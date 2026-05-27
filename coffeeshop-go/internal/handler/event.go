package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type EventHandler struct {
	db *gorm.DB
}

func NewEventHandler(db *gorm.DB) *EventHandler {
	return &EventHandler{db: db}
}

type eventCreateRequest struct {
	EventName   string  `json:"eventName"`
	EventDate   string  `json:"eventDate"`
	Description string  `json:"description"`
	ShopID      *string `json:"shopId"`
}

type eventUpdateRequest struct {
	EventName   string `json:"eventName"`
	EventDate   string `json:"eventDate"`
	Description string `json:"description"`
}

func parseDateParam(value, paramName string) (string, error) {
	if value == "" {
		return "", nil
	}
	_, err := time.Parse("2006-01-02", strings.TrimSpace(value))
	if err != nil {
		return "", fmt.Errorf("Invalid %s format, expected yyyy-MM-dd", paramName)
	}
	return strings.TrimSpace(value), nil
}

// GetAll handles GET /event — returns events for a shop (flat list) or paginated search.
func (h *EventHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	shopID := r.URL.Query().Get("shopId")
	if shopID != "" {
		h.listByShop(w, r, shopID)
		return
	}
	h.paginatedSearch(w, r)
}

func (h *EventHandler) listByShop(w http.ResponseWriter, r *http.Request, shopID string) {
	var events []model.Event
	if err := h.db.WithContext(r.Context()).Where("shop_id = ?", shopID).Find(&events).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch events"))
		return
	}
	if events == nil {
		events = []model.Event{}
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(events)
}

func (h *EventHandler) paginatedSearch(w http.ResponseWriter, r *http.Request) {
	pageParam := r.URL.Query().Get("page")
	page := 0
	if pageParam != "" {
		p, err := strconv.Atoi(pageParam)
		if err != nil || p < 0 {
			apperror.WriteError(w, apperror.BadRequest("Invalid page parameter"))
			return
		}
		page = p
	}

	sizeParam := r.URL.Query().Get("size")
	size := 10
	if sizeParam != "" {
		s, err := strconv.Atoi(sizeParam)
		if err != nil || s < 1 {
			apperror.WriteError(w, apperror.BadRequest("Invalid size parameter"))
			return
		}
		size = s
	}

	dateFrom, err := parseDateParam(r.URL.Query().Get("dateFrom"), "dateFrom")
	if err != nil {
		apperror.WriteError(w, apperror.BadRequest(err.Error()))
		return
	}
	dateTo, err := parseDateParam(r.URL.Query().Get("dateTo"), "dateTo")
	if err != nil {
		apperror.WriteError(w, apperror.BadRequest(err.Error()))
		return
	}

	if dateFrom != "" && dateTo != "" && dateFrom > dateTo {
		apperror.WriteError(w, apperror.BadRequest("dateFrom must not be after dateTo"))
		return
	}

	q := strings.TrimSpace(r.URL.Query().Get("q"))
	query := h.db.WithContext(r.Context()).Model(&model.Event{})

	if q != "" {
		like := "%" + strings.ToLower(q) + "%"
		query = query.Where("LOWER(event_name) LIKE ?", like)
	}
	if dateFrom != "" {
		query = query.Where("event_date >= ?", dateFrom)
	}
	if dateTo != "" {
		query = query.Where("event_date <= ?", dateTo)
	}

	var total int64
	if err := query.Count(&total).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to count events"))
		return
	}

	var events []model.Event
	offset := page * size
	if err := query.Order("event_date DESC").Offset(offset).Limit(size).Find(&events).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch events"))
		return
	}

	resp := model.NewPageResponse(events, page, size, total)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// GetByID handles GET /event/{eventId}.
func (h *EventHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "eventId")
	var event model.Event
	if err := h.db.WithContext(r.Context()).First(&event, "event_id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Event not found"))
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(event)
}

// Create handles POST /event.
func (h *EventHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req eventCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	event := model.Event{
		EventID:     uuid.New().String(),
		EventName:   req.EventName,
		EventDate:   req.EventDate,
		Description: req.Description,
		ShopID:      req.ShopID,
	}

	if err := h.db.WithContext(r.Context()).Create(&event).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to create event"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(event)
}

// Update handles PUT /event/{eventId}.
func (h *EventHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "eventId")
	var existing model.Event
	if err := h.db.WithContext(r.Context()).First(&existing, "event_id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Event not found"))
		return
	}

	var req eventUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	existing.EventName = req.EventName
	existing.EventDate = req.EventDate
	existing.Description = req.Description

	if err := h.db.WithContext(r.Context()).Save(&existing).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update event"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(existing)
}

// Delete handles DELETE /event/{eventId}.
func (h *EventHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "eventId")
	result := h.db.WithContext(r.Context()).Delete(&model.Event{}, "event_id = ?", id)
	if result.Error != nil {
		apperror.WriteError(w, apperror.Internal("Failed to delete event"))
		return
	}
	if result.RowsAffected == 0 {
		apperror.WriteError(w, apperror.NotFound("Event not found"))
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
