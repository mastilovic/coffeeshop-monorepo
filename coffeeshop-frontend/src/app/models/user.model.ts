import { RoleResponseDto } from './role.model';
import { ShopSummaryDto } from './shop.model';
import { ReviewResponseDto } from './review.model';
import { ReservationResponseDto } from './reservation.model';
import { PageResponseDto } from './event.model';

export interface UserListItemDto {
  id: string;
  name: string;
  username: string;
  userType: 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN';
  roles: RoleResponseDto[];
}

export type UserListPage = PageResponseDto<UserListItemDto>;

export interface UserResponseDto {
  id: string;
  name: string;
  username: string;
  userType: 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN';
  roles: RoleResponseDto[];
  favouriteShops: ShopSummaryDto[];
  reviews: ReviewResponseDto[];
  reservations: ReservationResponseDto[];
}

export interface UserProfileResponseDto {
  id: string;
  name: string;
  username: string;
  email: string;
  userType: 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN';
  roles: RoleResponseDto[];
  favouriteShops: ShopSummaryDto[];
  reviews: ReviewResponseDto[];
  reservations: ReservationResponseDto[];
}

export interface UserSummaryDto {
  id: string;
  name: string;
  username: string;
}

export interface UserCreateRequest {
  name: string;
  username: string;
  email: string;
  password?: string;
  userType: 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN';
  roleIds: string[];
}

export interface UserUpdateRequest {
  name: string;
  username?: string;
  email?: string;
  password?: string;
  userType: 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN';
  roleIds: string[];
  favouriteShopIds?: string[];
}

export interface RegisterRequest {
  name: string;
  username: string;
  email: string;
  password: string;
  role: 'customer' | 'shop_owner';
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface TokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  token_type: string;
}
