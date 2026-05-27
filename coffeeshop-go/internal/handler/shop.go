package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

var allowedPageSizes = map[int]bool{10: true, 25: true, 50: true}

type ShopHandler struct {
	db             *gorm.DB
	currentUserSvc *auth.CurrentUserService
}

func NewShopHandler(db *gorm.DB, currentUserSvc *auth.CurrentUserService) *ShopHandler {
	return &ShopHandler{db: db, currentUserSvc: currentUserSvc}
}

type shopCreateRequest struct {
	Name        string `json:"name"`
	Address     string `json:"address"`
	City        string `json:"city"`
	PhoneNumber string `json:"phoneNumber"`
	Email       string `json:"email"`
	OwnerUserID string `json:"ownerUserId"`
}

type shopUpdateRequest struct {
	Name           string `json:"name"`
	Address        string `json:"address"`
	City           string `json:"city"`
	PhoneNumber    string `json:"phoneNumber"`
	Email          string `json:"email"`
	NewOwnerUserID string `json:"newOwnerUserId"`
}

type menuCreateRequest struct {
	Label string `json:"label"`
}

// GetShops handles GET /shop: flat list (no page param, public) or paginated search (with page param, auth).
func (h *ShopHandler) GetShops(w http.ResponseWriter, r *http.Request) {
	pageParam := r.URL.Query().Get("page")

	if pageParam == "" {
		h.listAllShops(w, r)
		return
	}

	h.paginatedSearch(w, r, pageParam)
}

func (h *ShopHandler) listAllShops(w http.ResponseWriter, r *http.Request) {
	var shops []model.Shop
	if err := h.db.WithContext(r.Context()).Find(&shops).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch shops"))
		return
	}
	if shops == nil {
		shops = []model.Shop{}
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(shops)
}

func (h *ShopHandler) paginatedSearch(w http.ResponseWriter, r *http.Request, pageParam string) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}
	_ = user

	page, err := strconv.Atoi(pageParam)
	if err != nil || page < 0 {
		apperror.WriteError(w, apperror.BadRequest("Invalid page parameter"))
		return
	}

	sizeParam := r.URL.Query().Get("size")
	size := 10
	if sizeParam != "" {
		s, err := strconv.Atoi(sizeParam)
		if err != nil || !allowedPageSizes[s] {
			apperror.WriteError(w, apperror.BadRequest("size must be one of: 10, 25, 50"))
			return
		}
		size = s
	}

	q := strings.TrimSpace(r.URL.Query().Get("q"))
	query := h.db.WithContext(r.Context()).Model(&model.Shop{})
	if q != "" {
		like := "%" + strings.ToLower(q) + "%"
		query = query.Where("LOWER(name) LIKE ? OR LOWER(city) LIKE ?", like, like)
	}

	var total int64
	if err := query.Count(&total).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to count shops"))
		return
	}

	var shops []model.Shop
	offset := page * size
	if err := query.Offset(offset).Limit(size).Find(&shops).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch shops"))
		return
	}

	resp := model.NewPageResponse(shops, page, size, total)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// GetMine handles GET /shop/mine — shops where current user is OWNER.
func (h *ShopHandler) GetMine(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	var shopIDs []string
	if err := h.db.WithContext(r.Context()).
		Model(&model.UserShop{}).
		Where("user_id = ? AND relationship_type = ?", user.ID, "OWNER").
		Pluck("shop_id", &shopIDs).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch user shops"))
		return
	}

	var shops []model.Shop
	if len(shopIDs) > 0 {
		if err := h.db.WithContext(r.Context()).Where("id IN ?", shopIDs).Find(&shops).Error; err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to fetch shops"))
			return
		}
	}
	if shops == nil {
		shops = []model.Shop{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(shops)
}

// GetByID handles GET /shop/{id}.
func (h *ShopHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var shop model.Shop
	if err := h.db.WithContext(r.Context()).First(&shop, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(shop)
}

// Create handles POST /shop.
func (h *ShopHandler) Create(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req shopCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	shop := model.Shop{
		ID:          uuid.New().String(),
		Name:        req.Name,
		Address:     req.Address,
		City:        req.City,
		PhoneNumber: req.PhoneNumber,
		Email:       req.Email,
	}

	err = h.db.WithContext(r.Context()).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&shop).Error; err != nil {
			return err
		}

		if req.OwnerUserID != "" {
			us := model.UserShop{
				ID:               uuid.New().String(),
				UserID:           req.OwnerUserID,
				ShopID:           shop.ID,
				RelationshipType: "OWNER",
			}
			if err := tx.Create(&us).Error; err != nil {
				return err
			}
		}
		return nil
	})

	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create shop"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(shop)
}

