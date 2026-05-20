import {
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  forwardRef,
  inject,
  input,
  signal,
  computed,
} from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { FormSelectOption } from '../form-select/form-select-option.model';

@Component({
  selector: 'app-form-multi-select',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => FormMultiSelectComponent),
      multi: true,
    },
  ],
  template: `
    <div class="form-multi-select" (focusout)="onFocusOut($event)">
      <button
        type="button"
        class="form-input form-select-trigger"
        [disabled]="disabled()"
        [attr.aria-expanded]="dropdownOpen()"
        aria-haspopup="listbox"
        (click)="toggleDropdown()"
        (keydown)="onKeydown($event)">
        <span class="form-select-trigger-label" [class.form-select-trigger-label--placeholder]="selectedValues().length === 0">
          {{ triggerLabel() }}
        </span>
      </button>
      @if (dropdownOpen()) {
        <ul class="form-multi-select-dropdown" role="listbox" aria-multiselectable="true">
          @for (opt of options(); track opt.value) {
            <li class="form-multi-select-option" role="option">
              <label class="form-multi-select-option-label">
                <input
                  type="checkbox"
                  [checked]="isSelected(opt.value)"
                  (change)="toggleOption(opt.value)"
                  (mousedown)="$event.preventDefault()"
                />
                <span>{{ opt.label }}</span>
              </label>
            </li>
          }
        </ul>
      }
    </div>
  `,
})
export class FormMultiSelectComponent implements ControlValueAccessor {
  private readonly elementRef = inject(ElementRef);

  readonly options = input<FormSelectOption[]>([]);
  readonly placeholder = input('Select...');

  readonly dropdownOpen = signal(false);
  readonly selectedValues = signal<string[]>([]);
  readonly disabled = signal(false);

  readonly triggerLabel = computed(() => {
    const selected = this.selectedValues();
    if (selected.length === 0) {
      return this.placeholder();
    }
    const labels = selected
      .map(v => this.options().find(o => o.value === v)?.label)
      .filter((l): l is string => !!l);
    if (labels.length <= 2) {
      return labels.join(', ');
    }
    return `${selected.length} selected`;
  });

  private onChange: (value: string[]) => void = () => {};
  private onTouched: () => void = () => {};

  writeValue(value: string[] | null): void {
    this.selectedValues.set(value ?? []);
  }

  registerOnChange(fn: (value: string[]) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled.set(isDisabled);
  }

  isSelected(value: string): boolean {
    return this.selectedValues().includes(value);
  }

  toggleOption(value: string): void {
    if (this.disabled()) return;
    const current = this.selectedValues();
    const next = current.includes(value)
      ? current.filter(v => v !== value)
      : [...current, value];
    this.selectedValues.set(next);
    this.onChange(next);
  }

  toggleDropdown(): void {
    if (this.disabled()) return;
    this.dropdownOpen.update(open => !open);
  }

  onFocusOut(event: FocusEvent): void {
    const related = event.relatedTarget as Node | null;
    if (related && this.elementRef.nativeElement.contains(related)) {
      return;
    }
    this.dropdownOpen.set(false);
    this.onTouched();
  }

  onKeydown(event: KeyboardEvent): void {
    if (this.disabled()) return;
    if (event.key === 'Escape') {
      event.preventDefault();
      this.dropdownOpen.set(false);
    } else if (event.key === 'Enter' || event.key === ' ') {
      if (!this.dropdownOpen()) {
        event.preventDefault();
        this.dropdownOpen.set(true);
      }
    }
  }
}
