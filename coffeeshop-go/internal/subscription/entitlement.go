package subscription

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"github.com/mastilovic/coffeeshop-go/internal/repository"
	"gorm.io/gorm"
)

type Feature string

const (
	FeatureReservationManage    Feature = "reservation_manage"
	FeatureEventCreate          Feature = "event_create"
	FeatureEmployeeAssign       Feature = "employee_assign"
	FeatureCommunityPost        Feature = "community_post"
	FeatureLoyaltyBasic         Feature = "loyalty_basic"
	FeatureLoyaltyPremium       Feature = "loyalty_premium"
	FeatureReviewModerate       Feature = "review_moderate"
	FeatureDashboardNotifications Feature = "dashboard_notifications"
	FeatureAnalytics            Feature = "analytics"
	FeatureUnlimitedTables      Feature = "unlimited_tables"
	FeatureUnlimitedMenus       Feature = "unlimited_menus"
)

var allFeatures = []Feature{
	FeatureReservationManage,
	FeatureEventCreate,
	FeatureEmployeeAssign,
	FeatureCommunityPost,
	FeatureLoyaltyBasic,
	FeatureLoyaltyPremium,
	FeatureReviewModerate,
	FeatureDashboardNotifications,
	FeatureAnalytics,
	FeatureUnlimitedTables,
	FeatureUnlimitedMenus,
}

var tierResolutionOrder = []model.PlanTier{
	model.PlanTierStarter,
	model.PlanTierGrowth,
	model.PlanTierPro,
}

type LimitType string

const (
	LimitTables    LimitType = "tables"
	LimitMenus     LimitType = "menus"
	LimitEvents    LimitType = "events"
	LimitEmployees LimitType = "employees"
	LimitShops     LimitType = "shops"
)

const unlimitedSentinel = -1

type UpgradeHint struct {
	RequiredPlan     *model.PlanTier `json:"requiredPlan,omitempty"`
	RequiredFeatures []Feature       `json:"requiredFeatures,omitempty"`
}

type EntitlementService struct {
	db      *gorm.DB
	subRepo *repository.SubscriptionRepository
}

func NewEntitlementService(db *gorm.DB, subRepo *repository.SubscriptionRepository) *EntitlementService {
	return &EntitlementService{db: db, subRepo: subRepo}
}

func (e *EntitlementService) CanUse(ctx context.Context, userID, shopID uuid.UUID, feature Feature, isAdmin bool) (bool, *UpgradeHint) {
	_ = userID

	if isAdmin {
		return true, nil
	}

	ownerID, err := e.resolveShopOwnerID(ctx, shopID)
	if err != nil {
		return false, e.upgradeHintForFeature(ctx, feature)
	}

	entitlements, err := e.resolveEntitlementsForOwner(ctx, ownerID.String())
	if err != nil {
		return false, e.upgradeHintForFeature(ctx, feature)
	}

	if entitlements[feature] {
		return true, nil
	}
	return false, e.upgradeHintForFeature(ctx, feature)
}

func (e *EntitlementService) ResolveEntitlements(ctx context.Context, ownerUserID uuid.UUID, isAdmin bool) (map[Feature]bool, error) {
	if isAdmin {
		return allEntitlements(true), nil
	}
	return e.resolveEntitlementsForOwner(ctx, ownerUserID.String())
}

