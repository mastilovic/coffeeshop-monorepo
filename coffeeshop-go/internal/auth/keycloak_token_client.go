package auth

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/mastilovic/coffeeshop-go/internal/config"
)

type TokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"`
	TokenType    string `json:"token_type"`
}

type KeycloakTokenClient struct {
	cfg        config.Config
	httpClient *http.Client
}

func NewKeycloakTokenClient(cfg config.Config) *KeycloakTokenClient {
	return &KeycloakTokenClient{
		cfg:        cfg,
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

func (c *KeycloakTokenClient) PasswordGrant(email, password string) (*TokenResponse, error) {
	form := url.Values{
		"grant_type":    {"password"},
		"client_id":     {c.cfg.KeycloakClientID},
		"client_secret": {c.cfg.KeycloakClientSecret},
		"username":      {email},
		"password":      {password},
	}
	return c.postToken(form)
}

func (c *KeycloakTokenClient) RefreshGrant(refreshToken string) (*TokenResponse, error) {
	form := url.Values{
		"grant_type":    {"refresh_token"},
		"client_id":     {c.cfg.KeycloakClientID},
		"client_secret": {c.cfg.KeycloakClientSecret},
		"refresh_token": {refreshToken},
	}
	return c.postToken(form)
}

func (c *KeycloakTokenClient) Logout(refreshToken string) error {
	form := url.Values{
		"client_id":     {c.cfg.KeycloakClientID},
		"client_secret": {c.cfg.KeycloakClientSecret},
		"refresh_token": {refreshToken},
	}
	logoutURI := c.cfg.KeycloakBaseURL + "/realms/" + c.cfg.KeycloakRealm + "/protocol/openid-connect/logout"

	resp, err := c.httpClient.PostForm(logoutURI, form)
	if err != nil {
		return fmt.Errorf("keycloak logout request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("keycloak logout failed with status %d", resp.StatusCode)
	}
	return nil
}

func (c *KeycloakTokenClient) postToken(form url.Values) (*TokenResponse, error) {
	tokenURI := c.cfg.KeycloakBaseURL + "/realms/" + c.cfg.KeycloakRealm + "/protocol/openid-connect/token"

	resp, err := c.httpClient.Post(tokenURI, "application/x-www-form-urlencoded", strings.NewReader(form.Encode()))
	if err != nil {
		return nil, fmt.Errorf("keycloak token request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return nil, &KeycloakAuthError{StatusCode: resp.StatusCode}
	}

	var body map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return nil, fmt.Errorf("failed to decode keycloak response: %w", err)
	}

	accessToken, _ := body["access_token"].(string)
	if accessToken == "" {
		return nil, fmt.Errorf("keycloak response missing access_token")
	}

	refreshToken, _ := body["refresh_token"].(string)
	tokenType, _ := body["token_type"].(string)
	if tokenType == "" {
		tokenType = "Bearer"
	}
	var expiresIn int64
	if exp, ok := body["expires_in"].(float64); ok {
		expiresIn = int64(exp)
	}

	return &TokenResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    expiresIn,
		TokenType:    tokenType,
	}, nil
}

type KeycloakAuthError struct {
	StatusCode int
}

func (e *KeycloakAuthError) Error() string {
	return fmt.Sprintf("keycloak auth failed with status %d", e.StatusCode)
}
