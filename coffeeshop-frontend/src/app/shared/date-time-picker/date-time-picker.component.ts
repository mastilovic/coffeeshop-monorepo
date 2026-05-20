import {
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  forwardRef,
  HostListener,
  inject,
  input,
  signal,
  computed,
} from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import {
  buildCalendarDays,
  CalendarDay,
  defaultFutureTimeForToday,
  formatDisplay,
  parseIsoDate,
  startOfMonth,
  todayIso,
} from '../calendar/calendar-date.utils';

@Component({
  selector: 'app-date-time-picker',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => DateTimePickerComponent),
      multi: true,
    },
  ],
  template: `
    <div class="date-time-picker">
      <div class="date-range-picker date-time-picker-calendar">
        <button
          type="button"
          class="btn btn-secondary date-range-trigger"
          [attr.aria-expanded]="open()"
          aria-haspopup="dialog"
          (click)="toggleOpen($event)"
        >
          {{ triggerLabel() }}
        </button>

        @if (open()) {
          <div
            class="date-range-popover"
            role="dialog"
            aria-label="Select event date"
            (mousedown)="$event.stopPropagation()"
          >
            <div class="date-range-header">
              <button type="button" class="date-range-nav" aria-label="Previous month" (click)="prevMonth()">
                ‹
              </button>
              <span class="date-range-month">{{ monthLabel() }}</span>
              <button type="button" class="date-range-nav" aria-label="Next month" (click)="nextMonth()">
                ›
              </button>
            </div>

            <div class="date-range-weekdays">
              @for (label of weekdayLabels; track label) {
                <span class="date-range-weekday">{{ label }}</span>
              }
            </div>

            <div class="date-range-grid">
              @for (day of calendarDays(); track day.iso + day.inCurrentMonth) {
                <button
                  type="button"
                  class="date-range-day"
                  [class.outside-month]="!day.inCurrentMonth"
                  [class.today]="isToday(day)"
                  [class.selected]="isSelected(day)"
                  [disabled]="!day.inCurrentMonth || isBeforeMin(day)"
                  (click)="onDayClick(day)"
                >
                  {{ day.date.getDate() }}
                </button>
              }
            </div>

            <div class="date-range-footer">
              @if (dateIso()) {
                <button type="button" class="date-range-clear" (click)="clearDate()">Clear</button>
              }
            </div>
          </div>
        }
      </div>

      <input
        type="time"
        class="form-input date-time-picker-time"
        [value]="timeHHmm()"
        [attr.min]="timeInputMin()"
        [disabled]="disabled() || !dateIso()"
        (input)="onTimeInput($event)"
        (blur)="onTouched()"
      />
    </div>
  `,
})
export class DateTimePickerComponent implements ControlValueAccessor {
  private readonly elementRef = inject(ElementRef);

  readonly minDate = input<string | null>(null);
  readonly placeholder = input('Select date');

  readonly open = signal(false);
  readonly viewMonth = signal(startOfMonth(new Date()));
  readonly dateIso = signal('');
  readonly timeHHmm = signal('12:00');
  readonly disabled = signal(false);

  readonly weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  readonly triggerLabel = computed(() => {
    const date = this.dateIso();
    if (!date) return this.placeholder();
    return formatDisplay(date);
  });

  readonly monthLabel = computed(() => {
    const d = this.viewMonth();
    return d.toLocaleDateString(undefined, { month: 'long', year: 'numeric' });
  });

  readonly calendarDays = computed(() => buildCalendarDays(this.viewMonth()));

  readonly timeInputMin = computed(() => {
    const min = this.minDate();
    const date = this.dateIso();
    if (!min || date !== todayIso()) return null;
    return defaultFutureTimeForToday();
  });

  private onChange: (value: string) => void = () => {};
  private onTouchedCallback: () => void = () => {};

  @HostListener('document:keydown.escape')
  onEscape(): void {
    if (this.open()) {
      this.open.set(false);
    }
  }

  @HostListener('document:mousedown', ['$event'])
  onDocumentMouseDown(event: MouseEvent): void {
    if (!this.open()) return;
    const target = event.target as Node;
    if (!this.elementRef.nativeElement.contains(target)) {
      this.open.set(false);
    }
  }

  writeValue(value: string | null): void {
    if (!value) {
      this.dateIso.set('');
      this.timeHHmm.set('12:00');
      return;
    }
    const [datePart, timePart] = value.includes('T') ? value.split('T') : [value, '12:00'];
    this.dateIso.set(datePart);
    this.timeHHmm.set(timePart.length >= 5 ? timePart.slice(0, 5) : '12:00');
  }

  registerOnChange(fn: (value: string) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouchedCallback = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled.set(isDisabled);
  }

  onTouched(): void {
    this.onTouchedCallback();
  }

  toggleOpen(event: MouseEvent): void {
    if (this.disabled()) return;
    event.stopPropagation();
    const next = !this.open();
    this.open.set(next);
    if (next) {
      const anchor = this.dateIso() || todayIso();
      this.viewMonth.set(startOfMonth(parseIsoDate(anchor)));
    }
  }

  prevMonth(): void {
    const current = this.viewMonth();
    this.viewMonth.set(new Date(current.getFullYear(), current.getMonth() - 1, 1));
  }

  nextMonth(): void {
    const current = this.viewMonth();
    this.viewMonth.set(new Date(current.getFullYear(), current.getMonth() + 1, 1));
  }

  onDayClick(day: CalendarDay): void {
    if (!day.inCurrentMonth || this.isBeforeMin(day)) return;

    const iso = day.iso;
    let time = this.timeHHmm();
    if (!time || time === '12:00') {
      const min = this.minDate();
      time = min && iso === min ? defaultFutureTimeForToday() : '12:00';
    } else if (this.minDate() === todayIso() && iso === todayIso()) {
      const minTime = defaultFutureTimeForToday();
      if (time < minTime) {
        time = minTime;
      }
    }

    this.dateIso.set(iso);
    this.timeHHmm.set(time);
    this.open.set(false);
    this.emitValue();
    this.onTouchedCallback();
  }

  onTimeInput(event: Event): void {
    const value = (event.target as HTMLInputElement).value;
    this.timeHHmm.set(value);
    this.emitValue();
  }

  clearDate(): void {
    this.dateIso.set('');
    this.timeHHmm.set('12:00');
    this.open.set(false);
    this.onChange('');
    this.onTouchedCallback();
  }

  isToday(day: CalendarDay): boolean {
    return day.iso === todayIso();
  }

  isSelected(day: CalendarDay): boolean {
    return day.iso === this.dateIso();
  }

  isBeforeMin(day: CalendarDay): boolean {
    const min = this.minDate();
    if (!min) return false;
    return day.iso < min;
  }

  private emitValue(): void {
    const date = this.dateIso();
    if (!date) {
      this.onChange('');
      return;
    }
    this.onChange(`${date}T${this.timeHHmm()}`);
  }
}
