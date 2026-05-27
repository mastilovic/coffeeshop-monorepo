import { inject, Injectable, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { catchError, Observable, switchMap, tap, throwError } from 'rxjs';
import { environment } from '../../environments/environment';
import { TokenResponse, LoginRequest, RegisterRequest, UserResponseDto } from '../models/user.model';

const ACCESS_TOKEN_KEY = 'coffeeshop_access_token';
const REFRESH_TOKEN_KEY = 'coffeeshop_refresh_token';

interface JwtPayload {
  sub: string;
  email?: string;
  preferred_username?: string;
  realm_access?: { roles: string[] };
  exp: number;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly authBase = `${environment.apiUrl}/api/v2/auth`;

  readonly accessToken = signal<string | null>(localStorage.getItem(ACCESS_TOKEN_KEY));
  readonly refreshTokenValue = signal<string | null>(localStorage.getItem(REFRESH_TOKEN_KEY));

  readonly isAuthenticated = computed(() => !!this.accessToken());

  readonly decodedToken = computed<JwtPayload | null>(() => {
    const token = this.accessToken();
    if (!token) return null;
    try {
      const payload = token.split('.')[1];
      return JSON.parse(atob(payload));
    } catch {
      return null;
    }
  });

  readonly realmRoles = computed<string[]>(() => {
    const decoded = this.decodedToken();
    return decoded?.realm_access?.roles ?? [];
  });

  readonly isAdmin = computed(() => this.realmRoles().includes('admin'));

  login(email: string, password: string): Observable<TokenResponse> {
    return this.http.post<TokenResponse>(`${this.authBase}/login`, { email, password } as LoginRequest)
      .pipe(tap(res => this.storeTokens(res)));
  }

  register(
    name: string,
    username: string,
    email: string,
    password: string,
    role: 'customer' | 'shop_owner',
  ): Observable<UserResponseDto> {
    return this.http.post<UserResponseDto>(`${this.authBase}/register`, {
      name,
      username,
      email,
      password,
      role,
    } as RegisterRequest);
  }

  registerAndLogin(
    name: string,
    username: string,
    email: string,
    password: string,
    role: 'customer' | 'shop_owner',
  ): Observable<TokenResponse> {
    return this.register(name, username, email, password, role).pipe(
      switchMap(() =>
        this.login(email, password).pipe(
          catchError(err => throwError(() => ({ ...err, registrationCompleted: true }))),
        ),
      ),
    );
  }

  refreshToken(): Observable<TokenResponse> {
    return this.http.post<TokenResponse>(`${this.authBase}/refresh`, {
      refresh_token: this.refreshTokenValue(),
    }).pipe(tap(res => this.storeTokens(res)));
  }

  logout(): void {
    const rt = this.refreshTokenValue();
    if (rt) {
      this.http.post(`${this.authBase}/logout`, { refresh_token: rt }).subscribe();
    }
    this.clearTokens();
    this.router.navigate(['/login']);
  }

  private storeTokens(res: TokenResponse): void {
    localStorage.setItem(ACCESS_TOKEN_KEY, res.access_token);
    localStorage.setItem(REFRESH_TOKEN_KEY, res.refresh_token);
    this.accessToken.set(res.access_token);
    this.refreshTokenValue.set(res.refresh_token);
  }

  private clearTokens(): void {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    this.accessToken.set(null);
    this.refreshTokenValue.set(null);
  }
}
