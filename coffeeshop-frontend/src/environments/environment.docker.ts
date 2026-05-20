import type { Environment } from './environment.model';

export const environment: Environment = {
  production: true,
  apiUrl: '',
  /** Proxied by nginx to backend POST /login, /register, /auth/* (avoids clashing with SPA routes). */
  authApiUrl: '/api',
  /** Proxied by nginx to backend GET /profile (avoids clashing with SPA route /profile). */
  profileUrl: '/api/profile',
};
