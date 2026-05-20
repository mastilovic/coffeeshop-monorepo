export type MenuItemType = 'FOOD' | 'DRINK' | 'DESSERT' | 'OTHER';

export const MENU_ITEM_TYPES: { value: MenuItemType; label: string }[] = [
  { value: 'FOOD', label: 'Food' },
  { value: 'DRINK', label: 'Drink' },
  { value: 'DESSERT', label: 'Dessert' },
  { value: 'OTHER', label: 'Other' },
];

export type MenuCurrency = 'RSD' | 'EUR' | 'USD';

export const MENU_CURRENCIES: { value: MenuCurrency; label: string }[] = [
  { value: 'RSD', label: 'RSD' },
  { value: 'EUR', label: 'EUR' },
  { value: 'USD', label: 'USD' },
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
  priceCurrency: MenuCurrency;
  imageUrl: string;
  menuId: string;
  itemType: MenuItemType;
}

export interface MenuItemCreateRequest {
  name: string;
  description: string;
  price: number;
  priceCurrency: MenuCurrency;
  imageUrl: string;
  menuId: string;
  itemType: MenuItemType;
}

export interface MenuCreateRequest {
  label?: string;
}
