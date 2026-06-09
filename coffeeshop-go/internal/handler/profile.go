package handler

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type ProfileHandler struct {
	db          *gorm.DB
	currentUser *auth.CurrentUserService
}

func NewProfileHandler(db *gorm.DB, currentUser *auth.CurrentUserService) *ProfileHandler {
	return &ProfileHandler{db: db, currentUser: currentUser}
}

type profileResponse struct {
	ID             string                  `json:"id"`
	Name           string                  `json:"name"`
	Username       string                  `json:"username"`
	Email          string                  `json:"email"`
	UserType       string                  `json:"userType"`
	Roles          []model.Role            `json:"roles"`
	FavouriteShops []shopSummary           `json:"favouriteShops"`
	Reviews        []profileReviewResponse `json:"reviews"`
	Reservations   []reservationResponse   `json:"reservations"`
}

type profileReviewComment struct {
	ID        string       `json:"id"`
	Body      string       `json:"body"`
	CreatedAt string       `json:"createdAt"`
	User      ownerSummary `json:"user"`
}

type profileReviewResponse struct {
	ID              string                 `json:"id"`
	Title           string                 `json:"title,omitempty"`
	Description     string                 `json:"description"`
	Rating          int                    `json:"rating"`
	ReviewDate      string                 `json:"reviewDate"`
	CommentsEnabled bool                   `json:"commentsEnabled"`
	Comments        []profileReviewComment `json:"comments"`
	User            ownerSummary           `json:"user"`
	Shop            shopSummary            `json:"shop"`
}

