package handler

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type ReservationHandler struct {
	db *gorm.DB
}

func NewReservationHandler(db *gorm.DB) *ReservationHandler {
	return &ReservationHandler{db: db}
}

type ReservationCreateRequest struct {
	PartySize int     `json:"partySize"`
	UserID    *string `json:"userId"`
	ShopID    *string `json:"shopId"`
	TableID   *string `json:"tableId"`
	EventID   *string `json:"eventId"`
}

type ReservationUpdateRequest struct {
	PartySize int     `json:"partySize"`
	TableID   *string `json:"tableId"`
}

func (h *ReservationHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	var reservations []model.Reservation
	if err := h.db.WithContext(r.Context()).Find(&reservations).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch reservations"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reservations)
}

func (h *ReservationHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var reservation model.Reservation
	if err := h.db.WithContext(r.Context()).First(&reservation, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Reservation not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(reservation)
}

func (h *ReservationHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req ReservationCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	reservation := model.Reservation{
		ID:        uuid.New().String(),
		PartySize: req.PartySize,
		UserID:    req.UserID,
		ShopID:    req.ShopID,
		TableID:   req.TableID,
		EventID:   req.EventID,
	}

	if err := h.db.WithContext(r.Context()).Create(&reservation).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create reservation"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(reservation)
}

func (h *ReservationHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var existing model.Reservation
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Reservation not found"))
		return
	}

	var req ReservationUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	existing.PartySize = req.PartySize
	existing.TableID = req.TableID

	if err := h.db.WithContext(r.Context()).Save(&existing).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update reservation"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(existing)
}

func (h *ReservationHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	result := h.db.WithContext(r.Context()).Delete(&model.Reservation{}, "id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete reservation"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Reservation not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
