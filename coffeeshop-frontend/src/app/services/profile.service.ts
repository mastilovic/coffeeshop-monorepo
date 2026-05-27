import { inject, Injectable, signal } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, catchError, tap, throwError } from 'rxjs';
import { environment } from '../../environments/environment';
import { UserProfileResponseDto } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class ProfileService {
  private readonly http = inject(HttpClient);

  readonly currentUser = signal<UserProfileResponseDto | null>(null);

  getProfile(): Observable<UserProfileResponseDto> {
    const url = `${environment.apiUrl}/api/v2/profile`;
    return this.http.get<UserProfileResponseDto>(url).pipe(
      tap(user => this.currentUser.set(user)),
      catchError((error: HttpErrorResponse) => {
        if (error.status === 401) {
          this.currentUser.set(null);
        }
        return throwError(() => error);
      }),
    );
  }

  clearProfile(): void {
    this.currentUser.set(null);
  }
}
