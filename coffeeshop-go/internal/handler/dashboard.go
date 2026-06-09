package handler

import (
	"context"
	"encoding/json"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type DashboardHandler struct {
	db             *gorm.DB
	currentUserSvc *auth.CurrentUserService
	authorizer     *auth.ShopAuthorizer
}

func NewDashboardHandler(db *gorm.DB, currentUserSvc *auth.CurrentUserService, authorizer *auth.ShopAuthorizer) *DashboardHandler {
	return &DashboardHandler{db: db, currentUserSvc: currentUserSvc, authorizer: authorizer}
}

type dashboardActivityResponse struct {
	Aggregate       dashboardAggregate       `json:"aggregate"`
	Activities      []dashboardActivityItem  `json:"activities"`
	TopShops        []topShopItem            `json:"topShops"`
	UpcomingEvents  []upcomingEventItem      `json:"upcomingEvents"`
	PersonalSummary dashboardPersonalSummary `json:"personalSummary"`
	Notifications   []dashboardNotification  `json:"notifications"`
}

type dashboardAggregate struct {
	ShopCount     int      `json:"shopCount"`
	ReviewCount   int      `json:"reviewCount"`
	AverageRating *float64 `json:"averageRating"`
	EventCount    int      `json:"eventCount"`
	MemberCount   int      `json:"memberCount"`
}

type dashboardActivityItem struct {
	Type      string  `json:"type"`
	Timestamp string  `json:"timestamp"`
	ShopID    string  `json:"shopId"`
	ShopName  string  `json:"shopName"`
	Title     string  `json:"title"`
	Body      string  `json:"body"`
	ActorName *string `json:"actorName"`
	Rating    *int    `json:"rating"`
}

type topShopItem struct {
	ShopID        string   `json:"shopId"`
	ShopName      string   `json:"shopName"`
	City          string   `json:"city"`
	AverageRating *float64 `json:"averageRating"`
	ReviewCount   int      `json:"reviewCount"`
}

type upcomingEventItem struct {
	EventID   string `json:"eventId"`
	EventName string `json:"eventName"`
	EventDate string `json:"eventDate"`
	ShopID    string `json:"shopId"`
	ShopName  string `json:"shopName"`
}

type dashboardPersonalSummary struct {
	FavouriteShops int `json:"favouriteShops"`
	Reservations   int `json:"reservations"`
	ReviewsWritten int `json:"reviewsWritten"`
}

type dashboardNotification struct {
	Type    string `json:"type"`
	Message string `json:"message"`
	Count   int    `json:"count"`
	Link    string `json:"link"`
}

func emptyDashboardResponse() dashboardActivityResponse {
	return dashboardActivityResponse{
		Aggregate:       dashboardAggregate{},
		Activities:      []dashboardActivityItem{},
		TopShops:        []topShopItem{},
		UpcomingEvents:  []upcomingEventItem{},
		PersonalSummary: dashboardPersonalSummary{},
		Notifications:   []dashboardNotification{},
	}
}

func (h *DashboardHandler) GetActivity(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUserSvc.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	scopeShopIDs := h.resolveShopScope(r.Context())
	userType := auth.NormalizeUserType(user.UserType)

	resp := h.buildResponse(r.Context(), user.ID, userType, scopeShopIDs)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *DashboardHandler) resolveShopScope(ctx context.Context) []string {
	var ids []string
	h.db.WithContext(ctx).Model(&model.Shop{}).Pluck("id", &ids)
	return ids
}

func (h *DashboardHandler) buildResponse(ctx context.Context, userID, userType string, shopIDs []string) dashboardActivityResponse {
	personalSummary := h.computePersonalSummary(ctx, userID)

	if len(shopIDs) == 0 {
		resp := emptyDashboardResponse()
		resp.PersonalSummary = personalSummary
		return resp
	}

	agg := h.computeAggregate(ctx, shopIDs)
	activities := h.collectActivities(ctx, shopIDs)

	var notifications []dashboardNotification
	if userType != "CUSTOMER" {
		notifications = h.computeNotifications(ctx, shopIDs)
	} else {
		notifications = []dashboardNotification{}
	}

	return dashboardActivityResponse{
		Aggregate:       agg,
		Activities:      activities,
		TopShops:        h.computeTopShops(ctx, shopIDs),
		UpcomingEvents:  h.computeUpcomingEvents(ctx, shopIDs),
		PersonalSummary: personalSummary,
		Notifications:   notifications,
	}
}

func (h *DashboardHandler) computeAggregate(ctx context.Context, shopIDs []string) dashboardAggregate {
	agg := dashboardAggregate{
		ShopCount: len(shopIDs),
	}

	var reviewCount int64
	h.db.WithContext(ctx).Model(&model.Review{}).
		Where("shop_id IN ?", shopIDs).
		Count(&reviewCount)
	agg.ReviewCount = int(reviewCount)

	var avgRating *float64
	h.db.WithContext(ctx).Model(&model.Review{}).
		Where("shop_id IN ?", shopIDs).
		Select("COALESCE(AVG(CAST(rating AS FLOAT)), 0)").
		Scan(&avgRating)
	if avgRating != nil && *avgRating == 0 {
		avgRating = nil
	}
	agg.AverageRating = avgRating

	var eventCount int64
	h.db.WithContext(ctx).Model(&model.Event{}).
		Where("shop_id IN ?", shopIDs).
		Count(&eventCount)
	agg.EventCount = int(eventCount)

	var memberCount int64
	h.db.WithContext(ctx).Model(&model.UserShop{}).
		Where("shop_id IN ? AND relationship_type = ?", shopIDs, model.RelationshipTypeFavourite).
		Count(&memberCount)
	agg.MemberCount = int(memberCount)

	return agg
}

func (h *DashboardHandler) computeTopShops(ctx context.Context, shopIDs []string) []topShopItem {
	type shopRatingRow struct {
		ShopID        string
		ShopName      string
		City          string
		AverageRating *float64
		ReviewCount   int64
	}

	var rows []shopRatingRow
	h.db.WithContext(ctx).
		Table("shop AS s").
		Select(`s.id AS shop_id, s.name AS shop_name, s.city AS city,
			AVG(CAST(r.rating AS FLOAT)) AS average_rating,
			COUNT(r.id) AS review_count`).
		Joins("LEFT JOIN review AS r ON r.shop_id = s.id").
		Where("s.id IN ?", shopIDs).
		Group("s.id, s.name, s.city").
		Having("COUNT(r.id) > 0").
		Order("average_rating DESC, review_count DESC").
		Limit(5).
		Scan(&rows)

	items := make([]topShopItem, len(rows))
	for i, row := range rows {
		items[i] = topShopItem{
			ShopID:        row.ShopID,
			ShopName:      row.ShopName,
			City:          row.City,
			AverageRating: row.AverageRating,
			ReviewCount:   int(row.ReviewCount),
		}
	}
	return items
}

func (h *DashboardHandler) computeUpcomingEvents(ctx context.Context, shopIDs []string) []upcomingEventItem {
	today := time.Now().Format("2006-01-02")

	var events []model.Event
	h.db.WithContext(ctx).
		Where("shop_id IN ? AND event_date >= ?", shopIDs, today).
		Order("event_date ASC").
		Limit(10).
		Find(&events)

	shopNames := h.loadShopNames(ctx, shopIDs)
	items := make([]upcomingEventItem, len(events))
	for i, evt := range events {
		shopID := ""
		if evt.ShopID != nil {
			shopID = *evt.ShopID
		}
		items[i] = upcomingEventItem{
			EventID:   evt.EventID,
			EventName: evt.EventName,
			EventDate: evt.EventDate,
			ShopID:    shopID,
			ShopName:  shopNames[shopID],
		}
	}
	return items
}

func (h *DashboardHandler) computePersonalSummary(ctx context.Context, userID string) dashboardPersonalSummary {
	var summary dashboardPersonalSummary

	var favouriteCount int64
	h.db.WithContext(ctx).Model(&model.UserShop{}).
		Where("user_id = ? AND relationship_type = ?", userID, model.RelationshipTypeFavourite).
		Count(&favouriteCount)
	summary.FavouriteShops = int(favouriteCount)

	var reservationCount int64
	h.db.WithContext(ctx).Model(&model.Reservation{}).
		Where("user_id = ?", userID).
		Count(&reservationCount)
	summary.Reservations = int(reservationCount)

	var reviewCount int64
	h.db.WithContext(ctx).Model(&model.Review{}).
		Where("user_id = ?", userID).
		Count(&reviewCount)
	summary.ReviewsWritten = int(reviewCount)

	return summary
}

func (h *DashboardHandler) computeNotifications(ctx context.Context, shopIDs []string) []dashboardNotification {
	var notifications []dashboardNotification

	var pendingCount int64
	h.db.WithContext(ctx).Model(&model.ReservationRequest{}).
		Where("shop_id IN ? AND status = ?", shopIDs, "PENDING").
		Count(&pendingCount)
	if pendingCount > 0 {
		notifications = append(notifications, dashboardNotification{
			Type:    "pending_requests",
			Message: "Reservation requests awaiting approval",
			Count:   int(pendingCount),
			Link:    "/reservations",
		})
	}

	thirtyDaysAgo := time.Now().AddDate(0, 0, -30).Format("2006-01-02")
	var recentReviewCount int64
	h.db.WithContext(ctx).Model(&model.Review{}).
		Where("shop_id IN ? AND review_date >= ?", shopIDs, thirtyDaysAgo).
		Count(&recentReviewCount)
	if recentReviewCount > 0 {
		notifications = append(notifications, dashboardNotification{
			Type:    "new_reviews",
			Message: "New reviews in the last 30 days",
			Count:   int(recentReviewCount),
			Link:    "/shops",
		})
	}

	if notifications == nil {
		return []dashboardNotification{}
	}
	return notifications
}

func (h *DashboardHandler) collectActivities(ctx context.Context, shopIDs []string) []dashboardActivityItem {
	now := time.Now()
	thirtyDaysAgo := now.AddDate(0, 0, -30).Format("2006-01-02")
	today := now.Format("2006-01-02")

	var items []dashboardActivityItem

	shopNames := h.loadShopNames(ctx, shopIDs)

	var reviews []model.Review
	h.db.WithContext(ctx).
		Where("shop_id IN ? AND review_date >= ?", shopIDs, thirtyDaysAgo).
		Order("review_date DESC").
		Limit(50).
		Find(&reviews)

	for _, rev := range reviews {
		shopID := ""
		if rev.ShopID != nil {
			shopID = *rev.ShopID
		}
		rating := rev.Rating
		actorName := h.loadUserName(ctx, rev.UserID)
		items = append(items, dashboardActivityItem{
			Type:      "review",
			Timestamp: rev.ReviewDate,
			ShopID:    shopID,
			ShopName:  shopNames[shopID],
			Title:     rev.Title,
			Body:      truncate(rev.Description, 200),
			ActorName: actorName,
			Rating:    &rating,
		})
	}

	var events []model.Event
	h.db.WithContext(ctx).
		Where("shop_id IN ? AND event_date >= ?", shopIDs, today).
		Order("event_date ASC").
		Limit(50).
		Find(&events)

	for _, evt := range events {
		shopID := ""
		if evt.ShopID != nil {
			shopID = *evt.ShopID
		}
		items = append(items, dashboardActivityItem{
			Type:      "event",
			Timestamp: evt.EventDate,
			ShopID:    shopID,
			ShopName:  shopNames[shopID],
			Title:     evt.EventName,
			Body:      truncate(evt.Description, 200),
		})
	}

	var posts []model.CommunityPost
	h.db.WithContext(ctx).
		Where("shop_id IN ? AND created_at >= ?", shopIDs, thirtyDaysAgo).
		Order("created_at DESC").
		Limit(50).
		Find(&posts)

	for _, post := range posts {
		shopID := ""
		if post.ShopID != nil {
			shopID = *post.ShopID
		}
		actorName := h.loadUserName(ctx, post.AuthorID)
		items = append(items, dashboardActivityItem{
			Type:      "community_post",
			Timestamp: post.CreatedAt,
			ShopID:    shopID,
			ShopName:  shopNames[shopID],
			Title:     postTitle(post),
			Body:      truncate(post.Body, 200),
			ActorName: actorName,
		})
	}

	todayStr := time.Now().Format("2006-01-02")
	sort.Slice(items, func(i, j int) bool {
		iIsUpcoming := items[i].Type == "event" && items[i].Timestamp >= todayStr
		jIsUpcoming := items[j].Type == "event" && items[j].Timestamp >= todayStr

		if iIsUpcoming && jIsUpcoming {
			return items[i].Timestamp < items[j].Timestamp
		}
		if iIsUpcoming {
			return true
		}
		if jIsUpcoming {
			return false
		}
		return items[i].Timestamp > items[j].Timestamp
	})

	if len(items) > 50 {
		items = items[:50]
	}

	return items
}

func (h *DashboardHandler) loadShopNames(ctx context.Context, shopIDs []string) map[string]string {
	type shopName struct {
		ID   string
		Name string
	}
	var shops []shopName
	h.db.WithContext(ctx).Model(&model.Shop{}).
		Where("id IN ?", shopIDs).
		Select("id, name").
		Find(&shops)
	m := make(map[string]string, len(shops))
	for _, s := range shops {
		m[s.ID] = s.Name
	}
	return m
}

func (h *DashboardHandler) loadUserName(ctx context.Context, userID *string) *string {
	if userID == nil || *userID == "" {
		return nil
	}
	var user auth.User
	if err := h.db.WithContext(ctx).Select("name").First(&user, "id = ?", *userID).Error; err != nil {
		return nil
	}
	return &user.Name
}

func truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return strings.TrimSpace(s[:maxLen]) + "..."
}

func postTitle(post model.CommunityPost) string {
	if post.Type == "ANNOUNCEMENT" {
		return "New announcement"
	}
	return "New post"
}
