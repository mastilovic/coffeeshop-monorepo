import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { ContactResponseDto, ContactCreateRequest } from '../models/contact.model';

@Injectable({ providedIn: 'root' })
export class ContactService {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.apiUrl}/api/v1/contact`;

  getAll(): Observable<ContactResponseDto[]> {
    return this.http.get<ContactResponseDto[]>(this.base);
  }

  getById(id: string): Observable<ContactResponseDto> {
    return this.http.get<ContactResponseDto>(`${this.base}/${id}`);
  }

  create(req: ContactCreateRequest): Observable<ContactResponseDto> {
    return this.http.post<ContactResponseDto>(this.base, req);
  }

  update(id: string, req: ContactCreateRequest): Observable<ContactResponseDto> {
    return this.http.put<ContactResponseDto>(`${this.base}/${id}`, req);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${this.base}/${id}`);
  }
}
