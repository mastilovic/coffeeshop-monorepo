package handler

import (
	"context"
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
	authorizer     *auth.ShopAuthorizer
}

func NewShopHandler(db *gorm.DB, currentUserSvc *auth.CurrentUserService, authorizer *auth.ShopAuthorizer) *ShopHandler {
	return &ShopHandler{db: db, currentUserSvc: currentUserSvc, authorizer: authorizer}
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

// --- Full shop detail response types ---

type fullShopResponse struct {
	ID          string        `json:"id"`
	Name        string        `json:"name"`
	Address     string        `json:"address"`
	City        string        `json:"city"`
	PhoneNumber string        `json:"phoneNumber"`
	Email       string        `json:"email"`
	CreatedBy   *ownerSummary `json:"createdBy"`

	Users                   []ownerSummary           `json:"users"`
	CurrentMenu             *menuWithItemsResponse   `json:"currentMenu"`
	MenuHistory             []menuWithItemsResponse  `json:"menuHistory"`
	LoyaltyPlan             *loyaltyPlanSummary      `json:"loyaltyPlan"`
	Events                  []eventSummary           `json:"events"`
	Tables                  []tableSummary           `json:"tables"`
	Reviews                 []reviewWithUserResponse `json:"reviews"`
	ReviewCount             int                      `json:"reviewCount"`
	AverageRating           *float64                 `json:"averageRating"`
	Contacts                []contactSummary         `json:"contacts"`
	FavouriteByCurrentUser  *bool                    `json:"favouriteByCurrentUser,omitempty"`
	MemberCount             *int                     `json:"memberCount,omitempty"`
}

type menuWithItemsResponse struct {
	ID        string            `json:"id"`
	Label     *string           `json:"label"`
	CreatedAt string            `json:"createdAt"`
	ShopID    string            `json:"shopId"`
	Current   bool              `json:"current"`
	Items     []menuItemSummary `json:"items"`
}

type menuItemSummary struct {
	ID            string  `json:"id"`
	Name          string  `json:"name"`
	Description   string  `json:"description"`
	Price         float64 `json:"price"`
	PriceCurrency string  `json:"priceCurrency"`
	ImageURL      string  `json:"imageUrl"`
	ItemType      string  `json:"itemType"`
	MenuID        string  `json:"menuId"`
}

type tableSummary struct {
	ID       string `json:"id"`
	Number   int    `json:"number"`
	Capacity int    `json:"capacity"`
	ShopID   string `json:"shopId"`
}

type eventSummary struct {
	EventID     string `json:"eventId"`
	EventName   string `json:"eventName"`
	EventDate   string `json:"eventDate"`
	Description string `json:"description"`
	ShopID      string `json:"shopId"`
	ShopName    string `json:"shopName"`
	City        string `json:"city"`
}

type reviewWithUserResponse struct {
	ID              string       `json:"id"`
	Rating          int          `json:"rating"`
	Description     string       `json:"description"`
	ReviewDate      string       `json:"reviewDate"`
	CommentsEnabled bool         `json:"commentsEnabled"`
	User            ownerSummary `json:"user"`
	Comments        []string     `json:"comments"`
}

type loyaltyPlanSummary struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Type        string `json:"type"`
}

type contactSummary struct {
	ID     string `json:"id"`
	ShopID string `json:"shopId"`
}

type shopWithOwnerResponse struct {
	ID          string        `json:"id"`
	Name        string        `json:"name"`
	Address     string        `json:"address"`
	City        string        `json:"city"`
	PhoneNumber string        `json:"phoneNumber"`
	Email       string        `json:"email"`
	CreatedBy   *ownerSummary `json:"createdBy"`
}

type ownerSummary struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Username string `json:"username"`
}

