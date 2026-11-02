package handler

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/repository"
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
	"gorm.io/gorm"
)

type SubscriptionAdminHandler struct {
	db          *gorm.DB
	currentUser *auth.CurrentUserService
	authorizer  *auth.ShopAuthorizer
	subRepo     *repository.SubscriptionRepository
	pricing     *subscription.PricingService
}

func NewSubscriptionAdminHandler(
	db *gorm.DB,
	currentUser *auth.CurrentUserService,
	authorizer *auth.ShopAuthorizer,
	subRepo *repository.SubscriptionRepository,
	pricing *subscription.PricingService,
) *SubscriptionAdminHandler {
	return &SubscriptionAdminHandler{
		db:          db,
		currentUser: currentUser,
		authorizer:  authorizer,
		subRepo:     subRepo,
		pricing:     pricing,
	}
}

type adminTierUpdate struct {
	Tier                  string `json:"tier"`
	DisplayName           string `json:"displayName,omitempty"`
	BasePriceMonthlyCents int    `json:"basePriceMonthlyCents"`
	ExtraShopPriceCents   *int   `json:"extraShopPriceCents"`
	AnnualMonthsCharged   int    `json:"annualMonthsCharged"`
	IsActive              bool   `json:"isActive"`
}

type updateTiersRequest struct {
	Tiers []adminTierUpdate `json:"tiers"`
}

type adminFeatureUpdate struct {
	FeatureKey         string  `json:"featureKey"`
	MonthlyPriceCents  int     `json:"monthlyPriceCents"`
	LimitType          *string `json:"limitType"`
	LimitValue         *int    `json:"limitValue"`
	IsSelectableCustom bool    `json:"isSelectableCustom"`
	IsActive           bool    `json:"isActive"`
}

type updateFeaturesRequest struct {
	Features []adminFeatureUpdate `json:"features"`
}

type ownerSubscriptionListItem struct {
	ID                       string  `json:"id"`
	Name                     string  `json:"name"`
	Username                 string  `json:"username"`
	Email                    string  `json:"email"`
	PlanMode                 *string `json:"planMode,omitempty"`
	PlanTier                 *string `json:"planTier,omitempty"`
	Status                   *string `json:"status,omitempty"`
	ShopsUsed                int     `json:"shopsUsed"`
	LockedMonthlyAmountCents *int    `json:"lockedMonthlyAmountCents,omitempty"`
}

type adminOwnerOverrideRequest struct {
	PlanMode        string   `json:"planMode"`
	PlanTier        *string  `json:"planTier"`
	Features        []string `json:"features"`
	BillingInterval string   `json:"billingInterval"`
	Status          string   `json:"status"`
}

func (h *SubscriptionAdminHandler) requireAdmin(w http.ResponseWriter, r *http.Request) bool {
	if _, err := h.currentUser.RequireCurrentUser(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return false
	}
	if err := h.authorizer.RequireAdmin(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return false
	}
	return true
}

func (h *SubscriptionAdminHandler) GetTiers(w http.ResponseWriter, r *http.Request) {
	if !h.requireAdmin(w, r) {
		return
	}

	tiers, err := h.subRepo.ListPlanTiers(r.Context())
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load plan tiers"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(tiers)
}

func (h *SubscriptionAdminHandler) UpdateTiers(w http.ResponseWriter, r *http.Request) {
	if !h.requireAdmin(w, r) {
		return
	}

	var req updateTiersRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	if len(req.Tiers) == 0 {
		apperror.WriteError(w, apperror.BadRequest("tiers is required"))
		return
	}

	ctx := r.Context()
	existing, err := h.subRepo.ListPlanTiers(ctx)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load plan tiers"))
		return
	}
	byTier := make(map[model.PlanTier]model.PlanTierCatalog, len(existing))
	for _, tier := range existing {
		byTier[tier.Tier] = tier
	}

	updated := make([]model.PlanTierCatalog, 0, len(req.Tiers))
	for _, item := range req.Tiers {
		parsed := model.PlanTier(item.Tier)
		switch parsed {
		case model.PlanTierStarter, model.PlanTierGrowth, model.PlanTierPro:
		default:
			apperror.WriteError(w, apperror.BadRequest("unknown plan tier: "+item.Tier))
			return
		}

		tier, ok := byTier[parsed]
		if !ok {
			apperror.WriteError(w, apperror.NotFound("Plan tier not found: "+item.Tier))
			return
		}

		if item.DisplayName != "" {
			tier.DisplayName = item.DisplayName
		}
		tier.BasePriceMonthlyCents = item.BasePriceMonthlyCents
		tier.ExtraShopPriceCents = item.ExtraShopPriceCents
		if item.AnnualMonthsCharged > 0 {
			tier.AnnualMonthsCharged = item.AnnualMonthsCharged
		}
		tier.IsActive = item.IsActive

		if err := h.subRepo.UpdatePlanTier(ctx, &tier); err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to update plan tier"))
			return
		}
		updated = append(updated, tier)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(updated)
}

