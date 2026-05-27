package auth

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/mastilovic/coffeeshop-go/internal/config"
)

type KeycloakAdminClient struct {
	cfg        config.Config
	httpClient *http.Client
}

func NewKeycloakAdminClient(cfg config.Config) *KeycloakAdminClient {
	return &KeycloakAdminClient{
		cfg:        cfg,
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

func (c *KeycloakAdminClient) CreateUserWithRealmRole(email, password, name, realmRoleName string) (string, error) {
	adminToken, err := c.obtainAdminAccessToken()
	if err != nil {
		return "", err
	}

	payload := map[string]interface{}{
		"username":      email,
		"email":         email,
		"firstName":     name,
		"lastName":      name,
		"enabled":       true,
		"emailVerified": true,
		"credentials": []map[string]interface{}{
			{"type": "password", "value": password, "temporary": false},
		},
	}

	body, _ := json.Marshal(payload)
	usersURI := c.adminUsersBaseURI()
	req, _ := http.NewRequest(http.MethodPost, usersURI, bytes.NewReader(body))
	req.Header.Set("Authorization", "Bearer "+adminToken)
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("keycloak create user request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == 409 {
		return "", &KeycloakAuthError{StatusCode: 409}
	}
	if resp.StatusCode >= 400 {
		return "", fmt.Errorf("keycloak create user failed with status %d", resp.StatusCode)
	}

	location := resp.Header.Get("Location")
	if location == "" {
		return "", fmt.Errorf("keycloak user create response missing Location header")
	}
	parts := strings.Split(location, "/")
	userID := parts[len(parts)-1]

	if err := c.assignRealmRole(userID, realmRoleName, adminToken); err != nil {
		c.deleteUserBestEffort(userID, adminToken)
		return "", err
	}

	return userID, nil
}

func (c *KeycloakAdminClient) DeleteUserBestEffort(userID string) {
	adminToken, err := c.obtainAdminAccessToken()
	if err != nil {
		return
	}
	c.deleteUserBestEffort(userID, adminToken)
}

func (c *KeycloakAdminClient) deleteUserBestEffort(userID, adminToken string) {
	req, _ := http.NewRequest(http.MethodDelete, c.adminUsersBaseURI()+"/"+userID, nil)
	req.Header.Set("Authorization", "Bearer "+adminToken)
	resp, err := c.httpClient.Do(req)
	if err == nil {
		resp.Body.Close()
	}
}

func (c *KeycloakAdminClient) assignRealmRole(userID, roleName, adminToken string) error {
	roleURI := c.cfg.KeycloakBaseURL + "/admin/realms/" + c.cfg.KeycloakRealm + "/roles/" + roleName
	req, _ := http.NewRequest(http.MethodGet, roleURI, nil)
	req.Header.Set("Authorization", "Bearer "+adminToken)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("failed to fetch role: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("realm role not found: %s", roleName)
	}

	var roleRep map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&roleRep); err != nil {
		return fmt.Errorf("failed to decode role response: %w", err)
	}

	roleBody, _ := json.Marshal([]interface{}{roleRep})
	mappingURI := c.adminUsersBaseURI() + "/" + userID + "/role-mappings/realm"
	req2, _ := http.NewRequest(http.MethodPost, mappingURI, bytes.NewReader(roleBody))
	req2.Header.Set("Authorization", "Bearer "+adminToken)
	req2.Header.Set("Content-Type", "application/json")

	resp2, err := c.httpClient.Do(req2)
	if err != nil {
		return fmt.Errorf("failed to assign role: %w", err)
	}
	defer resp2.Body.Close()

	if resp2.StatusCode >= 400 {
		return fmt.Errorf("keycloak role assignment failed with status %d", resp2.StatusCode)
	}
	return nil
}

func (c *KeycloakAdminClient) obtainAdminAccessToken() (string, error) {
	adminTokenURI := c.cfg.KeycloakBaseURL + "/realms/master/protocol/openid-connect/token"
	form := url.Values{
		"grant_type": {"password"},
		"client_id":  {"admin-cli"},
		"username":   {c.cfg.KeycloakAdminUser},
		"password":   {c.cfg.KeycloakAdminPassword},
	}

	resp, err := c.httpClient.Post(adminTokenURI, "application/x-www-form-urlencoded", strings.NewReader(form.Encode()))
	if err != nil {
		return "", fmt.Errorf("keycloak admin login failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return "", fmt.Errorf("keycloak admin login failed with status %d", resp.StatusCode)
	}

	var body map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return "", fmt.Errorf("failed to decode admin token response: %w", err)
	}

	token, _ := body["access_token"].(string)
	if token == "" {
		return "", fmt.Errorf("keycloak admin token missing access_token")
	}
	return token, nil
}

func (c *KeycloakAdminClient) adminUsersBaseURI() string {
	return c.cfg.KeycloakBaseURL + "/admin/realms/" + c.cfg.KeycloakRealm + "/users"
}
