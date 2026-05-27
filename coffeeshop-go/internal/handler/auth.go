package handler

import (
	"encoding/base64"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"gorm.io/gorm"
)

func base64Decode(s string) ([]byte, error) {
	return base64.URLEncoding.DecodeString(s)
}

type AuthHandler struct {
	tokenClient *auth.KeycloakTokenClient
	adminClient *auth.KeycloakAdminClient
	db          *gorm.DB
}

func NewAuthHandler(tokenClient *auth.KeycloakTokenClient, adminClient *auth.KeycloakAdminClient, db *gorm.DB) *AuthHandler {
	return &AuthHandler{
		tokenClient: tokenClient,
		adminClient: adminClient,
		db:          db,
	}
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type refreshTokenRequest struct {
	RefreshToken string `json:"refreshToken"`
}

type logoutRequest struct {
	RefreshToken string `json:"refreshToken"`
}

type registerRequest struct {
	Name     string `json:"name"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
	Role     string `json:"role"`
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	var count int64
	h.db.Table("users").Where("LOWER(email) = LOWER(?)", req.Email).Count(&count)
	if count == 0 {
		apperror.WriteError(w, apperror.NotFound("not found"))
		return
	}

	tokens, err := h.tokenClient.PasswordGrant(req.Email, req.Password)
	if err != nil {
		apperror.WriteError(w, apperror.Unauthorized("Invalid email or password"))
		return
	}

	h.linkUserIfNeeded(tokens.AccessToken)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(tokens)
}

func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	var req refreshTokenRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	tokens, err := h.tokenClient.RefreshGrant(req.RefreshToken)
	if err != nil {
		apperror.WriteError(w, apperror.Unauthorized("Authentication failed. Please try again."))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(tokens)
}

func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	var req logoutRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	_ = h.tokenClient.Logout(req.RefreshToken)
	w.WriteHeader(http.StatusNoContent)
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req registerRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	if strings.EqualFold(req.Role, "admin") {
		apperror.WriteError(w, apperror.Forbidden("admin role is not allowed for self-registration"))
		return
	}

	if req.Role != "customer" && req.Role != "shop_owner" {
		apperror.WriteError(w, apperror.Validation("Invalid role"))
		return
	}

	var emailCount int64
	h.db.Table("users").Where("LOWER(email) = LOWER(?)", req.Email).Count(&emailCount)
	if emailCount > 0 {
		apperror.WriteError(w, apperror.NotFound("An account with this email already exists"))
		return
	}

	var usernameCount int64
	h.db.Table("users").Where("LOWER(username) = LOWER(?)", req.Username).Count(&usernameCount)
	if usernameCount > 0 {
		apperror.WriteError(w, apperror.NotFound("An account with this username already exists"))
		return
	}

	userType := "CUSTOMER"
	if req.Role == "shop_owner" {
		userType = "SHOP_OWNER"
	}

	keycloakUserID, err := h.adminClient.CreateUserWithRealmRole(req.Email, req.Password, req.Name, req.Role)
	if err != nil {
		if authErr, ok := err.(*auth.KeycloakAuthError); ok && authErr.StatusCode == 409 {
			apperror.WriteError(w, apperror.NotFound("An account with this email already exists"))
			return
		}
		apperror.WriteError(w, apperror.Internal("Registration failed with identity provider"))
		return
	}

	user := auth.User{
		Name:            req.Name,
		Username:        req.Username,
		Email:           req.Email,
		UserType:        userType,
		KeycloakSubject: keycloakUserID,
	}

	if result := h.db.Create(&user); result.Error != nil {
		h.adminClient.DeleteUserBestEffort(keycloakUserID)
		apperror.WriteError(w, apperror.Internal("Failed to create user"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"id":       user.ID,
		"name":     user.Name,
		"username": user.Username,
		"email":    user.Email,
		"userType": user.UserType,
	})
}

func (h *AuthHandler) linkUserIfNeeded(accessToken string) {
	parts := strings.Split(accessToken, ".")
	if len(parts) != 3 {
		return
	}

	// Decode JWT payload to extract sub and email
	payload, err := decodeJWTPayload(parts[1])
	if err != nil {
		return
	}

	sub, _ := payload["sub"].(string)
	if sub == "" {
		return
	}

	var existingCount int64
	h.db.Table("users").Where("keycloak_subject = ?", sub).Count(&existingCount)
	if existingCount > 0 {
		return
	}

	email, _ := payload["email"].(string)
	if email == "" {
		return
	}

	h.db.Table("users").
		Where("LOWER(email) = LOWER(?) AND keycloak_subject IS NULL", email).
		Update("keycloak_subject", sub)
}

func decodeJWTPayload(payload string) (map[string]interface{}, error) {
	switch len(payload) % 4 {
	case 2:
		payload += "=="
	case 3:
		payload += "="
	}

	decoded, err := base64Decode(payload)
	if err != nil {
		return nil, err
	}

	var claims map[string]interface{}
	if err := json.Unmarshal(decoded, &claims); err != nil {
		return nil, err
	}
	return claims, nil
}
