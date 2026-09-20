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

type TableHandler struct {
	db             *gorm.DB
	currentUserSvc *auth.CurrentUserService
	authorizer     *auth.ShopAuthorizer
	entitlements   *subscription.EntitlementService
}

func NewTableHandler(db *gorm.DB, currentUserSvc *auth.CurrentUserService, authorizer *auth.ShopAuthorizer, entitlements *subscription.EntitlementService) *TableHandler {
	return &TableHandler{db: db, currentUserSvc: currentUserSvc, authorizer: authorizer, entitlements: entitlements}
}

func (h *TableHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	var tables []model.Table
	if err := h.db.WithContext(r.Context()).Find(&tables).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch tables"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(tables)
}

func (h *TableHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var table model.Table
	if err := h.db.WithContext(r.Context()).First(&table, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Table not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(table)
}

func (h *TableHandler) Create(w http.ResponseWriter, r *http.Request) {
	if _, err := h.currentUserSvc.RequireCurrentUser(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req model.Table
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), req.ShopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	if !h.requireTableLimit(w, r, req.ShopID) {
		return
	}

	req.ID = uuid.New().String()
	if err := h.db.WithContext(r.Context()).Create(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create table"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(req)
}

func (h *TableHandler) Update(w http.ResponseWriter, r *http.Request) {
	if _, err := h.currentUserSvc.RequireCurrentUser(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

	id := chi.URLParam(r, "id")
	var existing model.Table
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Table not found"))
		return
	}

	if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), existing.ShopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req model.Table
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	req.ID = id
	if err := h.db.WithContext(r.Context()).Save(&req).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update table"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(req)
}

func (h *TableHandler) Delete(w http.ResponseWriter, r *http.Request) {
	if _, err := h.currentUserSvc.RequireCurrentUser(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

	id := chi.URLParam(r, "id")
	var existing model.Table
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Table not found"))
		return
	}

	if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), existing.ShopID); err != nil {
		apperror.WriteError(w, err)
		return
	}

	result := h.db.WithContext(r.Context()).Delete(&model.Table{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete table"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Table not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *TableHandler) requireTableLimit(w http.ResponseWriter, r *http.Request, shopID string) bool {
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
		apperror.WriteError(w, apperror.BadRequest("Invalid shop ID"))
		return false
	}

	return subscription.RequireLimit(
		w, r, h.entitlements,
		userID, shopUUID,
		subscription.LimitTables,
		h.authorizer.IsAdmin(r.Context()),
	)
}
