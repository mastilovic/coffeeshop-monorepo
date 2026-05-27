import { inject, Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  UserResponseDto,
  UserCreateRequest,
  UserUpdateRequest,
  UserListPage,
} from '../models/user.model';

export interface UserListParams {
  q?: string;
  page: number;
  size: number;
}

@Injectable({ providedIn: 'root' })
export class UserService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v2/user`;

  getAll(): Observable<UserResponseDto[]> {
    return this.http.get<UserResponseDto[]>(this.base);
  }

  list(params: UserListParams): Observable<UserListPage> {
    let httpParams = new HttpParams()
      .set('page', String(params.page))
      .set('size', String(params.size));
    if (params.q) {
      httpParams = httpParams.set('q', params.q);
    }
    return this.http.get<UserListPage>(this.base, { params: httpParams });
  }

  getById(id: string): Observable<UserResponseDto> {
    return this.http.get<UserResponseDto>(`${this.base}/${id}`);
  }

  create(req: UserCreateRequest): Observable<UserResponseDto> {
    return this.http.post<UserResponseDto>(this.base, req);
  }

  update(id: string, req: UserUpdateRequest): Observable<UserResponseDto> {
    return this.http.put<UserResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }
}
