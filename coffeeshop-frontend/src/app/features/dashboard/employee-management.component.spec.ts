import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { signal } from '@angular/core';
import { of } from 'rxjs';
import { EmployeeManagementComponent } from './employee-management.component';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';
import { ShopEmployeeService } from '../../services/shop-employee.service';
import { SubscriptionService } from '../../services/subscription.service';
import { UserService } from '../../services/user.service';
import { UserProfileResponseDto } from '../../models/user.model';
import { ShopEmployeeDto } from '../../models/shop-employee.model';

describe('EmployeeManagementComponent', () => {
  let fixture: ComponentFixture<EmployeeManagementComponent>;
  let canUseFeatureMock: ReturnType<typeof vi.fn>;
  let getLimitMock: ReturnType<typeof vi.fn>;

  const ownerProfile: UserProfileResponseDto = {
    id: 'owner-1',
    name: 'Owner',
    username: 'owner',
    email: 'owner@example.com',
    userType: 'SHOP_OWNER',
    roles: [],
    favouriteShops: [],
    reviews: [],
    reservations: [],
  };

  const ownerEmployee: ShopEmployeeDto = {
    shopId: 'shop-1',
    userId: 'owner-1',
    name: 'Owner',
    username: 'owner',
    email: 'owner@example.com',
    isOwner: true,
  };

  beforeEach(async () => {
    canUseFeatureMock = vi.fn((featureKey: string) => featureKey === 'employee_assign');
    getLimitMock = vi.fn(() => ({ used: 1, max: 3 }));

    await TestBed.configureTestingModule({
      imports: [EmployeeManagementComponent],
      providers: [
        provideRouter([]),
        {
          provide: ProfileService,
          useValue: { currentUser: signal(ownerProfile) },
        },
        {
          provide: AuthService,
          useValue: { isAdmin: vi.fn(() => false) },
        },
        {
          provide: ShopEmployeeService,
          useValue: {
            getEmployees: vi.fn(() => of([ownerEmployee])),
            assignEmployee: vi.fn(() => of(void 0)),
            removeEmployee: vi.fn(() => of(void 0)),
          },
        },
        {
          provide: UserService,
          useValue: { list: vi.fn(() => of({ content: [], page: 0, size: 10, totalElements: 0, totalPages: 1 })) },
        },
        {
          provide: SubscriptionService,
          useValue: {
            canUseFeature: canUseFeatureMock,
            getLimit: getLimitMock,
          },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(EmployeeManagementComponent);
    fixture.componentRef.setInput('shopId', 'shop-1');
    fixture.detectChanges();
  });

  it('shows employee search when entitled', () => {
    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).toContain('1 / 3 employees');
    expect(element.textContent).toContain('@owner');
    expect(element.textContent).not.toContain('owner@example.com');
    expect(element.querySelector('input.search-input')?.getAttribute('placeholder')).toBe(
      'Search users by name or username...',
    );
    expect(element.querySelector('a[routerlink="/profile/billing"]')).toBeNull();
  });

  it('shows upgrade link on Starter without employee_assign', () => {
    canUseFeatureMock.mockImplementation(() => false);
    fixture = TestBed.createComponent(EmployeeManagementComponent);
    fixture.componentRef.setInput('shopId', 'shop-1');
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.querySelector('input.search-input')).toBeNull();
    expect(element.querySelector('a[routerlink="/profile/billing"]')?.textContent).toContain('Upgrade to Growth');
  });
});