func (e *EntitlementService) CheckLimit(ctx context.Context, userID, shopID uuid.UUID, limit LimitType, isAdmin bool) (used, max int, ok bool, hint *UpgradeHint) {
	_ = userID

	if isAdmin {
		return 0, unlimitedSentinel, true, nil
	}

	var ownerID uuid.UUID
	if limit == LimitShops {
		ownerID = userID
	} else {
		var err error
		ownerID, err = e.resolveShopOwnerID(ctx, shopID)
		if err != nil {
			return 0, 0, false, e.upgradeHintForLimit(ctx, limit)
		}
	}

	entitlements, err := e.resolveEntitlementsForOwner(ctx, ownerID.String())
	if err != nil {
		return 0, 0, false, e.upgradeHintForLimit(ctx, limit)
	}

	sub, err := e.subRepo.GetOwnerSubscription(ctx, ownerID.String())
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return 0, 0, false, e.upgradeHintForLimit(ctx, limit)
	}
	if errors.Is(err, gorm.ErrRecordNotFound) {
		sub = nil
	}

	max, hint = e.resolveMaxLimit(ctx, entitlements, sub, limit)
	used, err = e.countUsed(ctx, ownerID, shopID, limit)
	if err != nil {
		return used, max, false, hint
	}

	if max < 0 {
		return used, max, true, nil
	}
	return used, max, used < max, hint
}

func (e *EntitlementService) resolveShopOwnerID(ctx context.Context, shopID uuid.UUID) (uuid.UUID, error) {
	var link model.UserShop
	err := e.db.WithContext(ctx).
		Where("shop_id = ? AND relationship_type = ?", shopID.String(), model.RelationshipTypeOwner).
		First(&link).Error
	if err != nil {
		return uuid.Nil, err
	}
	return uuid.Parse(link.UserID)
}

func (e *EntitlementService) resolveEntitlementsForOwner(ctx context.Context, ownerUserID string) (map[Feature]bool, error) {
	entitlements := allEntitlements(false)

	sub, err := e.subRepo.GetOwnerSubscription(ctx, ownerUserID)
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return entitlements, nil
	}
	if err != nil {
		return nil, err
	}

	switch sub.PlanMode {
	case model.PlanModePreset:
		if sub.PlanTier == nil {
			return entitlements, nil
		}
		mappings, err := e.subRepo.ListPlanTierFeatures(ctx, *sub.PlanTier)
		if err != nil {
			return nil, err
		}
		for _, mapping := range mappings {
			if mapping.Included {
				entitlements[Feature(mapping.FeatureKey)] = true
			}
		}
	case model.PlanModeCustom:
		features, err := e.subRepo.GetOwnerSubscriptionFeatures(ctx, ownerUserID)
		if err != nil {
			return nil, err
		}
		for _, feature := range features {
			entitlements[Feature(feature.FeatureKey)] = true
		}
	}

	return entitlements, nil
}

func (e *EntitlementService) resolveMaxLimit(ctx context.Context, entitlements map[Feature]bool, sub *model.OwnerSubscription, limit LimitType) (int, *UpgradeHint) {
	switch limit {
	case LimitTables:
		if entitlements[FeatureUnlimitedTables] {
			return unlimitedSentinel, nil
		}
		return e.featureLimitValue(ctx, string(FeatureUnlimitedTables), 15), e.upgradeHintForLimit(ctx, limit)

	case LimitMenus:
		if entitlements[FeatureUnlimitedMenus] {
			return unlimitedSentinel, nil
		}
		return e.featureLimitValue(ctx, string(FeatureUnlimitedMenus), 1), e.upgradeHintForLimit(ctx, limit)

	case LimitEvents:
		if !entitlements[FeatureEventCreate] {
			return 0, e.upgradeHintForLimit(ctx, limit)
		}
		if isProTier(sub) {
			return unlimitedSentinel, nil
		}
		return e.featureLimitValue(ctx, string(FeatureEventCreate), 5), nil

	case LimitEmployees:
		if !entitlements[FeatureEmployeeAssign] {
			return 0, e.upgradeHintForLimit(ctx, limit)
		}
		if isProTier(sub) {
			return unlimitedSentinel, nil
		}
		return e.featureLimitValue(ctx, string(FeatureEmployeeAssign), 3), nil

	case LimitShops:
		if isStarterTier(sub) {
			return 1, e.upgradeHintForLimit(ctx, limit)
		}
		return unlimitedSentinel, nil

	default:
		return 0, nil
	}
}

