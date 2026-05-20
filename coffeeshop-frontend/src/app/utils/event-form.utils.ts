import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function futureDateValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value as string;
    if (!value) return null;
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) return { invalidDate: true };
    if (parsed <= new Date()) return { pastDate: true };
    return null;
  };
}

export function normalizeDateTimeLocal(value: string): string {
  if (!value) return '';
  if (value.includes('T')) {
    return value.length >= 16 ? value.slice(0, 16) : value;
  }
  return `${value}T00:00`;
}
