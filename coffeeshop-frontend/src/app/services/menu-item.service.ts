import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { MenuItemResponseDto, MenuItemCreateRequest } from '../models/menu.model';

@Injectable({ providedIn: 'root' })
export class MenuItemService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v2/menu-item`;

  getAll(): Observable<MenuItemResponseDto[]> {
    return this.http.get<MenuItemResponseDto[]>(this.base);
  }

  getById(id: string): Observable<MenuItemResponseDto> {
    return this.http.get<MenuItemResponseDto>(`${this.base}/${id}`);
  }

  create(req: MenuItemCreateRequest): Observable<MenuItemResponseDto> {
    return this.http.post<MenuItemResponseDto>(this.base, req);
  }

  update(id: string, req: MenuItemCreateRequest): Observable<MenuItemResponseDto> {
    return this.http.put<MenuItemResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }
}
