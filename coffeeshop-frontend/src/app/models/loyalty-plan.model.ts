export type LoyaltyPlanType = 'BASIC' | 'PREMIUM' | 'VIP';

export const LOYALTY_PLAN_TYPES: { value: LoyaltyPlanType; label: string }[] = [
  { value: 'BASIC', label: 'Basic' },
  { value: 'PREMIUM', label: 'Premium' },
  { value: 'VIP', label: 'VIP' },
];

export interface LoyaltyPlanResponseDto {
  id: string;
  name: string;
  description: string;
  type: LoyaltyPlanType | string;
}

export interface LoyaltyPlanCreateRequest {
  name: string;
  description: string;
  type: LoyaltyPlanType | string;
}
