import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, switchMap, map } from 'rxjs';
import { environment } from '../../environments/environment';
import { ShopResponseDto, ShopCreateRequest, ShopSearchParams, ShopListPage } from '../models/shop.model';
import { ProfileService } from './profile.service';

@Injectable({ providedIn: 'root' })
export class ShopService {
  private readonly http = inject(HttpClient);
  private readonly profileService = inject(ProfileService);
  private readonly base = `${environment.apiUrl}/api/v1/shop`;

  getAll(): Observable<ShopResponseDto[]> {
    return this.http.get<ShopResponseDto[]>(this.base);
  }

  search(params: ShopSearchParams = {}): Observable<ShopListPage> {
    const httpParams: Record<string, string> = {
      page: String(params.page ?? 0),
      size: String(params.size ?? 10),
    };
    if (params.q?.trim()) {
      httpParams['q'] = params.q.trim();
    }
    return this.http.get<ShopListPage>(this.base, { params: httpParams });
  }

  getMine(): Observable<ShopResponseDto[]> {
    return this.http.get<ShopResponseDto[]>(`${this.base}/mine`);
  }

  getById(id: string): Observable<ShopResponseDto> {
    return this.http.get<ShopResponseDto>(`${this.base}/${id}`);
  }

  create(req: ShopCreateRequest): Observable<ShopResponseDto> {
    return this.http.post<ShopResponseDto>(this.base, req);
  }

  update(id: string, req: ShopCreateRequest): Observable<ShopResponseDto> {
    return this.http.put<ShopResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }

  addFavourite(shopId: string): Observable<ShopResponseDto> {
    return this.http.post<ShopResponseDto>(`${this.base}/${shopId}/favourite`, null).pipe(
      switchMap(shop => this.profileService.getProfile().pipe(map(() => shop))),
    );
  }

  removeFavourite(shopId: string): Observable<ShopResponseDto> {
    return this.http.delete<ShopResponseDto>(`${this.base}/${shopId}/favourite`).pipe(
      switchMap(shop => this.profileService.getProfile().pipe(map(() => shop))),
    );
  }
}
