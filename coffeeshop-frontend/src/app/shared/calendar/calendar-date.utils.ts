export interface CalendarDay {
  date: Date;
  inCurrentMonth: boolean;
  iso: string;
}

export function buildCalendarDays(viewMonth: Date): CalendarDay[] {
  const year = viewMonth.getFullYear();
  const month = viewMonth.getMonth();
  const firstOfMonth = new Date(year, month, 1);
  const startOffset = firstOfMonth.getDay();
  const gridStart = new Date(year, month, 1 - startOffset);
  const days: CalendarDay[] = [];

  for (let i = 0; i < 42; i++) {
    const date = new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + i);
    days.push({
      date,
      inCurrentMonth: date.getMonth() === month,
      iso: toIsoDate(date),
    });
  }

  return days;
}

export function startOfMonth(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), 1);
}

export function parseIsoDate(iso: string): Date {
  const [y, m, d] = iso.split('-').map(Number);
  return new Date(y, m - 1, d);
}

export function toIsoDate(date: Date): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

export function todayIso(): string {
  return toIsoDate(new Date());
}

export function formatDisplay(iso: string): string {
  const date = parseIsoDate(iso);
  return date.toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' });
}

export function formatTimeHHmm(date: Date): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

/** Next whole hour from now, or one minute ahead if that is still in the past. */
export function defaultFutureTimeForToday(): string {
  const now = new Date();
  const next = new Date(now);
  next.setMinutes(0, 0, 0);
  next.setHours(next.getHours() + 1);
  if (next <= now) {
    next.setTime(now.getTime() + 60_000);
  }
  return formatTimeHHmm(next);
}
