import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { MenuCreateRequest, MenuResponseDto } from '../models/menu.model';

@Injectable({ providedIn: 'root' })
export class MenuService {
  private readonly http = inject(HttpClient);
  private readonly shopBase = `${environment.apiUrl}/api/v1/shop`;

  getMenusForShop(shopId: string): Observable<MenuResponseDto[]> {
    return this.http.get<MenuResponseDto[]>(`${this.shopBase}/${shopId}/menus`);
  }

  createForShop(shopId: string, body?: MenuCreateRequest): Observable<MenuResponseDto> {
    return this.http.post<MenuResponseDto>(`${this.shopBase}/${shopId}/menus`, body ?? {});
  }
}
