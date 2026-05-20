import {
  ChangeDetectionStrategy,
  Component,
  forwardRef,
  input,
  signal,
} from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';

@Component({
  selector: 'app-star-rating',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => StarRatingComponent),
      multi: true,
    },
  ],
  template: `
    <div
      class="star-rating"
      [class.star-rating--readonly]="readonly()"
      role="group"
      [attr.aria-label]="readonly() ? rating() + ' out of 5 stars' : 'Rating'">
      @for (star of stars; track star) {
        <button
          type="button"
          class="star"
          [class.star--filled]="star <= displayValue()"
          [disabled]="readonly()"
          [attr.aria-label]="star + ' star' + (star === 1 ? '' : 's')"
          (click)="select(star)"
          (mouseenter)="onHover(star)"
          (mouseleave)="onHoverEnd()">
          ★
        </button>
      }
    </div>
  `,
  styles: `
    .star-rating {
      display: inline-flex;
      gap: 0.125rem;
    }

    .star {
      background: none;
      border: none;
      padding: 0;
      font-size: 1.25rem;
      line-height: 1;
      color: #4b5563;
      cursor: pointer;
      transition: color 0.15s ease, transform 0.1s ease;
    }

    .star--filled {
      color: #fbbf24;
    }

    .star-rating--readonly .star {
      cursor: default;
    }

    .star-rating:not(.star-rating--readonly) .star:hover,
    .star-rating:not(.star-rating--readonly) .star:focus-visible {
      color: #fcd34d;
      transform: scale(1.05);
    }

    .star:disabled {
      cursor: default;
    }
  `,
})
export class StarRatingComponent implements ControlValueAccessor {
  readonly readonly = input(false);
  readonly rating = input(0);

  readonly stars = [1, 2, 3, 4, 5] as const;

  private readonly value = signal(0);
  private readonly hoverValue = signal(0);
  private onChange: (value: number) => void = () => {};
  private onTouched: () => void = () => {};

  displayValue(): number {
    if (this.readonly()) {
      return this.rating();
    }
    const hover = this.hoverValue();
    if (hover > 0) {
      return hover;
    }
    return this.value();
  }

  select(star: number): void {
    if (this.readonly()) {
      return;
    }
    this.value.set(star);
    this.onChange(star);
    this.onTouched();
  }

  onHover(star: number): void {
    if (this.readonly()) {
      return;
    }
    this.hoverValue.set(star);
  }

  onHoverEnd(): void {
    this.hoverValue.set(0);
  }

  writeValue(value: number | null): void {
    this.value.set(value ?? 0);
  }

  registerOnChange(fn: (value: number) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    void isDisabled;
  }
}
