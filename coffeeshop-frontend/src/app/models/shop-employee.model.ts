export interface ShopEmployeeDto {
  userId: string;
  shopId: string;
  name: string;
  username: string;
  email: string;
  isOwner: boolean;
}

export interface AssignEmployeeRequest {
  shopId: string;
  userId: string;
}