// Update handles PUT /shop/{id}.
func (h *ShopHandler) Update(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	id := chi.URLParam(r, "id")
	var existing model.Shop
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}

	var req shopUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	existing.Name = req.Name
	existing.Address = req.Address
	existing.City = req.City
	existing.PhoneNumber = req.PhoneNumber
	existing.Email = req.Email

	err = h.db.WithContext(r.Context()).Transaction(func(tx *gorm.DB) error {
		if err := tx.Save(&existing).Error; err != nil {
			return err
		}

		if req.NewOwnerUserID != "" {
			tx.Where("shop_id = ? AND relationship_type = ?", id, "OWNER").
				Delete(&model.UserShop{})

			us := model.UserShop{
				ID:               uuid.New().String(),
				UserID:           req.NewOwnerUserID,
				ShopID:           id,
				RelationshipType: "OWNER",
			}
			if err := tx.Create(&us).Error; err != nil {
				return err
			}
		}
		return nil
	})

	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update shop"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(existing)
}

// Delete handles DELETE /shop/{id}.
func (h *ShopHandler) Delete(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	id := chi.URLParam(r, "id")
	result := h.db.WithContext(r.Context()).Delete(&model.Shop{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete shop"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// AddFavourite handles POST /shop/{shopId}/favourite.
func (h *ShopHandler) AddFavourite(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	shopID := chi.URLParam(r, "shopId")
	var shop model.Shop
	if err := h.db.WithContext(r.Context()).First(&shop, "id = ?", shopID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}

	us := model.UserShop{
		ID:               uuid.New().String(),
		UserID:           user.ID,
		ShopID:           shopID,
		RelationshipType: "FAVOURITE",
	}
	if err := h.db.WithContext(r.Context()).Create(&us).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to add favourite"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(shop)
}

// RemoveFavourite handles DELETE /shop/{shopId}/favourite.
func (h *ShopHandler) RemoveFavourite(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	shopID := chi.URLParam(r, "shopId")
	var shop model.Shop
	if err := h.db.WithContext(r.Context()).First(&shop, "id = ?", shopID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}

	result := h.db.WithContext(r.Context()).
		Where("user_id = ? AND shop_id = ? AND relationship_type = ?", user.ID, shopID, "FAVOURITE").
		Delete(&model.UserShop{})
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to remove favourite"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(shop)
}

type menuResponse struct {
	ID        string  `json:"id"`
	Label     *string `json:"label"`
	CreatedAt string  `json:"createdAt"`
	ShopID    string  `json:"shopId"`
	Current   bool    `json:"current"`
}

// GetMenus handles GET /shop/{shopId}/menus.
func (h *ShopHandler) GetMenus(w http.ResponseWriter, r *http.Request) {
	shopID := chi.URLParam(r, "shopId")

	var shop model.Shop
	if err := h.db.WithContext(r.Context()).First(&shop, "id = ?", shopID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}

	var menus []model.Menu
	if err := h.db.WithContext(r.Context()).Where("shop_id = ?", shopID).Find(&menus).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch menus"))
		return
	}

	results := make([]menuResponse, len(menus))
	for i, m := range menus {
		results[i] = menuResponse{
			ID:        m.ID,
			Label:     m.Label,
			CreatedAt: m.CreatedAt.Format("2006-01-02T15:04:05"),
			ShopID:    m.ShopID,
			Current:   shop.CurrentMenuID != nil && *shop.CurrentMenuID == m.ID,
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}

// CreateMenu handles POST /shop/{shopId}/menus.
func (h *ShopHandler) CreateMenu(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	shopID := chi.URLParam(r, "shopId")

	var shop model.Shop
	if err := h.db.WithContext(r.Context()).First(&shop, "id = ?", shopID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}

	var req menuCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	menu := model.Menu{
		ID:     uuid.New().String(),
		ShopID: shopID,
	}
	if req.Label != "" {
		menu.Label = &req.Label
	}

	err = h.db.WithContext(r.Context()).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&menu).Error; err != nil {
			return err
		}
		if err := tx.Model(&model.Shop{}).Where("id = ?", shopID).
			Update("current_menu_id", menu.ID).Error; err != nil {
			return fmt.Errorf("failed to set current menu: %w", err)
		}
		return nil
	})
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create menu"))
		return
	}

	menu.Current = true

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(menu)
}
