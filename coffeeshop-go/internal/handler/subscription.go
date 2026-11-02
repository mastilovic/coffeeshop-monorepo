package handler

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/repository"
	"github.com/mastilovic/coffeeshop-go/internal/subscription"
	"gorm.io/gorm"
)

type SubscriptionHandler struct {
	db           *gorm.DB
	currentUser  *auth.CurrentUserService
	entitlements *subscription.EntitlementService
	pricing      *subscription.PricingService
	subRepo      *repository.SubscriptionRepository
}

func NewSubscriptionHandler(
	db *gorm.DB,
	currentUser *auth.CurrentUserService,
	entitlements *subscription.EntitlementService,
	pricing *subscription.PricingService,
	subRepo *repository.SubscriptionRepository,
) *SubscriptionHandler {
	return &SubscriptionHandler{
		db:           db,
		currentUser:  currentUser,
		entitlements: entitlements,
		pricing:      pricing,
		subRepo:      subRepo,
	}
}

type catalogTierResponse struct {
	Tier                  string   `json:"tier"`
	DisplayName           string   `json:"displayName"`
	BasePriceMonthlyCents int      `json:"basePriceMonthlyCents"`
	ExtraShopPriceCents   *int     `json:"extraShopPriceCents"`
	AnnualMonthsCharged   int      `json:"annualMonthsCharged"`
	IsActive              bool     `json:"isActive"`
	IncludedFeatures      []string `json:"includedFeatures"`
}

type catalogResponse struct {
	Tiers    []catalogTierResponse  `json:"tiers"`
	Features []model.FeatureCatalog `json:"features"`
}

type quoteRequest struct {
	PlanMode        string   `json:"planMode"`
	PlanTier        *string  `json:"planTier"`
	Features        []string `json:"features"`
	ShopCount       int      `json:"shopCount"`
	BillingInterval string   `json:"billingInterval"`
}

type updatePlanRequest struct {
	PlanMode        string   `json:"planMode"`
	PlanTier        *string  `json:"planTier"`
	Features        []string `json:"features"`
	BillingInterval string   `json:"billingInterval"`
}

type subscriptionMeResponse struct {
	PlanMode                 string                      `json:"planMode"`
	PlanTier                   *string                     `json:"planTier,omitempty"`
	Status                     string                      `json:"status"`
	BillingInterval            *string                     `json:"billingInterval,omitempty"`
	Features                   []string                    `json:"features,omitempty"`
	ShopsIncluded              int                         `json:"shopsIncluded"`
	ShopsUsed                  int                         `json:"shopsUsed"`
	PeriodEnd                  *string                     `json:"periodEnd,omitempty"`
	LockedMonthlyAmountCents   int                         `json:"lockedMonthlyAmountCents"`
	RenewalQuote               *subscription.QuoteBreakdown `json:"renewalQuote"`
	Entitlements               map[string]bool             `json:"entitlements"`
	Limits                     map[string]limitUsage       `json:"limits,omitempty"`
}

