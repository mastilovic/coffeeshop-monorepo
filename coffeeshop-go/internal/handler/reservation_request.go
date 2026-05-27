package handler

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type ReservationRequestHandler struct {
	db          *gorm.DB
	currentUser *auth.CurrentUserService
}

func NewReservationRequestHandler(db *gorm.DB, currentUser *auth.CurrentUserService) *ReservationRequestHandler {
	return &ReservationRequestHandler{db: db, currentUser: currentUser}
}

type ReservationRequestCreateRequest struct {
	UserID    *string `json:"userId"`
	ShopID    *string `json:"shopId"`
	EventID   *string `json:"eventId"`
	PartySize int     `json:"partySize"`
}

type ReservationAcceptRequest struct {
	TableID *string `json:"tableId"`
}

func (h *ReservationRequestHandler) List(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUser.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	query := h.db.WithContext(r.Context()).Where("user_id = ?", user.ID)

	if shopID := r.URL.Query().Get("shopId"); shopID != "" {
		query = query.Where("shop_id = ?", shopID)
	}

	var requests []model.ReservationRequest
	if err := query.Find(&requests).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch reservation requests"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(requests)
}

func (h *ReservationRequestHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req ReservationRequestCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	reservationReq := model.ReservationRequest{
		ID:        uuid.New().String(),
		PartySize: req.PartySize,
		Status:    "PENDING",
		UserID:    req.UserID,
		ShopID:    req.ShopID,
		EventID:   req.EventID,
	}

	if err := h.db.WithContext(r.Context()).Create(&reservationReq).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create reservation request"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(reservationReq)
}

func (h *ReservationRequestHandler) Accept(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	var existing model.ReservationRequest
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Reservation request not found"))
		return
	}

	var req ReservationAcceptRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	existing.Status = "ACCEPTED"
	if err := h.db.WithContext(r.Context()).Save(&existing).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update reservation request"))
		return
	}

	reservation := model.Reservation{
		ID:                   uuid.New().String(),
		PartySize:            existing.PartySize,
		UserID:               existing.UserID,
		ShopID:               existing.ShopID,
		TableID:              req.TableID,
		EventID:              existing.EventID,
		ReservationRequestID: &existing.ID,
	}
	if err := h.db.WithContext(r.Context()).Create(&reservation).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create reservation"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(existing)
}

func (h *ReservationRequestHandler) Deny(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	var existing model.ReservationRequest
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Reservation request not found"))
		return
	}

	existing.Status = "DENIED"
	if err := h.db.WithContext(r.Context()).Save(&existing).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update reservation request"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(existing)
}
