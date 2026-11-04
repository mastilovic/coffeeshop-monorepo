import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { of } from 'rxjs';
import { RegisterComponent } from './register.component';
import { AuthService } from '../../services/auth.service';
import { ProfileService } from '../../services/profile.service';

describe('RegisterComponent brand', () => {
  let fixture: ComponentFixture<RegisterComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RegisterComponent],
      providers: [
        provideRouter([]),
        { provide: AuthService, useValue: { register: vi.fn(() => of({})) } },
        { provide: ProfileService, useValue: { getProfile: vi.fn(() => of({})) } },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(RegisterComponent);
    fixture.detectChanges();
  });

  it('shows the Find register subtitle', () => {
    const subtitle = fixture.nativeElement.querySelector('.auth-subtitle') as HTMLElement;
    expect(subtitle.textContent?.trim()).toBe('Join Find today');
  });
});
