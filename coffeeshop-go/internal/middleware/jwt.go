package middleware

import (
	"context"
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log/slog"
	"math/big"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type contextKeyType string

const UserClaimsKey contextKeyType = "userClaims"

type UserClaims struct {
	Subject  string
	Email    string
	Username string
	Roles    []string
}

type JWTMiddleware struct {
	issuerURI string
	keys      map[string]*rsa.PublicKey
	mu        sync.RWMutex
	lastFetch time.Time
}

func NewJWTMiddleware(issuerURI string) *JWTMiddleware {
	return &JWTMiddleware{
		issuerURI: issuerURI,
		keys:      make(map[string]*rsa.PublicKey),
	}
}

func (m *JWTMiddleware) Authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		tokenStr := extractBearerToken(r)
		if tokenStr == "" {
			http.Error(w, `{"message":"Authorization required"}`, http.StatusUnauthorized)
			return
		}

		claims, err := m.validateToken(tokenStr)
		if err != nil {
			slog.Debug("jwt validation failed", "error", err)
			http.Error(w, `{"message":"Invalid or expired token"}`, http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), UserClaimsKey, claims)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// OptionalAuth extracts claims if a valid token is present but does not reject the request.
func (m *JWTMiddleware) OptionalAuth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		tokenStr := extractBearerToken(r)
		if tokenStr != "" {
			claims, err := m.validateToken(tokenStr)
			if err == nil {
				ctx := context.WithValue(r.Context(), UserClaimsKey, claims)
				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}
		}
		next.ServeHTTP(w, r)
	})
}

func (m *JWTMiddleware) validateToken(tokenStr string) (*UserClaims, error) {
	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		kid, _ := t.Header["kid"].(string)
		return m.getKey(kid)
	}, jwt.WithIssuer(m.issuerURI), jwt.WithExpirationRequired())
	if err != nil {
		return nil, err
	}

	mapClaims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, fmt.Errorf("invalid claims type")
	}

	claims := &UserClaims{
		Subject:  getStringClaim(mapClaims, "sub"),
		Email:    getStringClaim(mapClaims, "email"),
		Username: getStringClaim(mapClaims, "preferred_username"),
	}

	if realmAccess, ok := mapClaims["realm_access"].(map[string]interface{}); ok {
		if roles, ok := realmAccess["roles"].([]interface{}); ok {
			for _, role := range roles {
				if s, ok := role.(string); ok {
					claims.Roles = append(claims.Roles, s)
				}
			}
		}
	}

	return claims, nil
}

func (m *JWTMiddleware) getKey(kid string) (*rsa.PublicKey, error) {
	m.mu.RLock()
	key, exists := m.keys[kid]
	lastFetch := m.lastFetch
	m.mu.RUnlock()

	if exists {
		return key, nil
	}

	if time.Since(lastFetch) < 30*time.Second {
		return nil, fmt.Errorf("key %s not found", kid)
	}

	if err := m.fetchJWKS(); err != nil {
		return nil, fmt.Errorf("failed to fetch JWKS: %w", err)
	}

	m.mu.RLock()
	key, exists = m.keys[kid]
	m.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("key %s not found after refresh", kid)
	}
	return key, nil
}

func (m *JWTMiddleware) fetchJWKS() error {
	jwksURL := m.issuerURI + "/protocol/openid-connect/certs"

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(jwksURL)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("JWKS endpoint returned %d", resp.StatusCode)
	}

	var jwks struct {
		Keys []struct {
			Kid string `json:"kid"`
			Kty string `json:"kty"`
			N   string `json:"n"`
			E   string `json:"e"`
		} `json:"keys"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&jwks); err != nil {
		return err
	}

	m.mu.Lock()
	defer m.mu.Unlock()

	for _, k := range jwks.Keys {
		if k.Kty != "RSA" {
			continue
		}
		pubKey, err := parseRSAPublicKey(k.N, k.E)
		if err != nil {
			slog.Warn("failed to parse JWKS key", "kid", k.Kid, "error", err)
			continue
		}
		m.keys[k.Kid] = pubKey
	}
	m.lastFetch = time.Now()
	return nil
}

func parseRSAPublicKey(nStr, eStr string) (*rsa.PublicKey, error) {
	nBytes, err := base64.RawURLEncoding.DecodeString(nStr)
	if err != nil {
		return nil, err
	}
	eBytes, err := base64.RawURLEncoding.DecodeString(eStr)
	if err != nil {
		return nil, err
	}

	n := new(big.Int).SetBytes(nBytes)
	e := new(big.Int).SetBytes(eBytes)

	return &rsa.PublicKey{N: n, E: int(e.Int64())}, nil
}

func extractBearerToken(r *http.Request) string {
	auth := r.Header.Get("Authorization")
	if len(auth) > 7 && strings.EqualFold(auth[:7], "bearer ") {
		return auth[7:]
	}
	return ""
}

func getStringClaim(claims jwt.MapClaims, key string) string {
	if v, ok := claims[key].(string); ok {
		return v
	}
	return ""
}

func GetUserClaims(ctx context.Context) *UserClaims {
	claims, _ := ctx.Value(UserClaimsKey).(*UserClaims)
	return claims
}