func (h *SubscriptionHandler) GetCatalog(w http.ResponseWriter, r *http.Request) {
	if _, err := h.requireShopOwner(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

	ctx := r.Context()
	tiers, err := h.subRepo.ListPlanTiers(ctx)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load plan tiers"))
		return
	}

	features, err := h.subRepo.ListFeatures(ctx)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load features"))
		return
	}

	tierResponses := make([]catalogTierResponse, 0, len(tiers))
	for _, tier := range tiers {
		mappings, err := h.subRepo.ListPlanTierFeatures(ctx, tier.Tier)
		if err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to load tier features"))
			return
		}
		included := []string{}
		for _, mapping := range mappings {
			if mapping.Included {
				included = append(included, mapping.FeatureKey)
			}
		}
		tierResponses = append(tierResponses, catalogTierResponse{
			Tier:                  string(tier.Tier),
			DisplayName:           tier.DisplayName,
			BasePriceMonthlyCents: tier.BasePriceMonthlyCents,
			ExtraShopPriceCents:   tier.ExtraShopPriceCents,
			AnnualMonthsCharged:   tier.AnnualMonthsCharged,
			IsActive:              tier.IsActive,
			IncludedFeatures:      included,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(catalogResponse{
		Tiers:    tierResponses,
		Features: features,
	})
}

func (h *SubscriptionHandler) Quote(w http.ResponseWriter, r *http.Request) {
	if _, err := h.requireShopOwner(r.Context()); err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req quoteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	quoteReq, err := h.parseQuoteRequest(req)
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	breakdown, err := h.pricing.Quote(r.Context(), quoteReq)
	if err != nil {
		apperror.WriteError(w, apperror.BadRequest(err.Error()))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(breakdown)
}

func (h *SubscriptionHandler) GetMe(w http.ResponseWriter, r *http.Request) {
	user, err := h.requireShopOwner(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	ctx := r.Context()
	sub, err := h.ensureOwnerSubscription(ctx, user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load subscription"))
		return
	}

	if err := h.syncShopSubscriptions(ctx, user.ID); err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to sync shop subscriptions"))
		return
	}

	resp, err := h.buildMeResponse(ctx, user.ID, sub)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load subscription details"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *SubscriptionHandler) UpdatePlan(w http.ResponseWriter, r *http.Request) {
	user, err := h.requireShopOwner(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	var req updatePlanRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		apperror.WriteError(w, apperror.BadRequest("Invalid request body"))
		return
	}

	quoteReq, err := h.parseUpdatePlanRequest(req)
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	ctx := r.Context()
	sub, err := h.ensureOwnerSubscription(ctx, user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load subscription"))
		return
	}

	if err := h.syncShopSubscriptions(ctx, user.ID); err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to sync shop subscriptions"))
		return
	}

	shopCount, err := h.countShopsUsed(ctx, user.ID)
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
	sub.Status = model.SubscriptionStatusActive

	if err := h.subRepo.UpdateOwnerSubscription(ctx, sub); err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to update subscription"))
		return
	}

	if quoteReq.PlanMode == model.PlanModeCustom {
		if err := h.subRepo.SetOwnerSubscriptionFeatures(ctx, user.ID, quoteReq.Features); err != nil {
			apperror.WriteError(w, apperror.Internal("Failed to update subscription features"))
			return
		}
	} else if err := h.subRepo.SetOwnerSubscriptionFeatures(ctx, user.ID, nil); err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to clear subscription features"))
		return
	}

	updated, err := h.subRepo.GetOwnerSubscription(ctx, user.ID)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load updated subscription"))
		return
	}

	resp, err := h.buildMeResponse(ctx, user.ID, updated)
	if err != nil {
		apperror.WriteError(w, apperror.Internal("Failed to load subscription details"))
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (h *SubscriptionHandler) requireShopOwner(ctx context.Context) (*auth.User, error) {
	user, err := h.currentUser.RequireCurrentUser(ctx)
	if err != nil {
		return nil, err
	}
	if auth.NormalizeUserType(user.UserType) != "SHOP_OWNER" {
		return nil, apperror.Forbidden("Shop owner access required")
	}
	return user, nil
}

func (h *SubscriptionHandler) ensureOwnerSubscription(ctx context.Context, ownerUserID string) (*model.OwnerSubscription, error) {
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

func (h *SubscriptionHandler) syncShopSubscriptions(ctx context.Context, ownerUserID string) error {
	var ownedShopIDs []string
	err := h.db.WithContext(ctx).
		Table("user_shop").
		Select("shop_id").
		Where("user_id = ? AND relationship_type = ?", ownerUserID, model.RelationshipTypeOwner).
		Order("shop_id ASC").
		Pluck("shop_id", &ownedShopIDs).Error
	if err != nil {
		return err
	}

	existing, err := h.subRepo.ListShopSubscriptionsByOwner(ctx, ownerUserID)
	if err != nil {
		return err
	}

	existingByShop := make(map[string]bool, len(existing))
	hasBase := false
	for _, row := range existing {
		existingByShop[row.ShopID] = true
		if row.IsBaseShop {
			hasBase = true
		}
	}

	for _, shopID := range ownedShopIDs {
		if existingByShop[shopID] {
			continue
		}
		row := model.ShopSubscription{
			ShopID:      shopID,
			OwnerUserID: ownerUserID,
			IsBaseShop:  !hasBase,
		}
		if err := h.db.WithContext(ctx).Create(&row).Error; err != nil {
			return err
		}
		if !hasBase {
			hasBase = true
		}
	}
	return nil
}

func (h *SubscriptionHandler) buildMeResponse(ctx context.Context, ownerUserID string, sub *model.OwnerSubscription) (*subscriptionMeResponse, error) {
	shopsUsed, err := h.countShopsUsed(ctx, ownerUserID)
	if err != nil {
		return nil, err
	}
	if shopsUsed < 1 {
		shopsUsed = 1
	}

	billingInterval := model.BillingIntervalMonthly
	if sub.BillingInterval != nil {
		billingInterval = *sub.BillingInterval
	}

	featureKeys := []string{}
	if sub.PlanMode == model.PlanModeCustom {
		features, err := h.subRepo.GetOwnerSubscriptionFeatures(ctx, ownerUserID)
		if err != nil {
			return nil, err
		}
		for _, feature := range features {
			featureKeys = append(featureKeys, feature.FeatureKey)
		}
	}

	renewalQuote, err := h.pricing.Quote(ctx, subscription.QuoteRequest{
		PlanMode:        sub.PlanMode,
		PlanTier:        sub.PlanTier,
		Features:        featureKeys,
		ShopCount:       shopsUsed,
		BillingInterval: billingInterval,
	})
	if err != nil {
		return nil, err
	}

	lockedAmount := renewalQuote.MonthlyTotalCents
	if sub.LockedMonthlyAmountCents != nil {
		lockedAmount = *sub.LockedMonthlyAmountCents
	}

	ownerID, err := uuid.Parse(ownerUserID)
	if err != nil {
		return nil, err
	}

	isAdmin := isAdminFromContext(ctx)
	entitlements, err := h.entitlements.ResolveEntitlements(ctx, ownerID, isAdmin)
	if err != nil {
		return nil, err
	}

	resp := &subscriptionMeResponse{
		PlanMode:               string(sub.PlanMode),
		Status:                 string(sub.Status),
		ShopsIncluded:          1,
		ShopsUsed:              shopsUsed,
		LockedMonthlyAmountCents: lockedAmount,
		RenewalQuote:           renewalQuote,
		Entitlements:           entitlementsToMap(entitlements),
	}
	if sub.PlanTier != nil {
		tier := string(*sub.PlanTier)
		resp.PlanTier = &tier
	}
	if sub.BillingInterval != nil {
		interval := string(*sub.BillingInterval)
		resp.BillingInterval = &interval
	}
	if len(featureKeys) > 0 {
		resp.Features = featureKeys
	}
	if sub.CurrentPeriodEnd != nil {
		formatted := sub.CurrentPeriodEnd.UTC().Format("2006-01-02")
		resp.PeriodEnd = &formatted
	}

	if primaryShopID, err := h.resolvePrimaryShopID(ctx, ownerUserID); err == nil {
		limits, err := h.loadSubscriptionLimits(ctx, ownerID, primaryShopID, isAdmin)
		if err != nil {
			return nil, err
		}
		resp.Limits = limits
	}

	return resp, nil
}

func (h *SubscriptionHandler) countShopsUsed(ctx context.Context, ownerUserID string) (int, error) {
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

func (h *SubscriptionHandler) resolvePrimaryShopID(ctx context.Context, ownerUserID string) (uuid.UUID, error) {
	var baseShop model.ShopSubscription
	err := h.db.WithContext(ctx).
		Where("owner_user_id = ? AND is_base_shop = ?", ownerUserID, true).
		First(&baseShop).Error
	if err == nil {
		return uuid.Parse(baseShop.ShopID)
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return uuid.Nil, err
	}

	var shopID string
	err = h.db.WithContext(ctx).
		Table("shop AS s").
		Select("s.id").
		Joins("JOIN user_shop AS us ON us.shop_id = s.id").
		Where("us.user_id = ? AND us.relationship_type = ?", ownerUserID, model.RelationshipTypeOwner).
		Order("s.name ASC").
		Limit(1).
		Scan(&shopID).Error
	if err != nil {
		return uuid.Nil, err
	}
	if shopID == "" {
		return uuid.Nil, gorm.ErrRecordNotFound
	}
	return uuid.Parse(shopID)
}

func (h *SubscriptionHandler) loadSubscriptionLimits(ctx context.Context, ownerID, shopID uuid.UUID, isAdmin bool) (map[string]limitUsage, error) {
	limitTypes := []subscription.LimitType{
		subscription.LimitTables,
		subscription.LimitMenus,
		subscription.LimitEvents,
		subscription.LimitEmployees,
		subscription.LimitShops,
	}

	limits := make(map[string]limitUsage, len(limitTypes))
	for _, limitType := range limitTypes {
		used, max, _, _ := h.entitlements.CheckLimit(ctx, ownerID, shopID, limitType, isAdmin)
		limits[string(limitType)] = limitUsage{Used: used, Max: max}
	}
	return limits, nil
}

func (h *SubscriptionHandler) parseQuoteRequest(req quoteRequest) (subscription.QuoteRequest, error) {
	if req.ShopCount < 1 {
		return subscription.QuoteRequest{}, apperror.BadRequest("shopCount must be at least 1")
	}
	quoteReq, err := h.buildQuoteRequest(req.PlanMode, req.PlanTier, req.Features, req.BillingInterval)
	if err != nil {
		return subscription.QuoteRequest{}, err
	}
	quoteReq.ShopCount = req.ShopCount
	return quoteReq, nil
}

func (h *SubscriptionHandler) parseUpdatePlanRequest(req updatePlanRequest) (subscription.QuoteRequest, error) {
	return h.buildQuoteRequest(req.PlanMode, req.PlanTier, req.Features, req.BillingInterval)
}

func (h *SubscriptionHandler) buildQuoteRequest(planMode string, planTier *string, features []string, billingInterval string) (subscription.QuoteRequest, error) {
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