func (h *ProfileHandler) GetProfile(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUser.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	ctx := r.Context()

	favouriteShops, err := h.loadFavouriteShops(ctx, user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load favourite shops"))
		return
	}

	roles, err := h.loadRoles(ctx, user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load user roles"))
		return
	}

	reviews, err := h.loadUserReviews(ctx, user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load user reviews"))
		return
	}

	reservations, err := h.loadUserReservations(ctx, user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load user reservations"))
		return
	}

	resp := profileResponse{
		ID:             user.ID,
		Name:           user.Name,
		Username:       user.Username,
		Email:          user.Email,
		UserType:       auth.NormalizeUserType(user.UserType),
		Roles:          roles,
		FavouriteShops: favouriteShops,
		Reviews:        reviews,
		Reservations:   reservations,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *ProfileHandler) loadFavouriteShops(ctx context.Context, userID string) ([]shopSummary, error) {
	rows, err := h.db.WithContext(ctx).
		Table("user_shop AS us").
		Select(`s.id, s.name, s.address, s.city, s.phone_number, s.email`).
		Joins("JOIN shop AS s ON s.id = us.shop_id").
		Where("us.user_id = ? AND us.relationship_type = ?", userID, model.RelationshipTypeFavourite).
		Order("s.name ASC").
		Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	shops := []shopSummary{}
	for rows.Next() {
		var s shopSummary
		if err := rows.Scan(&s.ID, &s.Name, &s.Address, &s.City, &s.PhoneNumber, &s.Email); err != nil {
			return nil, err
		}
		shops = append(shops, s)
	}
	return shops, nil
}

func (h *ProfileHandler) loadRoles(ctx context.Context, userID string) ([]model.Role, error) {
	var roles []model.Role
	err := h.db.WithContext(ctx).
		Table("roles").
		Select("roles.id, roles.name, roles.type").
		Joins("JOIN user_role ON user_role.role_id = roles.id").
		Where("user_role.user_id = ?", userID).
		Order("roles.name ASC").
		Find(&roles).Error
	if err != nil {
		return nil, err
	}
	if roles == nil {
		roles = []model.Role{}
	}
	return roles, nil
}

func (h *ProfileHandler) loadUserReviews(ctx context.Context, userID string) ([]profileReviewResponse, error) {
	rows, err := h.db.WithContext(ctx).
		Table("review AS rv").
		Select(`rv.id, rv.title, rv.description, rv.rating, rv.review_date, rv.comments_enabled,
			u.id AS user_id, u.name AS user_name, u.username AS user_username,
			s.id AS shop_id, s.name AS shop_name, s.address AS shop_address,
			s.city AS shop_city, s.phone_number AS shop_phone, s.email AS shop_email`).
		Joins("LEFT JOIN users AS u ON u.id = rv.user_id").
		Joins("LEFT JOIN shop AS s ON s.id = rv.shop_id").
		Where("rv.user_id = ?", userID).
		Order("rv.review_date DESC").
		Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	reviews := []profileReviewResponse{}
	reviewIDs := []string{}
	for rows.Next() {
		var resp profileReviewResponse
		var title *string
		var userIDVal, userName, userUsername *string
		var shopID, shopName, shopAddr, shopCity, shopPhone, shopEmail *string

		if err := rows.Scan(
			&resp.ID, &title, &resp.Description, &resp.Rating, &resp.ReviewDate, &resp.CommentsEnabled,
			&userIDVal, &userName, &userUsername,
			&shopID, &shopName, &shopAddr, &shopCity, &shopPhone, &shopEmail,
		); err != nil {
			return nil, err
		}
		if title != nil {
			resp.Title = *title
		}
		if userIDVal != nil {
			resp.User = ownerSummary{ID: *userIDVal, Name: strPtr(userName), Username: strPtr(userUsername)}
		}
		if shopID != nil {
			resp.Shop = shopSummary{
				ID: *shopID, Name: strPtr(shopName), Address: strPtr(shopAddr),
				City: strPtr(shopCity), PhoneNumber: strPtr(shopPhone), Email: strPtr(shopEmail),
			}
		}
		resp.Comments = []profileReviewComment{}
		reviews = append(reviews, resp)
		reviewIDs = append(reviewIDs, resp.ID)
	}

	if len(reviewIDs) == 0 {
		return reviews, nil
	}

	commentRows, err := h.db.WithContext(ctx).
		Table("review_comment AS rc").
		Select(`rc.id, rc.body, rc.created_at, rc.review_id,
			u.id AS user_id, u.name AS user_name, u.username AS user_username`).
		Joins("LEFT JOIN users AS u ON u.id = rc.user_id").
		Where("rc.review_id IN ?", reviewIDs).
		Order("rc.created_at ASC").
		Rows()
	if err != nil {
		return nil, err
	}
	defer commentRows.Close()

	commentsByReview := map[string][]profileReviewComment{}
	for commentRows.Next() {
		var comment profileReviewComment
		var reviewID string
		var userIDVal, userName, userUsername *string
		if err := commentRows.Scan(
			&comment.ID, &comment.Body, &comment.CreatedAt, &reviewID,
			&userIDVal, &userName, &userUsername,
		); err != nil {
			return nil, err
		}
		if userIDVal != nil {
			comment.User = ownerSummary{ID: *userIDVal, Name: strPtr(userName), Username: strPtr(userUsername)}
		}
		commentsByReview[reviewID] = append(commentsByReview[reviewID], comment)
	}

	for i := range reviews {
		if comments, ok := commentsByReview[reviews[i].ID]; ok {
			reviews[i].Comments = comments
		}
	}

	return reviews, nil
}

func (h *ProfileHandler) loadUserReservations(ctx context.Context, userID string) ([]reservationResponse, error) {
	rows, err := h.db.WithContext(ctx).
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
		Where("r.user_id = ?", userID).
		Order("e.event_date DESC, r.id DESC").
		Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	results := []reservationResponse{}
	for rows.Next() {
		var resp reservationResponse
		var userIDVal, userName, userUsername *string
		var shopID, shopName, shopAddr, shopCity, shopPhone, shopEmail *string
		var tableID, tableShopID *string
		var tableNumber, tableCapacity *int
		var eventName, eventDate *string

		if err := rows.Scan(
			&resp.ID, &resp.PartySize, &resp.ReservationRequestID, &resp.EventID,
			&userIDVal, &userName, &userUsername,
			&shopID, &shopName, &shopAddr, &shopCity, &shopPhone, &shopEmail,
			&tableID, &tableNumber, &tableCapacity, &tableShopID,
			&eventName, &eventDate,
		); err != nil {
			return nil, err
		}
		if userIDVal != nil {
			resp.User = &ownerSummary{ID: *userIDVal, Name: strPtr(userName), Username: strPtr(userUsername)}
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
	return results, nil
}
