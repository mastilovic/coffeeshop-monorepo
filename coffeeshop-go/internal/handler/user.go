package handler

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/middleware"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type UserHandler struct {
	db *gorm.DB
}

func NewUserHandler(db *gorm.DB) *UserHandler {
	return &UserHandler{db: db}
}

type userResponseDTO struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Username string `json:"username"`
	Email    string `json:"email"`
	UserType string `json:"userType"`
}

type userCreateRequest struct {
	Name     string `json:"name"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
	UserType string `json:"userType"`
}

type userUpdateRequest struct {
	Name     string `json:"name"`
	Username string `json:"username"`
	Email    string `json:"email"`
	UserType string `json:"userType"`
}

func toUserResponse(u auth.User) userResponseDTO {
	return userResponseDTO{
		ID:       u.ID,
		Name:     u.Name,
		Username: u.Username,
		Email:    u.Email,
		UserType: u.UserType,
	}
}

// GetAll returns either a flat list of all users or a paginated/searched result
// depending on whether the "page" query parameter is present.
func (h *UserHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	pageStr := r.URL.Query().Get("page")

	if pageStr == "" {
		h.listAll(w, r)
		return
	}
	h.paginatedSearch(w, r, pageStr)
}

func (h *UserHandler) listAll(w http.ResponseWriter, r *http.Request) {
	var users []auth.User
	if err := h.db.WithContext(r.Context()).Order("name ASC").Find(&users).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch users"))
		return
	}

	dtos := make([]userResponseDTO, len(users))
	for i, u := range users {
		dtos[i] = toUserResponse(u)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(dtos)
}

func (h *UserHandler) paginatedSearch(w http.ResponseWriter, r *http.Request, pageStr string) {
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 0 {
		apperror.WriteError(w, apperror.BadRequest("Invalid page parameter"))
		return
	}

	sizeStr := r.URL.Query().Get("size")
	size := 20
	if sizeStr != "" {
		if s, err := strconv.Atoi(sizeStr); err == nil && s > 0 {
			size = s
		}
	}

	q := strings.TrimSpace(r.URL.Query().Get("q"))

	query := h.db.WithContext(r.Context()).Model(&auth.User{})
	if q != "" {
		pattern := "%" + strings.ToLower(q) + "%"
		query = query.Where("LOWER(name) LIKE ? OR LOWER(email) LIKE ?", pattern, pattern)
	}

	var total int64
	if err := query.Count(&total).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to count users"))
		return
	}

	var users []auth.User
	if err := query.Order("name ASC").Offset(page * size).Limit(size).Find(&users).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch users"))
		return
	}

	dtos := make([]userResponseDTO, len(users))
	for i, u := range users {
		dtos[i] = toUserResponse(u)
	}

	resp := model.NewPageResponse(dtos, page, size, total)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *UserHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var user auth.User
	if err := h.db.WithContext(r.Context()).First(&user, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("User not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(toUserResponse(user))
}

func (h *UserHandler) Create(w http.ResponseWriter, r *http.Request) {
	if claims := middleware.GetUserClaims(r.Context()); claims == nil {
		apperror.WriteError(w, apperror.Unauthorized("Authentication required"))
		return
	}

	var req userCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	user := auth.User{
		ID:       uuid.New().String(),
		Name:     req.Name,
		Username: req.Username,
		Email:    req.Email,
		Password: req.Password,
		UserType: req.UserType,
	}

	if err := h.db.WithContext(r.Context()).Create(&user).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create user"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(toUserResponse(user))
}

func (h *UserHandler) Update(w http.ResponseWriter, r *http.Request) {
	if claims := middleware.GetUserClaims(r.Context()); claims == nil {
		apperror.WriteError(w, apperror.Unauthorized("Authentication required"))
		return
	}

	id := chi.URLParam(r, "id")
	var existing auth.User
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("User not found"))
		return
	}

	var req userUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	existing.Name = req.Name
	existing.Username = req.Username
	existing.Email = req.Email
	existing.UserType = req.UserType

	if err := h.db.WithContext(r.Context()).Save(&existing).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update user"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(toUserResponse(existing))
}

func (h *UserHandler) Delete(w http.ResponseWriter, r *http.Request) {
	if claims := middleware.GetUserClaims(r.Context()); claims == nil {
		apperror.WriteError(w, apperror.Unauthorized("Authentication required"))
		return
	}

	id := chi.URLParam(r, "id")
	result := h.db.WithContext(r.Context()).Delete(&auth.User{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete user"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("User not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
