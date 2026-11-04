import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';
import { LoginComponent } from './login.component';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';

describe('LoginComponent brand', () => {
  let fixture: ComponentFixture<LoginComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LoginComponent],
      providers: [
        provideRouter([]),
        { provide: AuthService, useValue: { login: vi.fn(() => of({})) } },
        { provide: ProfileService, useValue: { getProfile: vi.fn(() => of({})) } },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(LoginComponent);
    fixture.detectChanges();
  });

  it('shows the Find account login subtitle', () => {
    const subtitle = fixture.nativeElement.querySelector('.auth-subtitle') as HTMLElement;
    expect(subtitle.textContent?.trim()).toBe('Sign in to your Find account');
  });
});
