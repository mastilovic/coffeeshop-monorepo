package model

import "time"

type PlanMode string

const (
	PlanModePreset PlanMode = "PRESET"
	PlanModeCustom PlanMode = "CUSTOM"
)

type PlanTier string

const (
	PlanTierStarter PlanTier = "STARTER"
	PlanTierGrowth  PlanTier = "GROWTH"
	PlanTierPro     PlanTier = "PRO"
)

type SubscriptionStatus string

const (
	SubscriptionStatusActive    SubscriptionStatus = "active"
	SubscriptionStatusTrialing  SubscriptionStatus = "trialing"
	SubscriptionStatusPastDue   SubscriptionStatus = "past_due"
	SubscriptionStatusCanceled  SubscriptionStatus = "canceled"
)

type BillingInterval string

const (
	BillingIntervalMonthly BillingInterval = "monthly"
	BillingIntervalAnnual  BillingInterval = "annual"
)

type PlanTierCatalog struct {
	Tier                   PlanTier  `gorm:"column:tier;primaryKey" json:"tier"`
	DisplayName            string    `gorm:"column:display_name;not null" json:"displayName"`
	BasePriceMonthlyCents  int       `gorm:"column:base_price_monthly_cents;not null;default:0" json:"basePriceMonthlyCents"`
	ExtraShopPriceCents    *int      `gorm:"column:extra_shop_price_cents" json:"extraShopPriceCents"`
	AnnualMonthsCharged    int       `gorm:"column:annual_months_charged;not null;default:12" json:"annualMonthsCharged"`
	IsActive               bool      `gorm:"column:is_active;not null;default:true" json:"isActive"`
	UpdatedAt              time.Time `gorm:"column:updated_at;autoUpdateTime" json:"updatedAt"`
}

func (PlanTierCatalog) TableName() string { return "plan_tier_catalog" }

type FeatureCatalog struct {
	FeatureKey          string  `gorm:"column:feature_key;primaryKey" json:"featureKey"`
	DisplayName         string  `gorm:"column:display_name;not null" json:"displayName"`
	Description         *string `gorm:"column:description" json:"description"`
	MonthlyPriceCents   int     `gorm:"column:monthly_price_cents;not null;default:0" json:"monthlyPriceCents"`
	LimitType           *string `gorm:"column:limit_type" json:"limitType"`
	LimitValue          *int    `gorm:"column:limit_value" json:"limitValue"`
	IsSelectableCustom  bool    `gorm:"column:is_selectable_custom;not null;default:true" json:"isSelectableCustom"`
	SortOrder           int     `gorm:"column:sort_order;not null;default:0" json:"sortOrder"`
	IsActive            bool    `gorm:"column:is_active;not null;default:true" json:"isActive"`
}

func (FeatureCatalog) TableName() string { return "feature_catalog" }

type PlanTierFeature struct {
	Tier       PlanTier `gorm:"column:tier;primaryKey" json:"tier"`
	FeatureKey string   `gorm:"column:feature_key;primaryKey" json:"featureKey"`
	Included   bool     `gorm:"column:included;not null;default:false" json:"included"`
}

func (PlanTierFeature) TableName() string { return "plan_tier_features" }

type OwnerSubscription struct {
	UserID                   string              `gorm:"column:user_id;type:uuid;primaryKey" json:"userId"`
	PlanMode                 PlanMode            `gorm:"column:plan_mode;not null" json:"planMode"`
	PlanTier                 *PlanTier           `gorm:"column:plan_tier" json:"planTier"`
	Status                   SubscriptionStatus  `gorm:"column:status;not null" json:"status"`
	BillingInterval          *BillingInterval    `gorm:"column:billing_interval" json:"billingInterval"`
	LockedMonthlyAmountCents *int                `gorm:"column:locked_monthly_amount_cents" json:"lockedMonthlyAmountCents"`
	CurrentPeriodStart       *time.Time          `gorm:"column:current_period_start" json:"currentPeriodStart"`
	CurrentPeriodEnd         *time.Time          `gorm:"column:current_period_end" json:"currentPeriodEnd"`
	CanceledAt               *time.Time          `gorm:"column:canceled_at" json:"canceledAt"`
}

func (OwnerSubscription) TableName() string { return "owner_subscription" }

type OwnerSubscriptionFeature struct {
	UserID     string `gorm:"column:user_id;type:uuid;primaryKey" json:"userId"`
	FeatureKey string `gorm:"column:feature_key;primaryKey" json:"featureKey"`
}

func (OwnerSubscriptionFeature) TableName() string { return "owner_subscription_features" }

type ShopSubscription struct {
	ShopID      string `gorm:"column:shop_id;type:uuid;primaryKey" json:"shopId"`
	OwnerUserID string `gorm:"column:owner_user_id;type:uuid;not null" json:"ownerUserId"`
	IsBaseShop  bool   `gorm:"column:is_base_shop;not null;default:false" json:"isBaseShop"`
}

func (ShopSubscription) TableName() string { return "shop_subscription" }

type ShopUsage struct {
	ShopID        string    `gorm:"column:shop_id;type:uuid;primaryKey" json:"shopId"`
	PeriodStart   time.Time `gorm:"column:period_start;type:date;primaryKey" json:"periodStart"`
	EventsCreated int       `gorm:"column:events_created;not null;default:0" json:"eventsCreated"`
}

func (ShopUsage) TableName() string { return "shop_usage" }