// fillShopOwners enriches a slice of shops with their owner information
// by joining user_shop (relationship_type = 'OWNER') with the users table.
func fillShopOwners(ctx context.Context, db *gorm.DB, shops []model.Shop) ([]shopWithOwnerResponse, error) {
	if len(shops) == 0 {
		return []shopWithOwnerResponse{}, nil
	}

	shopIDs := make([]string, len(shops))
	for i, s := range shops {
		shopIDs[i] = s.ID
	}

	type ownerRow struct {
		ShopID   string
		UserID   string
		UserName string
		Username string
	}
	var ownerRows []ownerRow
	if err := db.WithContext(ctx).
		Table("user_shop").
		Select("user_shop.shop_id, users.id AS user_id, users.name AS user_name, users.username").
		Joins("JOIN users ON users.id = user_shop.user_id").
		Where("user_shop.shop_id IN ? AND user_shop.relationship_type = ?", shopIDs, model.RelationshipTypeOwner).
		Scan(&ownerRows).Error; err != nil {
		return nil, err
	}

	ownerMap := make(map[string]*ownerSummary, len(ownerRows))
	for _, row := range ownerRows {
		ownerMap[row.ShopID] = &ownerSummary{
			ID:       row.UserID,
			Name:     row.UserName,
			Username: row.Username,
		}
	}

	results := make([]shopWithOwnerResponse, len(shops))
	for i, s := range shops {
		results[i] = shopWithOwnerResponse{
			ID:          s.ID,
			Name:        s.Name,
			Address:     s.Address,
			City:        s.City,
			PhoneNumber: s.PhoneNumber,
			Email:       s.Email,
			CreatedBy:   ownerMap[s.ID],
		}
	}
	return results, nil
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

	enriched, err := fillShopOwners(r.Context(), h.db, shops)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch shop owners"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(enriched)
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

	city := strings.TrimSpace(r.URL.Query().Get("city"))
	if city != "" {
		query = query.Where("city = ?", city)
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

	enriched, err := fillShopOwners(r.Context(), h.db, shops)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch shop owners"))
		return
	}

	resp := model.NewPageResponse(enriched, page, size, total)
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

// buildFullShopResponse loads all related data for a single shop and returns
// a full detail response suitable for the shop detail page.
func (h *ShopHandler) buildFullShopResponse(ctx context.Context, shop model.Shop) (*fullShopResponse, error) {
	resp := &fullShopResponse{
		ID:          shop.ID,
		Name:        shop.Name,
		Address:     shop.Address,
		City:        shop.City,
		PhoneNumber: shop.PhoneNumber,
		Email:       shop.Email,
		Users:       []ownerSummary{},
		MenuHistory: []menuWithItemsResponse{},
		Events:      []eventSummary{},
		Tables:      []tableSummary{},
		Reviews:     []reviewWithUserResponse{},
		Contacts:    []contactSummary{},
	}

	// 1. Owner (same logic as fillShopOwners but for a single shop).
	var ownerRow struct {
		UserID   string
		UserName string
		Username string
	}
	err := h.db.WithContext(ctx).
		Table("user_shop").
		Select("users.id AS user_id, users.name AS user_name, users.username").
		Joins("JOIN users ON users.id = user_shop.user_id").
		Where("user_shop.shop_id = ? AND user_shop.relationship_type = ?", shop.ID, model.RelationshipTypeOwner).
		Scan(&ownerRow).Error
	if err != nil {
		return nil, err
	}
	if ownerRow.UserID != "" {
		resp.CreatedBy = &ownerSummary{
			ID:       ownerRow.UserID,
			Name:     ownerRow.UserName,
			Username: ownerRow.Username,
		}
	}

	// 2. Menus + items.
	var menus []model.Menu
	if err := h.db.WithContext(ctx).Where("shop_id = ?", shop.ID).Order("created_at DESC").Find(&menus).Error; err != nil {
		return nil, err
	}
	menuIDs := make([]string, len(menus))
	for i, m := range menus {
		menuIDs[i] = m.ID
	}
	itemMap := map[string][]model.MenuItem{}
	if len(menuIDs) > 0 {
		var items []model.MenuItem
		if err := h.db.WithContext(ctx).Where("menu_id IN ?", menuIDs).Find(&items).Error; err != nil {
			return nil, err
		}
		for _, it := range items {
			itemMap[it.MenuID] = append(itemMap[it.MenuID], it)
		}
	}
	for _, m := range menus {
		mr := menuWithItemsResponse{
			ID:        m.ID,
			Label:     m.Label,
			CreatedAt: m.CreatedAt.Format("2006-01-02T15:04:05"),
			ShopID:    m.ShopID,
			Current:   shop.CurrentMenuID != nil && *shop.CurrentMenuID == m.ID,
			Items:     []menuItemSummary{},
		}
		for _, it := range itemMap[m.ID] {
			mr.Items = append(mr.Items, menuItemSummary{
				ID:            it.ID,
				Name:          it.Name,
				Description:   it.Description,
				Price:         it.Price,
				PriceCurrency: it.PriceCurrency,
				ImageURL:      it.ImageURL,
				ItemType:      string(it.ItemType),
				MenuID:        it.MenuID,
			})
		}
		if mr.Current {
			resp.CurrentMenu = &mr
		} else {
			resp.MenuHistory = append(resp.MenuHistory, mr)
		}
	}
	// If no current menu is set but there are menus, pick the latest.
	if resp.CurrentMenu == nil && len(menus) > 0 {
		latest := menus[0]
		resp.CurrentMenu = &menuWithItemsResponse{
			ID:        latest.ID,
			Label:     latest.Label,
			CreatedAt: latest.CreatedAt.Format("2006-01-02T15:04:05"),
			ShopID:    latest.ShopID,
			Current:   true,
			Items:     []menuItemSummary{},
		}
		for _, it := range itemMap[latest.ID] {
			resp.CurrentMenu.Items = append(resp.CurrentMenu.Items, menuItemSummary{
				ID:            it.ID,
				Name:          it.Name,
				Description:   it.Description,
				Price:         it.Price,
				PriceCurrency: it.PriceCurrency,
				ImageURL:      it.ImageURL,
				ItemType:      string(it.ItemType),
				MenuID:        it.MenuID,
			})
		}
		// Remove from menu history.
		resp.MenuHistory = nil
		for _, m := range menus {
			if m.ID == latest.ID {
				continue
			}
			mr := menuWithItemsResponse{
				ID:        m.ID,
				Label:     m.Label,
				CreatedAt: m.CreatedAt.Format("2006-01-02T15:04:05"),
				ShopID:    m.ShopID,
				Current:   false,
				Items:     []menuItemSummary{},
			}
			for _, it := range itemMap[m.ID] {
				mr.Items = append(mr.Items, menuItemSummary{
					ID:            it.ID,
					Name:          it.Name,
					Description:   it.Description,
					Price:         it.Price,
					PriceCurrency: it.PriceCurrency,
					ImageURL:      it.ImageURL,
					ItemType:      string(it.ItemType),
					MenuID:        it.MenuID,
				})
			}
			resp.MenuHistory = append(resp.MenuHistory, mr)
		}
	}

	// 3. Tables.
	var tables []model.Table
	if err := h.db.WithContext(ctx).Where("shop_id = ?", shop.ID).Order("\"number\" ASC").Find(&tables).Error; err != nil {
		return nil, err
	}
	for _, t := range tables {
		resp.Tables = append(resp.Tables, tableSummary{
			ID:       t.ID,
			Number:   t.Number,
			Capacity: t.Capacity,
			ShopID:   t.ShopID,
		})
	}

	// 4. Events.
	var events []model.Event
	if err := h.db.WithContext(ctx).Where("shop_id = ?", shop.ID).Order("event_date DESC").Find(&events).Error; err != nil {
		return nil, err
	}
	for _, e := range events {
		shopID := ""
		if e.ShopID != nil {
			shopID = *e.ShopID
		}
		resp.Events = append(resp.Events, eventSummary{
			EventID:     e.EventID,
			EventName:   e.EventName,
			EventDate:   e.EventDate,
			Description: e.Description,
			ShopID:      shopID,
			ShopName:    shop.Name,
			City:        shop.City,
		})
	}

	// 5. Reviews with user info.
	type reviewRow struct {
		ID              string
		Rating          int
		Description     string
		ReviewDate      string
		CommentsEnabled bool
		UserID          string
		UserName        string
		Username        string
	}
	var reviewRows []reviewRow
	if err := h.db.WithContext(ctx).
		Table("review").
		Select("review.id, review.rating, review.description, review.review_date, review.comments_enabled, users.id AS user_id, users.name AS user_name, users.username").
		Joins("JOIN users ON users.id = review.user_id").
		Where("review.shop_id = ?", shop.ID).
		Order("review.review_date DESC").
		Scan(&reviewRows).Error; err != nil {
		return nil, err
	}
	var totalRating int
	for _, r := range reviewRows {
		totalRating += r.Rating
		resp.Reviews = append(resp.Reviews, reviewWithUserResponse{
			ID:              r.ID,
			Rating:          r.Rating,
			Description:     r.Description,
			ReviewDate:      r.ReviewDate,
			CommentsEnabled: r.CommentsEnabled,
			User: ownerSummary{
				ID:       r.UserID,
				Name:     r.UserName,
				Username: r.Username,
			},
			Comments: []string{},
		})
	}
	resp.ReviewCount = len(reviewRows)
	if resp.ReviewCount > 0 {
		avg := float64(totalRating) / float64(resp.ReviewCount)
		resp.AverageRating = &avg
	}

	// 6. Loyalty plan.
	if shop.LoyaltyPlanID != nil {
		var lp model.LoyaltyPlan
		if err := h.db.WithContext(ctx).First(&lp, "id = ?", *shop.LoyaltyPlanID).Error; err == nil {
			resp.LoyaltyPlan = &loyaltyPlanSummary{
				ID:          lp.ID,
				Name:        lp.Name,
				Description: lp.Description,
				Type:        string(lp.Type),
			}
		}
	}

	// 7. Contacts.
	var contacts []model.Contact
	if err := h.db.WithContext(ctx).Where("shop_id = ?", shop.ID).Find(&contacts).Error; err != nil {
		return nil, err
	}
	for _, c := range contacts {
		resp.Contacts = append(resp.Contacts, contactSummary{ID: c.ID, ShopID: c.ShopID})
	}

	// 8. Member count (users who FAVOURITE'd this shop).
	var mc int64
	if err := h.db.WithContext(ctx).
		Model(&model.UserShop{}).
		Where("shop_id = ? AND relationship_type = ?", shop.ID, model.RelationshipTypeFavourite).
		Count(&mc).Error; err != nil {
		return nil, err
	}
	mcInt := int(mc)
	resp.MemberCount = &mcInt

	// 9. Favourite status for current user.
	if user := h.currentUserSvc.GetCurrentUser(ctx); user != nil {
		var fc int64
		h.db.WithContext(ctx).
			Model(&model.UserShop{}).
			Where("user_id = ? AND shop_id = ? AND relationship_type = ?", user.ID, shop.ID, model.RelationshipTypeFavourite).
			Count(&fc)
		isFav := fc > 0
		resp.FavouriteByCurrentUser = &isFav
	}

	return resp, nil
}

// GetByID handles GET /shop/{id}.
func (h *ShopHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var shop model.Shop
	if err := h.db.WithContext(r.Context()).First(&shop, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Shop not found"))
		return
	}

	full, err := h.buildFullShopResponse(r.Context(), shop)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch shop details"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(full)
}

// Create handles POST /shop.
func (h *ShopHandler) Create(w http.ResponseWriter, r *http.Request) {
	_, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	if err := h.authorizer.RequireCanCreateShop(r.Context()); err != nil {
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

	if err := h.authorizer.RequireShopOwnerOrAdmin(r.Context(), id); err != nil {
		apperror.WriteError(w, err)
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

	if err := h.authorizer.RequireShopOwnerOrAdmin(r.Context(), id); err != nil {
		apperror.WriteError(w, err)
		return
	}

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

	var ownerCount int64
	if err := h.db.WithContext(r.Context()).Model(&model.UserShop{}).
		Where("user_id = ? AND shop_id = ? AND relationship_type = ?", user.ID, shopID, model.RelationshipTypeOwner).
		Count(&ownerCount).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to verify shop ownership"))
		return
	}
	if ownerCount > 0 {
		apperror.WriteError(w, apperror.Conflict("Shop owners cannot favourite their own shop"))
		return
	}

	var existingCount int64
	if err := h.db.WithContext(r.Context()).Model(&model.UserShop{}).
		Where("user_id = ? AND shop_id = ? AND relationship_type = ?", user.ID, shopID, model.RelationshipTypeFavourite).
		Count(&existingCount).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to verify favourite status"))
		return
	}
	if existingCount == 0 {
		us := model.UserShop{
			ID:               uuid.New().String(),
			UserID:           user.ID,
			ShopID:           shopID,
			RelationshipType: model.RelationshipTypeFavourite,
		}
		if err := h.db.WithContext(r.Context()).Create(&us).Error; err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to add favourite"))
			return
		}
	}

	full, err := h.buildFullShopResponse(r.Context(), shop)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch shop details"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(full)
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
		Where("user_id = ? AND shop_id = ? AND relationship_type = ?", user.ID, shopID, model.RelationshipTypeFavourite).
		Delete(&model.UserShop{})
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to remove favourite"))
		return
	}

	full, err := h.buildFullShopResponse(r.Context(), shop)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch shop details"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(full)
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

	if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), shopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

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
