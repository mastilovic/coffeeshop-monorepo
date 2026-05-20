export interface LoyaltyPlanResponseDto {
  id: string;
  name: string;
  description: string;
  type: string;
}

export interface LoyaltyPlanCreateRequest {
  name: string;
  description: string;
  type: string;
}
