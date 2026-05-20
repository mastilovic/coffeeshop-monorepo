export interface RoleResponseDto {
  id: string;
  name: string;
  type: 'USER' | 'ADMIN' | 'SHOP_OWNER';
}

export interface RoleCreateRequest {
  name: string;
  type: 'USER' | 'ADMIN' | 'SHOP_OWNER';
}
