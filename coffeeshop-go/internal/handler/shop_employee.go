package handler

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
	"gorm.io/gorm"
)

type ShopEmployeeHandler struct {
	db           *gorm.DB
	authorizer   *auth.ShopAuthorizer
	currentUser  *auth.CurrentUserService
	entitlements *subscription.EntitlementService
}

func NewShopEmployeeHandler(
	db *gorm.DB,
	authorizer *auth.ShopAuthorizer,
	currentUser *auth.CurrentUserService,
	entitlements *subscription.EntitlementService,
) *ShopEmployeeHandler {
	return &ShopEmployeeHandler{
		db:           db,
		authorizer:   authorizer,
		currentUser:  currentUser,
		entitlements: entitlements,
	}
}

type assignEmployeeRequest struct {
	ShopID string `json:"shopId"`
	UserID string `json:"userId"`
}

type shopEmployeeResponse struct {
	UserID  string `json:"userId"`
	ShopID  string `json:"shopId"`
	Name    string `json:"name"`
	Email   string `json:"email"`
	IsOwner bool   `json:"isOwner"`
}

// Assign handles POST /shop-employees — assigns a user as an employee of a shop.
func (h *ShopEmployeeHandler) Assign(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUser.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req assignEmployeeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	if req.ShopID == "" || req.UserID == "" {
		apperror.WriteError(w, apperror.BadRequest("shopId and userId are required"))
		return
	}

	if err := h.authorizer.RequireShopOwnerOrAdmin(r.Context(), req.ShopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	if !h.requireEmployeeAssign(w, r, req.ShopID) {
		return
	}

	var targetUser auth.User
	if err := h.db.WithContext(r.Context()).First(&targetUser, "id = ?", req.UserID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("User not found"))
		return
	}

	var existing model.UserShop
	result := h.db.WithContext(r.Context()).
		Where("user_id = ? AND shop_id = ? AND relationship_type IN ?",
			req.UserID, req.ShopID, []string{model.RelationshipTypeOwner, model.RelationshipTypeEmployee}).
		First(&existing)
	if result.Error == nil {
		apperror.WriteError(w, apperror.BadRequest("User is already an owner or employee of this shop"))
		return
	}

	us := model.UserShop{
		ID:               uuid.New().String(),
		UserID:           req.UserID,
		ShopID:           req.ShopID,
		RelationshipType: model.RelationshipTypeEmployee,
	}
	if err := h.db.WithContext(r.Context()).Create(&us).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to assign employee"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(shopEmployeeResponse{
		UserID:  targetUser.ID,
		ShopID:  req.ShopID,
		Name:    targetUser.Name,
		Email:   targetUser.Email,
		IsOwner: false,
	})
}

// Remove handles DELETE /shop-employees — removes an employee from a shop.
func (h *ShopEmployeeHandler) Remove(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUser.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req assignEmployeeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	if req.ShopID == "" || req.UserID == "" {
		apperror.WriteError(w, apperror.BadRequest("shopId and userId are required"))
		return
	}

	if err := h.authorizer.RequireShopOwnerOrAdmin(r.Context(), req.ShopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	result := h.db.WithContext(r.Context()).
		Where("user_id = ? AND shop_id = ? AND relationship_type = ?", req.UserID, req.ShopID, model.RelationshipTypeEmployee).
		Delete(&model.UserShop{})
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to remove employee"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Employee relationship not found"))
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// List handles GET /shop/{shopId}/employees — lists employees for a shop.
func (h *ShopEmployeeHandler) List(w http.ResponseWriter, r *http.Request) {
	shopID := chi.URLParam(r, "shopId")

	var shop model.Shop
	if err := h.db.WithContext(r.Context()).First(&shop, "id = ?", shopID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}

	var userShops []model.UserShop
	if err := h.db.WithContext(r.Context()).
		Where("shop_id = ? AND relationship_type IN ?", shopID, []string{model.RelationshipTypeOwner, model.RelationshipTypeEmployee}).
		Find(&userShops).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch employees"))
		return
	}

	if len(userShops) == 0 {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode([]shopEmployeeResponse{})
		return
	}

	userIDs := make([]string, len(userShops))
	for i, us := range userShops {
		userIDs[i] = us.UserID
	}

	var users []auth.User
	if err := h.db.WithContext(r.Context()).Where("id IN ?", userIDs).Find(&users).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch user details"))
		return
	}

	userMap := make(map[string]auth.User, len(users))
	for _, u := range users {
		userMap[u.ID] = u
	}

	results := make([]shopEmployeeResponse, 0, len(userShops))
	for _, us := range userShops {
		u, ok := userMap[us.UserID]
		if !ok {
			continue
		}
		results = append(results, shopEmployeeResponse{
			UserID:  u.ID,
			ShopID:  shopID,
			Name:    u.Name,
			Email:   u.Email,
			IsOwner: us.RelationshipType == model.RelationshipTypeOwner,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}

// GetMyEmployeeShops handles GET /shop-employees/me — returns shops where the current user is an employee.
func (h *ShopEmployeeHandler) GetMyEmployeeShops(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUser.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	var shopIDs []string
	if err := h.db.WithContext(r.Context()).
		Model(&model.UserShop{}).
		Where("user_id = ? AND relationship_type = ?", user.ID, model.RelationshipTypeEmployee).
		Pluck("shop_id", &shopIDs).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch employee shops"))
		return
	}

	if len(shopIDs) == 0 {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode([]model.Shop{})
		return
	}

	var shops []model.Shop
	if err := h.db.WithContext(r.Context()).Where("id IN ?", shopIDs).Find(&shops).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch shops"))
		return
	}
	if shops == nil {
		shops = []model.Shop{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(shops)
}

func (h *ShopEmployeeHandler) requireEmployeeAssign(w http.ResponseWriter, r *http.Request, shopID string) bool {
	user, err := h.currentUser.RequireCurrentUser(r.Context())
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

	isAdmin := h.authorizer.IsAdmin(r.Context())
	if !subscription.RequireFeature(
		w, r, h.entitlements,
		userID, shopUUID, isAdmin,
		subscription.FeatureEmployeeAssign,
	) {
		return false
	}

	return subscription.RequireLimit(
		w, r, h.entitlements,
		userID, shopUUID,
		subscription.LimitEmployees, isAdmin,
	)
}
