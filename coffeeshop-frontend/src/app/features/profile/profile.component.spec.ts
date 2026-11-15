import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';
import { ProfileComponent } from './profile.component';
import { ProfileService } from '../../services/profile.service';
import { UserService } from '../../services/user.service';
import { ShopService } from '../../services/shop.service';
import { UserProfileResponseDto } from '../../models/user.model';

describe('ProfileComponent privacy link', () => {
  let fixture: ComponentFixture<ProfileComponent>;

  const profile: UserProfileResponseDto = {
    id: 'user-1',
    name: 'Ada',
    username: 'ada',
    email: 'ada@example.com',
    userType: 'CUSTOMER',
    roles: [],
    favouriteShops: [],
    reviews: [],
    reservations: [],
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ProfileComponent],
      providers: [
        provideRouter([]),
        { provide: ProfileService, useValue: { getProfile: vi.fn(() => of(profile)) } },
        { provide: UserService, useValue: { update: vi.fn() } },
        { provide: ShopService, useValue: { getAll: vi.fn(() => of([])) } },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(ProfileComponent);
    fixture.detectChanges();
    await fixture.whenStable();
    fixture.detectChanges();
  });

  it('links to the privacy policy', () => {
    const link = fixture.nativeElement.querySelector('a[href="/privacy-policy"]') as HTMLAnchorElement | null;
    expect(link).toBeTruthy();
    expect(link!.textContent?.toLowerCase()).toContain('privacy');
  });
});