func (e *EntitlementService) countUsed(ctx context.Context, ownerID, shopID uuid.UUID, limit LimitType) (int, error) {
	switch limit {
	case LimitTables:
		var count int64
		err := e.db.WithContext(ctx).Model(&model.Table{}).Where("shop_id = ?", shopID.String()).Count(&count).Error
		return int(count), err

	case LimitMenus:
		var count int64
		err := e.db.WithContext(ctx).Model(&model.Menu{}).Where("shop_id = ?", shopID.String()).Count(&count).Error
		return int(count), err

	case LimitEvents:
		usage, err := e.subRepo.GetShopUsage(ctx, shopID.String(), currentMonthPeriodStart())
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return 0, nil
		}
		if err != nil {
			return 0, err
		}
		return usage.EventsCreated, nil

	case LimitEmployees:
		var count int64
		err := e.db.WithContext(ctx).Model(&model.UserShop{}).
			Where("shop_id = ? AND relationship_type = ?", shopID.String(), model.RelationshipTypeEmployee).
			Count(&count).Error
		return int(count), err

	case LimitShops:
		shops, err := e.subRepo.ListShopSubscriptionsByOwner(ctx, ownerID.String())
		if err != nil {
			return 0, err
		}
		return len(shops), nil

	default:
		return 0, fmt.Errorf("unknown limit type: %s", limit)
	}
}

func (e *EntitlementService) featureLimitValue(ctx context.Context, featureKey string, fallback int) int {
	features, err := e.subRepo.ListFeatures(ctx)
	if err != nil {
		return fallback
	}
	for _, feature := range features {
		if feature.FeatureKey == featureKey && feature.LimitValue != nil {
			return *feature.LimitValue
		}
	}
	return fallback
}

func (e *EntitlementService) upgradeHintForLimit(ctx context.Context, limit LimitType) *UpgradeHint {
	switch limit {
	case LimitTables:
		return e.upgradeHintForFeature(ctx, FeatureUnlimitedTables)
	case LimitMenus:
		return e.upgradeHintForFeature(ctx, FeatureUnlimitedMenus)
	case LimitEvents:
		return e.upgradeHintForFeature(ctx, FeatureEventCreate)
	case LimitEmployees:
		return e.upgradeHintForFeature(ctx, FeatureEmployeeAssign)
	case LimitShops:
		growth := model.PlanTierGrowth
		return &UpgradeHint{RequiredPlan: &growth}
	default:
		return nil
	}
}

func (e *EntitlementService) upgradeHintForFeature(ctx context.Context, feature Feature) *UpgradeHint {
	for _, tier := range tierResolutionOrder {
		mappings, err := e.subRepo.ListPlanTierFeatures(ctx, tier)
		if err != nil {
			continue
		}
		for _, mapping := range mappings {
			if mapping.FeatureKey == string(feature) && mapping.Included {
				requiredTier := tier
				return &UpgradeHint{
					RequiredPlan:     &requiredTier,
					RequiredFeatures: []Feature{feature},
				}
			}
		}
	}
	return &UpgradeHint{RequiredFeatures: []Feature{feature}}
}

func allEntitlements(enabled bool) map[Feature]bool {
	result := make(map[Feature]bool, len(allFeatures))
	for _, feature := range allFeatures {
		result[feature] = enabled
	}
	return result
}

func isProTier(sub *model.OwnerSubscription) bool {
	return sub != nil && sub.PlanMode == model.PlanModePreset && sub.PlanTier != nil && *sub.PlanTier == model.PlanTierPro
}

func isStarterTier(sub *model.OwnerSubscription) bool {
	if sub == nil {
		return true
	}
	if sub.PlanMode == model.PlanModeCustom {
		return false
	}
	return sub.PlanTier == nil || *sub.PlanTier == model.PlanTierStarter
}

func currentMonthPeriodStart() time.Time {
	now := time.Now().UTC()
	return time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
}
