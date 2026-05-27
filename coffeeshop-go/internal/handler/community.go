package handler

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type CommunityHandler struct {
	db             *gorm.DB
	currentUserSvc *auth.CurrentUserService
}

func NewCommunityHandler(db *gorm.DB, currentUserSvc *auth.CurrentUserService) *CommunityHandler {
	return &CommunityHandler{db: db, currentUserSvc: currentUserSvc}
}

type communityPostCreateRequest struct {
	Body string `json:"body"`
}

type memberSummary struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Username string `json:"username"`
}

func (h *CommunityHandler) GetPosts(w http.ResponseWriter, r *http.Request) {
	shopID := chi.URLParam(r, "shopId")

	page := 0
	size := 20
	if p := r.URL.Query().Get("page"); p != "" {
		if v, err := strconv.Atoi(p); err == nil && v >= 0 {
			page = v
		}
	}
	if s := r.URL.Query().Get("size"); s != "" {
		if v, err := strconv.Atoi(s); err == nil && v > 0 {
			size = v
		}
	}

	query := h.db.WithContext(r.Context()).Model(&model.CommunityPost{}).Where("shop_id = ?", shopID)

	var total int64
	if err := query.Count(&total).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to count posts"))
		return
	}

	var posts []model.CommunityPost
	if err := query.Order("pinned DESC, created_at DESC").
		Offset(page * size).Limit(size).Find(&posts).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch posts"))
		return
	}

	resp := model.NewPageResponse(posts, page, size, total)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *CommunityHandler) GetMembers(w http.ResponseWriter, r *http.Request) {
	shopID := chi.URLParam(r, "shopId")

	page := 0
	size := 20
	if p := r.URL.Query().Get("page"); p != "" {
		if v, err := strconv.Atoi(p); err == nil && v >= 0 {
			page = v
		}
	}
	if s := r.URL.Query().Get("size"); s != "" {
		if v, err := strconv.Atoi(s); err == nil && v > 0 {
			size = v
		}
	}

	var userIDs []string
	if err := h.db.WithContext(r.Context()).
		Model(&model.UserShop{}).
		Where("shop_id = ? AND relationship_type = ?", shopID, "FAVOURITE").
		Pluck("user_id", &userIDs).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch members"))
		return
	}

	if len(userIDs) == 0 {
		resp := model.NewPageResponse([]memberSummary{}, page, size, 0)
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
		return
	}

	q := strings.TrimSpace(r.URL.Query().Get("q"))
	userQuery := h.db.WithContext(r.Context()).Model(&auth.User{}).Where("id IN ?", userIDs)
	if q != "" {
		pattern := "%" + strings.ToLower(q) + "%"
		userQuery = userQuery.Where("LOWER(name) LIKE ?", pattern)
	}

	var total int64
	if err := userQuery.Count(&total).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to count members"))
		return
	}

	var users []auth.User
	if err := userQuery.Offset(page * size).Limit(size).Find(&users).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch members"))
		return
	}

	members := make([]memberSummary, len(users))
	for i, u := range users {
		members[i] = memberSummary{
			ID:       u.ID,
			Name:     u.Name,
			Username: u.Username,
		}
	}

	resp := model.NewPageResponse(members, page, size, total)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *CommunityHandler) CreateAnnouncement(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	shopID := chi.URLParam(r, "shopId")

	var req communityPostCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	post := model.CommunityPost{
		ID:        uuid.New().String(),
		Body:      req.Body,
		CreatedAt: time.Now().Format("2006-01-02T15:04:05"),
		Type:      "ANNOUNCEMENT",
		Pinned:    false,
		AuthorID:  &user.ID,
		ShopID:    &shopID,
	}

	if err := h.db.WithContext(r.Context()).Create(&post).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create announcement"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(post)
}

func (h *CommunityHandler) DeletePost(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	shopID := chi.URLParam(r, "shopId")
	postID := chi.URLParam(r, "postId")

	result := h.db.WithContext(r.Context()).
		Where("id = ? AND shop_id = ?", postID, shopID).
		Delete(&model.CommunityPost{})
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete post"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Post not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
