import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { ShopEmployeeDto, AssignEmployeeRequest } from '../models/shop-employee.model';
import { ShopResponseDto } from '../models/shop.model';

@Injectable({ providedIn: 'root' })
export class ShopEmployeeService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v2/shop-employees`;

  getEmployees(shopId: string): Observable<ShopEmployeeDto[]> {
    return this.http.get<ShopEmployeeDto[]>(`${environment.apiUrl}/api/v2/shop/${shopId}/employees`);
  }

  assignEmployee(req: AssignEmployeeRequest): Observable<ShopEmployeeDto> {
    return this.http.post<ShopEmployeeDto>(this.base, req);
  }

  removeEmployee(shopId: string, userId: string): Observable<void> {
    return this.http.delete<void>(this.base, {
      body: { shopId, userId },
    });
  }

  getMyEmployeeShops(): Observable<ShopResponseDto[]> {
    return this.http.get<ShopResponseDto[]>(`${this.base}/me`);
  }
}
