package handler

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type ReviewHandler struct {
	db             *gorm.DB
	currentUserSvc *auth.CurrentUserService
}

func NewReviewHandler(db *gorm.DB, currentUserSvc *auth.CurrentUserService) *ReviewHandler {
	return &ReviewHandler{db: db, currentUserSvc: currentUserSvc}
}

type reviewCreateRequest struct {
	Title           string `json:"title"`
	Description     string `json:"description"`
	Rating          int    `json:"rating"`
	CommentsEnabled bool   `json:"commentsEnabled"`
	ShopID          string `json:"shopId"`
}

type reviewUpdateRequest struct {
	Title           string `json:"title"`
	Description     string `json:"description"`
	Rating          int    `json:"rating"`
	CommentsEnabled bool   `json:"commentsEnabled"`
}

type reviewCommentCreateRequest struct {
	Body string `json:"body"`
}

func (h *ReviewHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	var reviews []model.Review
	if err := h.db.WithContext(r.Context()).Find(&reviews).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch reviews"))
		return
	}
	if reviews == nil {
		reviews = []model.Review{}
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reviews)
}

func (h *ReviewHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var review model.Review
	if err := h.db.WithContext(r.Context()).First(&review, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Review not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(review)
}

func (h *ReviewHandler) Create(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req reviewCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	var shopID *string
	if req.ShopID != "" {
		shopID = &req.ShopID
	}

	review := model.Review{
		ID:              uuid.New().String(),
		Title:           req.Title,
		Description:     req.Description,
		Rating:          req.Rating,
		ReviewDate:      time.Now().Format("2006-01-02"),
		CommentsEnabled: req.CommentsEnabled,
		UserID:          &user.ID,
		ShopID:          shopID,
	}

	if err := h.db.WithContext(r.Context()).Create(&review).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create review"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(review)
}

func (h *ReviewHandler) Update(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	id := chi.URLParam(r, "id")
	var existing model.Review
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Review not found"))
		return
	}

	var req reviewUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	existing.Title = req.Title
	existing.Description = req.Description
	existing.Rating = req.Rating
	existing.CommentsEnabled = req.CommentsEnabled

	if err := h.db.WithContext(r.Context()).Save(&existing).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update review"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(existing)
}

func (h *ReviewHandler) Delete(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	id := chi.URLParam(r, "id")
	result := h.db.WithContext(r.Context()).Delete(&model.Review{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete review"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Review not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *ReviewHandler) GetComments(w http.ResponseWriter, r *http.Request) {
	reviewID := chi.URLParam(r, "reviewId")

	var review model.Review
	if err := h.db.WithContext(r.Context()).First(&review, "id = ?", reviewID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Review not found"))
		return
	}

	var comments []model.ReviewComment
	if err := h.db.WithContext(r.Context()).Where("review_id = ?", reviewID).Find(&comments).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch comments"))
		return
	}
	if comments == nil {
		comments = []model.ReviewComment{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(comments)
}

func (h *ReviewHandler) CreateComment(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	reviewID := chi.URLParam(r, "reviewId")

	var review model.Review
	if err := h.db.WithContext(r.Context()).First(&review, "id = ?", reviewID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Review not found"))
		return
	}

	var req reviewCommentCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	comment := model.ReviewComment{
		ID:        uuid.New().String(),
		Body:      req.Body,
		CreatedAt: time.Now().Format("2006-01-02T15:04:05"),
		UserID:    &user.ID,
		ReviewID:  &reviewID,
	}

	if err := h.db.WithContext(r.Context()).Create(&comment).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create comment"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(comment)
}
