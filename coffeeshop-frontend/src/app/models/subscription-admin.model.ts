import { PageResponseDto } from './event.model';
import {
  BillingInterval,
  FeatureCatalogItem,
  PlanMode,
  PlanTier,
  SubscriptionStatus,
} from './subscription.model';

export interface PlanTierCatalogItem {
  tier: PlanTier;
  displayName: string;
  basePriceMonthlyCents: number;
  extraShopPriceCents?: number | null;
  annualMonthsCharged: number;
  isActive: boolean;
  updatedAt?: string;
}

export interface AdminTierUpdate {
  tier: PlanTier;
  displayName?: string;
  basePriceMonthlyCents: number;
  extraShopPriceCents?: number | null;
  annualMonthsCharged: number;
  isActive: boolean;
}

export interface AdminFeatureUpdate {
  featureKey: string;
  monthlyPriceCents: number;
  limitType?: string | null;
  limitValue?: number | null;
  isSelectableCustom: boolean;
  isActive: boolean;
}

export interface OwnerSubscriptionListItem {
  id: string;
  name: string;
  username: string;
  email: string;
  planMode?: PlanMode;
  planTier?: PlanTier;
  status?: SubscriptionStatus;
  shopsUsed: number;
  lockedMonthlyAmountCents?: number;
}

export type OwnerSubscriptionPage = PageResponseDto<OwnerSubscriptionListItem>;

export interface AdminOwnerOverrideRequest {
  planMode: PlanMode;
  planTier?: PlanTier;
  features: string[];
  billingInterval: BillingInterval;
  status: SubscriptionStatus;
}

export interface OwnerSubscriptionResponse {
  userId: string;
  planMode: PlanMode;
  planTier?: PlanTier;
  status: SubscriptionStatus;
  billingInterval?: BillingInterval;
  lockedMonthlyAmountCents?: number;
}

export type { FeatureCatalogItem };
