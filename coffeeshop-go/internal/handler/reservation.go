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

type ReservationHandler struct {
	db         *gorm.DB
	authorizer *auth.ShopAuthorizer
}

func NewReservationHandler(db *gorm.DB, authorizer *auth.ShopAuthorizer) *ReservationHandler {
	return &ReservationHandler{db: db, authorizer: authorizer}
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

// --- Enriched response types ---

type shopSummary struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Address     string `json:"address"`
	City        string `json:"city"`
	PhoneNumber string `json:"phoneNumber"`
	Email       string `json:"email"`
}

type reservationResponse struct {
	ID                   string        `json:"id"`
	PartySize            int           `json:"partySize"`
	ReservationRequestID *string       `json:"reservationRequestId"`
	User                 *ownerSummary `json:"user"`
	Shop                 *shopSummary  `json:"shop"`
	Table                *tableSummary `json:"table"`
	EventID              *string       `json:"eventId,omitempty"`
	EventName            *string       `json:"eventName,omitempty"`
	EventDate            *string       `json:"eventDate,omitempty"`
}

func (h *ReservationHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	query := h.db.WithContext(r.Context()).
		Table("reservations AS r").
		Select(`r.id, r.party_size, r.reservation_request_id, r.event_id,
			u.id AS user_id, u.name AS user_name, u.username AS user_username,
			s.id AS shop_id, s.name AS shop_name, s.address AS shop_address,
			s.city AS shop_city, s.phone_number AS shop_phone, s.email AS shop_email,
			t.id AS table_id, t.number AS table_number, t.capacity AS table_capacity, t.shop_id AS table_shop_id,
			e.event_name, e.event_date`).
		Joins("LEFT JOIN users AS u ON u.id = r.user_id").
		Joins("LEFT JOIN shop AS s ON s.id = r.shop_id").
		Joins("LEFT JOIN tables AS t ON t.id = r.table_id").
		Joins("LEFT JOIN event AS e ON e.event_id = r.event_id")

	if shopID := r.URL.Query().Get("shopId"); shopID != "" {
		query = query.Where("r.shop_id = ?", shopID)
	}

	rows, err := query.Rows()
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch reservations"))
		return
	}
	defer rows.Close()

	results := []reservationResponse{}
	for rows.Next() {
		var resp reservationResponse
		var userID, userName, userUsername *string
		var shopID, shopName, shopAddr, shopCity, shopPhone, shopEmail *string
		var tableID, tableShopID *string
		var tableNumber, tableCapacity *int
		var eventName, eventDate *string

		if err := rows.Scan(
			&resp.ID, &resp.PartySize, &resp.ReservationRequestID, &resp.EventID,
			&userID, &userName, &userUsername,
			&shopID, &shopName, &shopAddr, &shopCity, &shopPhone, &shopEmail,
			&tableID, &tableNumber, &tableCapacity, &tableShopID,
			&eventName, &eventDate,
		); err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to read reservation data"))
			return
		}
		if userID != nil {
			resp.User = &ownerSummary{ID: *userID, Name: strPtr(userName), Username: strPtr(userUsername)}
		}
		if shopID != nil {
			resp.Shop = &shopSummary{
				ID: *shopID, Name: strPtr(shopName), Address: strPtr(shopAddr),
				City: strPtr(shopCity), PhoneNumber: strPtr(shopPhone), Email: strPtr(shopEmail),
			}
		}
		if tableID != nil {
			resp.Table = &tableSummary{
				ID: *tableID, Number: intPtr(tableNumber), Capacity: intPtr(tableCapacity), ShopID: strPtr(tableShopID),
			}
		}
		resp.EventName = eventName
		resp.EventDate = eventDate
		results = append(results, resp)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}

func (h *ReservationHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	row := h.db.WithContext(r.Context()).
		Table("reservations AS r").
		Select(`r.id, r.party_size, r.reservation_request_id, r.event_id,
			u.id AS user_id, u.name AS user_name, u.username AS user_username,
			s.id AS shop_id, s.name AS shop_name, s.address AS shop_address,
			s.city AS shop_city, s.phone_number AS shop_phone, s.email AS shop_email,
			t.id AS table_id, t.number AS table_number, t.capacity AS table_capacity, t.shop_id AS table_shop_id,
			e.event_name, e.event_date`).
		Joins("LEFT JOIN users AS u ON u.id = r.user_id").
		Joins("LEFT JOIN shop AS s ON s.id = r.shop_id").
		Joins("LEFT JOIN tables AS t ON t.id = r.table_id").
		Joins("LEFT JOIN event AS e ON e.event_id = r.event_id").
		Where("r.id = ?", id).
		Row()

	var resp reservationResponse
	var userID, userName, userUsername *string
	var shopID, shopName, shopAddr, shopCity, shopPhone, shopEmail *string
	var tableID, tableShopID *string
	var tableNumber, tableCapacity *int
	var eventName, eventDate *string

	err := row.Scan(
		&resp.ID, &resp.PartySize, &resp.ReservationRequestID, &resp.EventID,
		&userID, &userName, &userUsername,
		&shopID, &shopName, &shopAddr, &shopCity, &shopPhone, &shopEmail,
		&tableID, &tableNumber, &tableCapacity, &tableShopID,
		&eventName, &eventDate,
	)
	if err != nil {
		apperror.WriteError(w, apperror.NotFound("Reservation not found"))
		return
	}
	if userID != nil {
		resp.User = &ownerSummary{ID: *userID, Name: strPtr(userName), Username: strPtr(userUsername)}
	}
	if shopID != nil {
		resp.Shop = &shopSummary{
			ID: *shopID, Name: strPtr(shopName), Address: strPtr(shopAddr),
			City: strPtr(shopCity), PhoneNumber: strPtr(shopPhone), Email: strPtr(shopEmail),
		}
	}
	if tableID != nil {
		resp.Table = &tableSummary{
			ID: *tableID, Number: intPtr(tableNumber), Capacity: intPtr(tableCapacity), ShopID: strPtr(tableShopID),
		}
	}
	resp.EventName = eventName
	resp.EventDate = eventDate

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func strPtr(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

func intPtr(i *int) int {
	if i == nil {
		return 0
	}
	return *i
}

func (h *ReservationHandler) Create(w http.ResponseWriter, r *http.Request) {
	var req ReservationCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	if req.ShopID != nil && *req.ShopID != "" {
		if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), *req.ShopID); err != nil {
			apperror.WriteError(w, err)
			return
		}
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

	if existing.ShopID != nil && *existing.ShopID != "" {
		if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), *existing.ShopID); err != nil {
			apperror.WriteError(w, err)
			return
		}
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
	var existing model.Reservation
	if err := h.db.WithContext(r.Context()).First(&existing, "id = ?", id).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("Reservation not found"))
		return
	}

	if existing.ShopID != nil && *existing.ShopID != "" {
		if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), *existing.ShopID); err != nil {
			apperror.WriteError(w, err)
			return
		}
	}

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
