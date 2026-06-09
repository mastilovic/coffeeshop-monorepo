export interface ShopEmployeeDto {
  userId: string;
  shopId: string;
  name: string;
  email: string;
  isOwner: boolean;
}

export interface AssignEmployeeRequest {
  shopId: string;
  userId: string;
}
