export type PlanMode = 'PRESET' | 'CUSTOM';

export type PlanTier = 'STARTER' | 'GROWTH' | 'PRO';

export type SubscriptionStatus = 'active' | 'trialing' | 'past_due' | 'canceled';

export type BillingInterval = 'monthly' | 'annual';

export type FeatureKey =
  | 'reservation_manage'
  | 'event_create'
  | 'employee_assign'
  | 'community_post'
  | 'loyalty_basic'
  | 'loyalty_premium'
  | 'review_moderate'
  | 'dashboard_notifications'
  | 'analytics'
  | 'unlimited_tables'
  | 'unlimited_menus';

export type LimitKey = 'tables' | 'menus' | 'events' | 'employees' | 'shops';

export interface LimitUsage {
  used: number;
  max: number;
}

export interface SubscriptionSummary {
  planMode: PlanMode;
  planTier?: PlanTier;
  status: SubscriptionStatus;
  shopsIncluded: number;
  shopsUsed: number;
  periodEnd?: string;
  monthlyAmountCents: number;
}

export interface FeatureCatalogItem {
  featureKey: string;
  displayName: string;
  description?: string | null;
  monthlyPriceCents: number;
  limitType?: string | null;
  limitValue?: number | null;
  isSelectableCustom: boolean;
  sortOrder: number;
  isActive: boolean;
}

export interface CatalogTier {
  tier: PlanTier;
  displayName: string;
  basePriceMonthlyCents: number;
  extraShopPriceCents?: number | null;
  annualMonthsCharged: number;
  isActive: boolean;
  includedFeatures: string[];
}

export interface CatalogResponse {
  tiers: CatalogTier[];
  features: FeatureCatalogItem[];
}

export interface QuoteLineItem {
  key: string;
  label: string;
  amountCents: number;
}

export interface QuoteBreakdown {
  baseMonthlyCents: number;
  extraShopsCents: number;
  featuresMonthlyCents: number;
  monthlyTotalCents: number;
  annualTotalCents: number;
  annualMonthsCharged: number;
  lineItems: QuoteLineItem[];
}

export interface QuoteRequest {
  planMode: PlanMode;
  planTier?: PlanTier;
  features?: string[];
  shopCount: number;
  billingInterval: BillingInterval;
}

export interface UpdatePlanRequest {
  planMode: PlanMode;
  planTier?: PlanTier;
  features?: string[];
  billingInterval: BillingInterval;
}

export interface SubscriptionMeResponse {
  planMode: PlanMode;
  planTier?: PlanTier;
  status: SubscriptionStatus;
  billingInterval?: BillingInterval;
  features?: string[];
  shopsIncluded: number;
  shopsUsed: number;
  periodEnd?: string;
  lockedMonthlyAmountCents: number;
  renewalQuote?: QuoteBreakdown;
  entitlements: Record<string, boolean>;
  limits?: Record<string, LimitUsage>;
}
