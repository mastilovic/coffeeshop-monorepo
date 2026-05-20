import { UserSummaryDto } from './user.model';
import { MenuResponseDto } from './menu.model';
import { LoyaltyPlanResponseDto } from './loyalty-plan.model';
import { EventResponseDto } from './event.model';
import { TableResponseDto } from './table.model';
import { ReviewResponseDto } from './review.model';
import { ContactResponseDto } from './contact.model';

export interface ShopResponseDto {
  id: string;
  name: string;
  address: string;
  city: string;
  phoneNumber: string;
  email: string;
  createdBy: UserSummaryDto;
  users: UserSummaryDto[];
  currentMenu: MenuResponseDto | null;
  menuHistory: MenuResponseDto[];
  loyaltyPlan: LoyaltyPlanResponseDto;
  events: EventResponseDto[];
  tables: TableResponseDto[];
  reviews: ReviewResponseDto[];
  reviewCount: number;
  averageRating: number | null;
  contacts: ContactResponseDto[];
  favouriteByCurrentUser?: boolean;
  memberCount?: number;
}

export interface ShopSummaryDto {
  id: string;
  name: string;
  address: string;
  city: string;
  phoneNumber: string;
  email: string;
}

export interface ShopCreateRequest {
  name: string;
  address: string;
  city: string;
  phoneNumber: string;
  email?: string;
  createdByUserId?: string;
  loyaltyPlanId?: string;
}
