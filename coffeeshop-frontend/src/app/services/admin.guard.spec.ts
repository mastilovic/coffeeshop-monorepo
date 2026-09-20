import { TestBed } from '@angular/core/testing';
import { Router, UrlTree } from '@angular/router';
import { signal } from '@angular/core';
import { adminGuard } from './admin.guard';
import { AuthService } from './auth.service';

describe('adminGuard', () => {
  let router: { createUrlTree: ReturnType<typeof vi.fn> };
  let isAdmin: ReturnType<typeof signal<boolean>>;

  beforeEach(() => {
    isAdmin = signal(false);
    router = {
      createUrlTree: vi.fn((commands: string[]) => ({ commands }) as unknown as UrlTree),
    };

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: { isAdmin } },
        { provide: Router, useValue: router },
      ],
    });
  });

  it('allows admin users', () => {
    isAdmin.set(true);
    const result = TestBed.runInInjectionContext(() => adminGuard({} as never, {} as never));
    expect(result).toBe(true);
  });

  it('redirects non-admin users to dashboard', () => {
    isAdmin.set(false);
    const result = TestBed.runInInjectionContext(() => adminGuard({} as never, {} as never));
    expect(router.createUrlTree).toHaveBeenCalledWith(['/dashboard']);
    expect(result).toEqual({ commands: ['/dashboard'] });
  });
});
