import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { RoleResponseDto, RoleCreateRequest } from '../models/role.model';

@Injectable({ providedIn: 'root' })
export class RoleService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v1/role`;

  getAll(): Observable<RoleResponseDto[]> {
    return this.http.get<RoleResponseDto[]>(this.base);
  }

  getById(id: string): Observable<RoleResponseDto> {
    return this.http.get<RoleResponseDto>(`${this.base}/${id}`);
  }

  create(req: RoleCreateRequest): Observable<RoleResponseDto> {
    return this.http.post<RoleResponseDto>(this.base, req);
  }

  update(id: string, req: RoleCreateRequest): Observable<RoleResponseDto> {
    return this.http.put<RoleResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }
}
