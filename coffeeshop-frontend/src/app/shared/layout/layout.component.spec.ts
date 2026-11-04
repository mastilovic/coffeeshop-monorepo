import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { signal } from '@angular/core';
import { of } from 'rxjs';
import { LayoutComponent } from './layout.component';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { SubscriptionService } from '../../services/subscription.service';

describe('LayoutComponent brand', () => {
  let fixture: ComponentFixture<LayoutComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LayoutComponent],
      providers: [
        provideRouter([]),
        {
          provide: AuthService,
          useValue: {
            isAuthenticated: vi.fn(() => false),
            logout: vi.fn(),
          },
        },
        {
          provide: ProfileService,
          useValue: {
            currentUser: signal(null),
            getProfile: vi.fn(() => of({})),
            clearProfile: vi.fn(),
          },
        },
        {
          provide: SubscriptionService,
          useValue: { clear: vi.fn() },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(LayoutComponent);
    fixture.detectChanges();
  });

  it('shows the full product name in the sidebar brand', () => {
    const brand = fixture.nativeElement.querySelector('.sidebar-brand') as HTMLElement;
    expect(brand.textContent?.trim()).toBe('Find: Cafes & Events');
  });
});
