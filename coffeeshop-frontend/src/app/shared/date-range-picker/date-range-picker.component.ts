import {
  Component,
  ElementRef,
  HostListener,
  inject,
  input,
  output,
  signal,
  computed,
  ChangeDetectionStrategy,
} from '@angular/core';
import {
  buildCalendarDays,
  CalendarDay,
  formatDisplay,
  parseIsoDate,
  startOfMonth,
  todayIso,
} from '../calendar/calendar-date.utils';

export interface DateRangeValue {
  dateFrom: string;
  dateTo: string;
}

@Component({
  selector: 'app-date-range-picker',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="date-range-picker">
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
          aria-label="Select date range"
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
                [class.in-range]="isInRange(day)"
                [disabled]="!day.inCurrentMonth"
                (click)="onDayClick(day)"
              >
                {{ day.date.getDate() }}
              </button>
            }
          </div>

          <div class="date-range-footer">
            @if (dateFrom() || dateTo() || pendingFrom()) {
              <button type="button" class="date-range-clear" (click)="clearRange()">Clear</button>
            }
            @if (pendingFrom()) {
              <span class="date-range-hint">Select end date</span>
            }
          </div>
        </div>
      }
    </div>
  `,
})
export class DateRangePickerComponent {
  private readonly elementRef = inject(ElementRef);

  readonly dateFrom = input('');
  readonly dateTo = input('');
  readonly placeholder = input('Filter by date');

  readonly rangeChange = output<DateRangeValue>();

  readonly open = signal(false);
  readonly viewMonth = signal(startOfMonth(new Date()));
  readonly pendingFrom = signal<string | null>(null);
  readonly pendingTo = signal<string | null>(null);

  readonly weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  readonly triggerLabel = computed(() => {
    const from = this.dateFrom();
    const to = this.dateTo();
    if (from && to) {
      return `${formatDisplay(from)} – ${formatDisplay(to)}`;
    }
    if (from) {
      return `From ${formatDisplay(from)}`;
    }
    return this.placeholder();
  });

  readonly monthLabel = computed(() => {
    const d = this.viewMonth();
    return d.toLocaleDateString(undefined, { month: 'long', year: 'numeric' });
  });

  readonly calendarDays = computed(() => buildCalendarDays(this.viewMonth()));

  @HostListener('document:keydown.escape')
  onEscape(): void {
    if (this.open()) {
      this.open.set(false);
      this.resetPending();
    }
  }

  @HostListener('document:mousedown', ['$event'])
  onDocumentMouseDown(event: MouseEvent): void {
    if (!this.open()) return;
    const target = event.target as Node;
    if (!this.elementRef.nativeElement.contains(target)) {
      this.open.set(false);
      this.resetPending();
    }
  }

  toggleOpen(event: MouseEvent): void {
    event.stopPropagation();
    const next = !this.open();
    this.open.set(next);
    if (next) {
      this.resetPending();
      const anchor = this.dateFrom() || todayIso();
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
    if (!day.inCurrentMonth) return;

    const iso = day.iso;
    const pendingStart = this.pendingFrom();

    if (!pendingStart) {
      this.pendingFrom.set(iso);
      this.pendingTo.set(null);
      return;
    }

    let from = pendingStart;
    let to = iso;
    if (to < from) {
      [from, to] = [to, from];
    }

    this.pendingFrom.set(null);
    this.pendingTo.set(null);
    this.open.set(false);
    this.rangeChange.emit({ dateFrom: from, dateTo: to });
  }

  clearRange(): void {
    this.pendingFrom.set(null);
    this.pendingTo.set(null);
    this.open.set(false);
    this.rangeChange.emit({ dateFrom: '', dateTo: '' });
  }

  isToday(day: CalendarDay): boolean {
    return day.iso === todayIso();
  }

  isSelected(day: CalendarDay): boolean {
    const iso = day.iso;
    const pendingStart = this.pendingFrom();
    if (pendingStart) {
      return iso === pendingStart;
    }
    return iso === this.dateFrom() || iso === this.dateTo();
  }

  isInRange(day: CalendarDay): boolean {
    if (this.pendingFrom()) {
      return false;
    }
    const from = this.dateFrom();
    const to = this.dateTo();
    if (!from || !to) return false;
    const iso = day.iso;
    return iso > from && iso < to;
  }

  private resetPending(): void {
    this.pendingFrom.set(null);
    this.pendingTo.set(null);
  }
}
