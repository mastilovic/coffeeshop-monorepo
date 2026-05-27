package testutil

import (
	"crypto/rand"
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"math/big"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type TestJWTIssuer struct {
	Server     *httptest.Server
	PrivateKey *rsa.PrivateKey
	Kid        string
	IssuerURI  string
}

func NewTestJWTIssuer(t *testing.T) *TestJWTIssuer {
	t.Helper()

	privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatalf("failed to generate RSA key: %v", err)
	}

	kid := "test-kid-001"

	mux := http.NewServeMux()
	issuer := &TestJWTIssuer{
		PrivateKey: privateKey,
		Kid:        kid,
	}

	mux.HandleFunc("/protocol/openid-connect/certs", func(w http.ResponseWriter, r *http.Request) {
		n := base64.RawURLEncoding.EncodeToString(privateKey.PublicKey.N.Bytes())
		e := base64.RawURLEncoding.EncodeToString(big.NewInt(int64(privateKey.PublicKey.E)).Bytes())

		jwks := map[string]interface{}{
			"keys": []map[string]interface{}{
				{
					"kid": kid,
					"kty": "RSA",
					"alg": "RS256",
					"use": "sig",
					"n":   n,
					"e":   e,
				},
			},
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(jwks)
	})

	server := httptest.NewServer(mux)
	issuer.Server = server
	issuer.IssuerURI = server.URL

	t.Cleanup(func() { server.Close() })

	return issuer
}

func (ti *TestJWTIssuer) CreateToken(subject string, roles []string) string {
	claims := jwt.MapClaims{
		"sub":                subject,
		"iss":                ti.IssuerURI,
		"exp":                time.Now().Add(1 * time.Hour).Unix(),
		"iat":                time.Now().Unix(),
		"preferred_username": "testuser-" + subject[:8],
		"email":              "test-" + subject[:8] + "@example.com",
		"realm_access": map[string]interface{}{
			"roles": roles,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	token.Header["kid"] = ti.Kid

	tokenStr, err := token.SignedString(ti.PrivateKey)
	if err != nil {
		panic("failed to sign test token: " + err.Error())
	}
	return tokenStr
}

func (ti *TestJWTIssuer) CreateTokenWithUsername(subject, username, email string, roles []string) string {
	claims := jwt.MapClaims{
		"sub":                subject,
		"iss":                ti.IssuerURI,
		"exp":                time.Now().Add(1 * time.Hour).Unix(),
		"iat":                time.Now().Unix(),
		"preferred_username": username,
		"email":              email,
		"realm_access": map[string]interface{}{
			"roles": roles,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	token.Header["kid"] = ti.Kid

	tokenStr, err := token.SignedString(ti.PrivateKey)
	if err != nil {
		panic("failed to sign test token: " + err.Error())
	}
	return tokenStr
}
