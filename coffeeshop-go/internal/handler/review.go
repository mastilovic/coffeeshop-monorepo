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
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
	"gorm.io/gorm"
)

type ReviewHandler struct {
	db             *gorm.DB
	currentUserSvc *auth.CurrentUserService
	authorizer     *auth.ShopAuthorizer
	entitlements   *subscription.EntitlementService
}

func NewReviewHandler(
	db *gorm.DB,
	currentUserSvc *auth.CurrentUserService,
	authorizer *auth.ShopAuthorizer,
	entitlements *subscription.EntitlementService,
) *ReviewHandler {
	return &ReviewHandler{
		db:             db,
		currentUserSvc: currentUserSvc,
		authorizer:     authorizer,
		entitlements:   entitlements,
	}
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

type reviewUserResponse struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Username string `json:"username"`
}

type reviewResponse struct {
	ID              string              `json:"id"`
	Title           string              `json:"title"`
	Description     string              `json:"description"`
	Rating          int                 `json:"rating"`
	ReviewDate      string              `json:"reviewDate"`
	CommentsEnabled bool                `json:"commentsEnabled"`
	UserID          *string             `json:"userId"`
	ShopID          *string             `json:"shopId"`
	User            *reviewUserResponse `json:"user,omitempty"`
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

	resp, err := h.toReviewResponses(r, reviews)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch reviews"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *ReviewHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var review model.Review
	if err := h.db.WithContext(r.Context()).First(&review, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Review not found"))
		return
	}

	resp, err := h.toReviewResponse(r, review)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch review"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
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

		var existingCount int64
		if err := h.db.WithContext(r.Context()).
			Model(&model.Review{}).
			Where("user_id = ? AND shop_id = ?", user.ID, req.ShopID).
			Count(&existingCount).Error; err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to create review"))
			return
		}
		if existingCount > 0 {
			apperror.WriteError(w, apperror.Conflict("You have already reviewed this shop"))
			return
		}
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

	resp := reviewResponse{
		ID:              review.ID,
		Title:           review.Title,
		Description:     review.Description,
		Rating:          review.Rating,
		ReviewDate:      review.ReviewDate,
		CommentsEnabled: review.CommentsEnabled,
		UserID:          review.UserID,
		ShopID:          review.ShopID,
		User: &reviewUserResponse{
			ID:       user.ID,
			Name:     user.Name,
			Username: user.Username,
		},
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(resp)
}

func (h *ReviewHandler) Update(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
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

	if !h.canAuthorOrStaffUpdate(r, user, existing) {
		apperror.WriteError(w, apperror.Forbidden("You can only modify your own reviews"))
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

	resp, err := h.toReviewResponse(r, existing)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update review"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *ReviewHandler) Delete(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
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

	isAuthor := existing.UserID != nil && *existing.UserID == user.ID
	if isAuthor {
		// Authors may delete their own review without moderation entitlement.
	} else if existing.ShopID != nil && *existing.ShopID != "" {
		if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), *existing.ShopID); err != nil {
			apperror.WriteError(w, err)
			return
		}
		if !h.requireReviewModerate(w, r, *existing.ShopID) {
			return
		}
	} else {
		apperror.WriteError(w, apperror.Forbidden("You can only delete your own reviews"))
		return
	}

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

func (h *ReviewHandler) canAuthorOrStaffUpdate(r *http.Request, user *auth.User, review model.Review) bool {
	if review.UserID != nil && *review.UserID == user.ID {
		return true
	}
	if review.ShopID != nil && *review.ShopID != "" {
		return h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), *review.ShopID) == nil
	}
	return false
}

func (h *ReviewHandler) toReviewResponse(r *http.Request, review model.Review) (reviewResponse, error) {
	resp, err := h.toReviewResponses(r, []model.Review{review})
	if err != nil {
		return reviewResponse{}, err
	}
	if len(resp) == 0 {
		return reviewResponse{}, gorm.ErrRecordNotFound
	}
	return resp[0], nil
}

func (h *ReviewHandler) toReviewResponses(r *http.Request, reviews []model.Review) ([]reviewResponse, error) {
	if len(reviews) == 0 {
		return []reviewResponse{}, nil
	}

	userIDs := make([]string, 0, len(reviews))
	seen := map[string]struct{}{}
	for _, review := range reviews {
		if review.UserID == nil || *review.UserID == "" {
			continue
		}
		if _, ok := seen[*review.UserID]; ok {
			continue
		}
		seen[*review.UserID] = struct{}{}
		userIDs = append(userIDs, *review.UserID)
	}

	usersByID := map[string]reviewUserResponse{}
	if len(userIDs) > 0 {
		var users []auth.User
		if err := h.db.WithContext(r.Context()).
			Select("id, name, username").
			Where("id IN ?", userIDs).
			Find(&users).Error; err != nil {
			return nil, err
		}
		for _, u := range users {
			usersByID[u.ID] = reviewUserResponse{
				ID:       u.ID,
				Name:     u.Name,
				Username: u.Username,
			}
		}
	}

	resp := make([]reviewResponse, 0, len(reviews))
	for _, review := range reviews {
		item := reviewResponse{
			ID:              review.ID,
			Title:           review.Title,
			Description:     review.Description,
			Rating:          review.Rating,
			ReviewDate:      review.ReviewDate,
			CommentsEnabled: review.CommentsEnabled,
			UserID:          review.UserID,
			ShopID:          review.ShopID,
		}
		if review.UserID != nil {
			if user, ok := usersByID[*review.UserID]; ok {
				u := user
				item.User = &u
			}
		}
		resp = append(resp, item)
	}
	return resp, nil
}

func (h *ReviewHandler) requireReviewModerate(w http.ResponseWriter, r *http.Request, shopID string) bool {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return false
	}

	userID, err := uuid.Parse(user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Invalid user ID"))
		return false
	}

	shopUUID, err := uuid.Parse(shopID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Invalid shop ID"))
		return false
	}

	return subscription.RequireFeature(
		w, r, h.entitlements,
		userID, shopUUID,
		h.authorizer.IsAdmin(r.Context()),
		subscription.FeatureReviewModerate,
	)
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