func (h *SubscriptionAdminHandler) GetFeatures(w http.ResponseWriter, r *http.Request) {
	if !h.requireAdmin(w, r) {
		return
	}

	features, err := h.subRepo.ListFeatures(r.Context())
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load features"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(features)
}

func (h *SubscriptionAdminHandler) UpdateFeatures(w http.ResponseWriter, r *http.Request) {
	if !h.requireAdmin(w, r) {
		return
	}

	var req updateFeaturesRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}
	if len(req.Features) == 0 {
		apperror.WriteError(w, apperror.BadRequest("features is required"))
		return
	}

	ctx := r.Context()
	existing, err := h.subRepo.ListFeatures(ctx)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load features"))
		return
	}
	byKey := make(map[string]model.FeatureCatalog, len(existing))
	for _, feature := range existing {
		byKey[feature.FeatureKey] = feature
	}

	updated := make([]model.FeatureCatalog, 0, len(req.Features))
	for _, item := range req.Features {
		if item.FeatureKey == "" {
			apperror.WriteError(w, apperror.BadRequest("featureKey is required"))
			return
		}

		feature, ok := byKey[item.FeatureKey]
		if !ok {
			apperror.WriteError(w, apperror.NotFound("Feature not found: "+item.FeatureKey))
			return
		}

		feature.MonthlyPriceCents = item.MonthlyPriceCents
		feature.LimitType = item.LimitType
		feature.LimitValue = item.LimitValue
		feature.IsSelectableCustom = item.IsSelectableCustom
		feature.IsActive = item.IsActive

		if err := h.subRepo.UpdateFeature(ctx, &feature); err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to update feature"))
			return
		}
		updated = append(updated, feature)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(updated)
}

func (h *SubscriptionAdminHandler) ListOwners(w http.ResponseWriter, r *http.Request) {
	if !h.requireAdmin(w, r) {
		return
	}

	pageStr := r.URL.Query().Get("page")
	if pageStr == "" {
		apperror.WriteError(w, apperror.BadRequest("page query parameter is required"))
		return
	}
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 0 {
		apperror.WriteError(w, apperror.BadRequest("Invalid page parameter"))
		return
	}

	size := 20
	if sizeStr := r.URL.Query().Get("size"); sizeStr != "" {
		if s, err := strconv.Atoi(sizeStr); err == nil && s > 0 {
			size = s
		}
	}

	q := strings.TrimSpace(r.URL.Query().Get("q"))
	ctx := r.Context()

	query := h.db.WithContext(ctx).Model(&auth.User{}).Where("user_type = ?", "SHOP_OWNER")
	if q != "" {
		pattern := "%" + strings.ToLower(q) + "%"
		query = query.Where("LOWER(name) LIKE ? OR LOWER(email) LIKE ?", pattern, pattern)
	}

	var total int64
	if err := query.Count(&total).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to count owners"))
		return
	}

	var users []auth.User
	if err := query.Order("name ASC").Offset(page * size).Limit(size).Find(&users).Error; err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to fetch owners"))
		return
	}

	items := make([]ownerSubscriptionListItem, len(users))
	for i, user := range users {
		item := ownerSubscriptionListItem{
			ID:       user.ID,
			Name:     user.Name,
			Username: user.Username,
			Email:    user.Email,
		}

		sub, err := h.subRepo.GetOwnerSubscription(ctx, user.ID)
		if err == nil {
			mode := string(sub.PlanMode)
			item.PlanMode = &mode
			status := string(sub.Status)
			item.Status = &status
			if sub.PlanTier != nil {
				tier := string(*sub.PlanTier)
				item.PlanTier = &tier
			}
			item.LockedMonthlyAmountCents = sub.LockedMonthlyAmountCents
		} else if !errors.Is(err, gorm.ErrRecordNotFound) {
			apperror.WriteError(w, apperror.Internal("Failed to load owner subscription"))
			return
		}

		shopsUsed, err := h.countShopsUsed(ctx, user.ID)
		if err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to count shops"))
			return
		}
		item.ShopsUsed = shopsUsed

		items[i] = item
	}

	resp := model.NewPageResponse(items, page, size, total)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *SubscriptionAdminHandler) OverrideOwnerPlan(w http.ResponseWriter, r *http.Request) {
	if !h.requireAdmin(w, r) {
		return
	}

	userID := chi.URLParam(r, "userId")
	var user auth.User
	if err := h.db.WithContext(r.Context()).First(&user, "id = ?", userID).Error; err != nil {
		apperror.WriteError(w, apperror.NotFound("User not found"))
		return
	}
	if auth.NormalizeUserType(user.UserType) != "SHOP_OWNER" {
		apperror.WriteError(w, apperror.BadRequest("User is not a shop owner"))
		return
	}

	var req adminOwnerOverrideRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	quoteReq, err := buildAdminQuoteRequest(req.PlanMode, req.PlanTier, req.Features, req.BillingInterval)
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	ctx := r.Context()
	sub, err := h.ensureOwnerSubscription(ctx, userID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load subscription"))
		return
	}

	shopCount, err := h.countShopsUsed(ctx, userID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to count shops"))
		return
	}
	if shopCount < 1 {
		shopCount = 1
	}
	quoteReq.ShopCount = shopCount

	lockedAmount, err := h.pricing.ComputeLockedMonthlyAmountCents(ctx, quoteReq)
	if err != nil {
		apperror.WriteError(w, apperror.BadRequest(err.Error()))
		return
	}

	sub.PlanMode = quoteReq.PlanMode
	sub.PlanTier = quoteReq.PlanTier
	sub.BillingInterval = &quoteReq.BillingInterval
	sub.LockedMonthlyAmountCents = &lockedAmount

	if req.Status != "" {
		status := model.SubscriptionStatus(req.Status)
		switch status {
		case model.SubscriptionStatusActive, model.SubscriptionStatusTrialing,
			model.SubscriptionStatusPastDue, model.SubscriptionStatusCanceled:
			sub.Status = status
		default:
			apperror.WriteError(w, apperror.BadRequest("invalid status"))
			return
		}
	} else {
		sub.Status = model.SubscriptionStatusActive
	}

	if err := h.subRepo.UpdateOwnerSubscription(ctx, sub); err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update subscription"))
		return
	}

	if quoteReq.PlanMode == model.PlanModeCustom {
		if err := h.subRepo.SetOwnerSubscriptionFeatures(ctx, userID, quoteReq.Features); err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to update subscription features"))
			return
		}
	} else if err := h.subRepo.SetOwnerSubscriptionFeatures(ctx, userID, nil); err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to clear subscription features"))
		return
	}

	updated, err := h.subRepo.GetOwnerSubscription(ctx, userID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load updated subscription"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(updated)
}

