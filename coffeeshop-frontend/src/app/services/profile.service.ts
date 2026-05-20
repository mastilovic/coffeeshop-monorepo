import { inject, Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../environments/environment';
import { UserResponseDto } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class ProfileService {
  private readonly http = inject(HttpClient);

  readonly currentUser = signal<UserResponseDto | null>(null);

  getProfile(): Observable<UserResponseDto> {
    const url = environment.profileUrl ?? `${environment.apiUrl}/profile`;
    return this.http.get<UserResponseDto>(url)
      .pipe(tap(user => this.currentUser.set(user)));
  }

  clearProfile(): void {
    this.currentUser.set(null);
  }
}
