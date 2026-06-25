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
	authorizer  *auth.ShopAuthorizer
}

func NewReservationRequestHandler(db *gorm.DB, currentUser *auth.CurrentUserService, authorizer *auth.ShopAuthorizer) *ReservationRequestHandler {
	return &ReservationRequestHandler{db: db, currentUser: currentUser, authorizer: authorizer}
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

// --- Enriched response types ---

type reservationRequestResponse struct {
	ID            string        `json:"id"`
	PartySize     int           `json:"partySize"`
	Status        string        `json:"status"`
	ReservationID *string       `json:"reservationId,omitempty"`
	User          *ownerSummary `json:"user"`
	Shop          *shopSummary  `json:"shop"`
	EventID       *string       `json:"eventId,omitempty"`
	EventName     *string       `json:"eventName,omitempty"`
	EventDate     *string       `json:"eventDate,omitempty"`
}

func (h *ReservationRequestHandler) List(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUser.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	shopID := r.URL.Query().Get("shopId")

	query := h.db.WithContext(r.Context()).
		Table("reservation_request AS rr").
		Select(`rr.id, rr.party_size, rr.status, rr.event_id,
			u.id AS user_id, u.name AS user_name, u.username AS user_username,
			s.id AS shop_id, s.name AS shop_name, s.address AS shop_address,
			s.city AS shop_city, s.phone_number AS shop_phone, s.email AS shop_email,
			e.event_name, e.event_date,
			resv.id AS reservation_id`).
		Joins("LEFT JOIN users AS u ON u.id = rr.user_id").
		Joins("LEFT JOIN shop AS s ON s.id = rr.shop_id").
		Joins("LEFT JOIN event AS e ON e.event_id = rr.event_id").
		Joins("LEFT JOIN reservations AS resv ON resv.reservation_request_id = rr.id")

	if shopID != "" && (h.authorizer.IsAdmin(r.Context()) || h.authorizer.IsShopOwnerOrEmployee(r.Context(), shopID)) {
		query = query.Where("rr.shop_id = ?", shopID)
	} else if h.authorizer.IsAdmin(r.Context()) {
		// admin sees all requests — no additional filter
	} else {
		var ownedShopIDs []string
		h.db.WithContext(r.Context()).
			Model(&model.UserShop{}).
			Where("user_id = ? AND relationship_type = ?", user.ID, model.RelationshipTypeOwner).
			Pluck("shop_id", &ownedShopIDs)

		if len(ownedShopIDs) > 0 {
			query = query.Where("rr.shop_id IN ? OR rr.user_id = ?", ownedShopIDs, user.ID)
		} else {
			query = query.Where("rr.user_id = ?", user.ID)
		}
		if shopID != "" {
			query = query.Where("rr.shop_id = ?", shopID)
		}
	}

	rows, err := query.Rows()
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch reservation requests"))
		return
	}
	defer rows.Close()

	results := []reservationRequestResponse{}
	for rows.Next() {
		var resp reservationRequestResponse
		var userID, userName, userUsername *string
		var shopIDVal, shopName, shopAddr, shopCity, shopPhone, shopEmail *string
		var eventName, eventDate *string

		if err := rows.Scan(
			&resp.ID, &resp.PartySize, &resp.Status, &resp.EventID,
			&userID, &userName, &userUsername,
			&shopIDVal, &shopName, &shopAddr, &shopCity, &shopPhone, &shopEmail,
			&eventName, &eventDate,
			&resp.ReservationID,
		); err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to read reservation request data"))
			return
		}
		if userID != nil {
			resp.User = &ownerSummary{ID: *userID, Name: strPtr(userName), Username: strPtr(userUsername)}
		}
		if shopIDVal != nil {
			resp.Shop = &shopSummary{
				ID: *shopIDVal, Name: strPtr(shopName), Address: strPtr(shopAddr),
				City: strPtr(shopCity), PhoneNumber: strPtr(shopPhone), Email: strPtr(shopEmail),
			}
		}
		resp.EventName = eventName
		resp.EventDate = eventDate
		results = append(results, resp)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}

func (h *ReservationRequestHandler) Create(w http.ResponseWriter, r *http.Request) {
	if _, err := h.currentUser.RequireCurrentUser(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

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

	if existing.ShopID != nil && *existing.ShopID != "" {
		if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), *existing.ShopID); err != nil {
			apperror.WriteError(w, err)
			return
		}
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

	if existing.ShopID != nil && *existing.ShopID != "" {
		if err := h.authorizer.RequireShopOwnerOrEmployeeOrAdmin(r.Context(), *existing.ShopID); err != nil {
			apperror.WriteError(w, err)
			return
		}
	}

	existing.Status = "DENIED"
	if err := h.db.WithContext(r.Context()).Save(&existing).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update reservation request"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(existing)
}
