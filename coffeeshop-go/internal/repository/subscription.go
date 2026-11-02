package repository

import (
	"context"
	"errors"
	"time"

	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type SubscriptionRepository struct {
	db *gorm.DB
}

func NewSubscriptionRepository(db *gorm.DB) *SubscriptionRepository {
	return &SubscriptionRepository{db: db}
}

func (r *SubscriptionRepository) ListPlanTiers(ctx context.Context) ([]model.PlanTierCatalog, error) {
	var tiers []model.PlanTierCatalog
	err := r.db.WithContext(ctx).Order("tier").Find(&tiers).Error
	if err != nil {
		return nil, err
	}
	return tiers, nil
}

func (r *SubscriptionRepository) ListFeatures(ctx context.Context) ([]model.FeatureCatalog, error) {
	var features []model.FeatureCatalog
	err := r.db.WithContext(ctx).Order("sort_order, feature_key").Find(&features).Error
	if err != nil {
		return nil, err
	}
	return features, nil
}

func (r *SubscriptionRepository) ListPlanTierFeatures(ctx context.Context, tier model.PlanTier) ([]model.PlanTierFeature, error) {
	var mappings []model.PlanTierFeature
	err := r.db.WithContext(ctx).
		Where("tier = ?", tier).
		Order("feature_key").
		Find(&mappings).Error
	if err != nil {
		return nil, err
	}
	return mappings, nil
}

func (r *SubscriptionRepository) GetOwnerSubscription(ctx context.Context, userID string) (*model.OwnerSubscription, error) {
	var sub model.OwnerSubscription
	err := r.db.WithContext(ctx).First(&sub, "user_id = ?", userID).Error
	if err != nil {
		return nil, err
	}
	return &sub, nil
}

func (r *SubscriptionRepository) CreateOwnerSubscription(ctx context.Context, sub *model.OwnerSubscription) error {
	return r.db.WithContext(ctx).Create(sub).Error
}

func (r *SubscriptionRepository) UpdateOwnerSubscription(ctx context.Context, sub *model.OwnerSubscription) error {
	return r.db.WithContext(ctx).Save(sub).Error
}

func (r *SubscriptionRepository) GetOwnerSubscriptionFeatures(ctx context.Context, userID string) ([]model.OwnerSubscriptionFeature, error) {
	var features []model.OwnerSubscriptionFeature
	err := r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		Order("feature_key").
		Find(&features).Error
	if err != nil {
		return nil, err
	}
	return features, nil
}

func (r *SubscriptionRepository) SetOwnerSubscriptionFeatures(ctx context.Context, userID string, featureKeys []string) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Where("user_id = ?", userID).Delete(&model.OwnerSubscriptionFeature{}).Error; err != nil {
			return err
		}
		if len(featureKeys) == 0 {
			return nil
		}
		rows := make([]model.OwnerSubscriptionFeature, len(featureKeys))
		for i, key := range featureKeys {
			rows[i] = model.OwnerSubscriptionFeature{
				UserID:     userID,
				FeatureKey: key,
			}
		}
		return tx.Create(&rows).Error
	})
}

func (r *SubscriptionRepository) ListShopSubscriptionsByOwner(ctx context.Context, ownerUserID string) ([]model.ShopSubscription, error) {
	var subs []model.ShopSubscription
	err := r.db.WithContext(ctx).
		Where("owner_user_id = ?", ownerUserID).
		Order("shop_id").
		Find(&subs).Error
	if err != nil {
		return nil, err
	}
	return subs, nil
}

func (r *SubscriptionRepository) GetShopSubscriptionByShopID(ctx context.Context, shopID string) (*model.ShopSubscription, error) {
	var sub model.ShopSubscription
	err := r.db.WithContext(ctx).First(&sub, "shop_id = ?", shopID).Error
	if err != nil {
		return nil, err
	}
	return &sub, nil
}

func (r *SubscriptionRepository) GetShopUsage(ctx context.Context, shopID string, periodStart time.Time) (*model.ShopUsage, error) {
	period := truncateToDate(periodStart)
	var usage model.ShopUsage
	err := r.db.WithContext(ctx).
		Where("shop_id = ? AND period_start = ?", shopID, period).
		First(&usage).Error
	if err != nil {
		return nil, err
	}
	return &usage, nil
}

func (r *SubscriptionRepository) IncrementEventsCreated(ctx context.Context, shopID string, periodStart time.Time) (*model.ShopUsage, error) {
	period := truncateToDate(periodStart)

	var usage model.ShopUsage
	err := r.db.WithContext(ctx).
		Where("shop_id = ? AND period_start = ?", shopID, period).
		First(&usage).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		usage = model.ShopUsage{
			ShopID:        shopID,
			PeriodStart:   period,
			EventsCreated: 1,
		}
		if createErr := r.db.WithContext(ctx).Create(&usage).Error; createErr != nil {
			return nil, createErr
		}
		return &usage, nil
	}
	if err != nil {
		return nil, err
	}

	usage.EventsCreated++
	if saveErr := r.db.WithContext(ctx).Save(&usage).Error; saveErr != nil {
		return nil, saveErr
	}
	return &usage, nil
}

func (r *SubscriptionRepository) UpdatePlanTier(ctx context.Context, tier *model.PlanTierCatalog) error {
	return r.db.WithContext(ctx).Save(tier).Error
}

func (r *SubscriptionRepository) UpdateFeature(ctx context.Context, feature *model.FeatureCatalog) error {
	return r.db.WithContext(ctx).Save(feature).Error
}

func truncateToDate(t time.Time) time.Time {
	y, m, d := t.Date()
	return time.Date(y, m, d, 0, 0, 0, 0, time.UTC)
}
