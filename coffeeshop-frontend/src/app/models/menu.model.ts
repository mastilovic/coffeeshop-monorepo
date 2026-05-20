export type MenuItemType = 'FOOD' | 'DRINK' | 'DESSERT' | 'OTHER';

export const MENU_ITEM_TYPES: { value: MenuItemType; label: string }[] = [
  { value: 'FOOD', label: 'Food' },
  { value: 'DRINK', label: 'Drink' },
  { value: 'DESSERT', label: 'Dessert' },
  { value: 'OTHER', label: 'Other' },
];

export interface MenuResponseDto {
  id: string;
  shopId?: string;
  label?: string;
  createdAt?: string;
  current?: boolean;
  items: MenuItemResponseDto[];
}

export interface MenuItemResponseDto {
  id: string;
  name: string;
  description: string;
  price: number;
  priceCurrency: string;
  imageUrl: string;
  menuId: string;
  itemType: MenuItemType;
}

export interface MenuItemCreateRequest {
  name: string;
  description: string;
  price: number;
  priceCurrency: string;
  imageUrl: string;
  menuId: string;
  itemType: MenuItemType;
}

export interface MenuCreateRequest {
  label?: string;
}
