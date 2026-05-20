import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { TableResponseDto, TableCreateRequest } from '../models/table.model';

@Injectable({ providedIn: 'root' })
export class TableService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v1/table`;

  getAll(): Observable<TableResponseDto[]> {
    return this.http.get<TableResponseDto[]>(this.base);
  }

  getById(id: string): Observable<TableResponseDto> {
    return this.http.get<TableResponseDto>(`${this.base}/${id}`);
  }

  create(req: TableCreateRequest): Observable<TableResponseDto> {
    return this.http.post<TableResponseDto>(this.base, req);
  }

  update(id: string, req: TableCreateRequest): Observable<TableResponseDto> {
    return this.http.put<TableResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }
}