func buildAdminQuoteRequest(planMode string, planTier *string, features []string, billingInterval string) (subscription.QuoteRequest, error) {
	if planMode == "" {
		return subscription.QuoteRequest{}, apperror.BadRequest("planMode is required")
	}

	mode := model.PlanMode(planMode)
	switch mode {
	case model.PlanModePreset, model.PlanModeCustom:
	default:
		return subscription.QuoteRequest{}, apperror.BadRequest("planMode must be PRESET or CUSTOM")
	}

	interval := model.BillingIntervalMonthly
	if billingInterval != "" {
		interval = model.BillingInterval(billingInterval)
		if interval != model.BillingIntervalMonthly && interval != model.BillingIntervalAnnual {
			return subscription.QuoteRequest{}, apperror.BadRequest("billingInterval must be monthly or annual")
		}
	}

	var tier *model.PlanTier
	if mode == model.PlanModePreset {
		if planTier == nil || *planTier == "" {
			return subscription.QuoteRequest{}, apperror.BadRequest("planTier is required for PRESET mode")
		}
		parsed := model.PlanTier(*planTier)
		switch parsed {
		case model.PlanTierStarter, model.PlanTierGrowth, model.PlanTierPro:
			tier = &parsed
		default:
			return subscription.QuoteRequest{}, apperror.BadRequest("unknown plan tier")
		}
	} else if planTier != nil && *planTier != "" {
		return subscription.QuoteRequest{}, apperror.BadRequest("planTier must not be set for CUSTOM mode")
	}

	return subscription.QuoteRequest{
		PlanMode:        mode,
		PlanTier:        tier,
		Features:        features,
		BillingInterval: interval,
	}, nil
}

func (h *SubscriptionAdminHandler) ensureOwnerSubscription(ctx context.Context, ownerUserID string) (*model.OwnerSubscription, error) {
	sub, err := h.subRepo.GetOwnerSubscription(ctx, ownerUserID)
	if err == nil {
		return sub, nil
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}

	starter := model.PlanTierStarter
	interval := model.BillingIntervalMonthly
	sub = &model.OwnerSubscription{
		UserID:          ownerUserID,
		PlanMode:        model.PlanModePreset,
		PlanTier:        &starter,
		Status:          model.SubscriptionStatusActive,
		BillingInterval: &interval,
	}
	locked := 0
	sub.LockedMonthlyAmountCents = &locked

	if err := h.subRepo.CreateOwnerSubscription(ctx, sub); err != nil {
		return nil, err
	}
	return sub, nil
}

func (h *SubscriptionAdminHandler) countShopsUsed(ctx context.Context, ownerUserID string) (int, error) {
	shops, err := h.subRepo.ListShopSubscriptionsByOwner(ctx, ownerUserID)
	if err != nil {
		return 0, err
	}
	if len(shops) > 0 {
		return len(shops), nil
	}

	var count int64
	err = h.db.WithContext(ctx).
		Model(&model.UserShop{}).
		Where("user_id = ? AND relationship_type = ?", ownerUserID, model.RelationshipTypeOwner).
		Count(&count).Error
	return int(count), err
}
