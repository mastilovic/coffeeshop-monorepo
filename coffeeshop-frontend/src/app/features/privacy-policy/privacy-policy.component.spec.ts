import { TestBed } from '@angular/core/testing';
import { provideRouter, Router } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { of } from 'rxjs';
import { routes } from '../../app.routes';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';

describe('Privacy policy public page', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      providers: [
        provideRouter(routes),
        { provide: AuthService, useValue: { isAuthenticated: () => false } },
        { provide: ProfileService, useValue: { getProfile: vi.fn(() => of({})) } },
      ],
    }).compileComponents();
  });

  it('shows Find policy topics at /privacy-policy without auth', async () => {
    const harness = await RouterTestingHarness.create();
    await harness.navigateByUrl('/privacy-policy');

    const router = TestBed.inject(Router);
    expect(router.url).toBe('/privacy-policy');

    const text = harness.routeNativeElement?.textContent ?? '';
    expect(text).toContain('Find');
    expect(text.toLowerCase()).toContain('keycloak');
    expect(text.toLowerCase()).toContain('reservation');
    expect(text.toLowerCase()).toMatch(/billing|subscription/);
  });

  it('still shows the policy when the visitor is signed in', async () => {
    TestBed.resetTestingModule();
    await TestBed.configureTestingModule({
      providers: [
        provideRouter(routes),
        { provide: AuthService, useValue: { isAuthenticated: () => true } },
        { provide: ProfileService, useValue: { getProfile: vi.fn(() => of({})) } },
      ],
    }).compileComponents();

    const harness = await RouterTestingHarness.create();
    await harness.navigateByUrl('/privacy-policy');

    const router = TestBed.inject(Router);
    expect(router.url).toBe('/privacy-policy');
    expect(harness.routeNativeElement?.textContent ?? '').toContain('Privacy Policy');
  });
});
