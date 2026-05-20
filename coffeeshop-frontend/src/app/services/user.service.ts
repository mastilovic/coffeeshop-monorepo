import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { UserResponseDto, UserCreateRequest, UserUpdateRequest } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class UserService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v1/user`;

  getAll(): Observable<UserResponseDto[]> {
    return this.http.get<UserResponseDto[]>(this.base);
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
