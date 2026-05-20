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
import { FormSelectOption } from './form-select-option.model';

@Component({
  selector: 'app-form-select',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => FormSelectComponent),
      multi: true,
    },
  ],
  template: `
    <div class="form-select" (focusout)="onFocusOut($event)">
      <button
        type="button"
        class="form-input form-select-trigger"
        [class.form-select-trigger--compact]="compact()"
        [id]="inputId() || null"
        [disabled]="disabled()"
        [attr.aria-expanded]="dropdownOpen()"
        [attr.aria-describedby]="ariaDescribedBy() || null"
        aria-haspopup="listbox"
        (click)="toggleDropdown()"
        (keydown)="onKeydown($event)">
        <span class="form-select-trigger-label" [class.form-select-trigger-label--placeholder]="!selectedValue()">
          {{ displayLabel() }}
        </span>
      </button>
      @if (dropdownOpen() && options().length > 0) {
        <ul class="form-select-dropdown" role="listbox">
          @for (opt of options(); track opt.value; let i = $index) {
            <li
              role="option"
              class="form-select-option"
              [class.active]="i === highlightedIndex()"
              [attr.aria-selected]="opt.value === selectedValue()"
              (mousedown)="selectOption(opt, $event)">
              {{ opt.label }}
            </li>
          }
        </ul>
      }
    </div>
  `,
})
export class FormSelectComponent implements ControlValueAccessor {
  private readonly elementRef = inject(ElementRef);

  readonly options = input<FormSelectOption[]>([]);
  readonly placeholder = input('Select...');
  readonly inputId = input<string | undefined>(undefined);
  readonly ariaDescribedBy = input<string | null | undefined>(undefined);
  readonly compact = input(false);

  readonly dropdownOpen = signal(false);
  readonly highlightedIndex = signal(0);
  readonly selectedValue = signal('');
  readonly disabled = signal(false);

  readonly displayLabel = computed(() => {
    const value = this.selectedValue();
    if (!value) {
      return this.placeholder();
    }
    const match = this.options().find(o => o.value === value);
    return match?.label ?? this.placeholder();
  });

  private onChange: (value: string) => void = () => {};
  private onTouched: () => void = () => {};

  writeValue(value: string | null): void {
    this.selectedValue.set(value ?? '');
  }

  registerOnChange(fn: (value: string) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled.set(isDisabled);
  }

  toggleDropdown(): void {
    if (this.disabled()) return;
    if (this.dropdownOpen()) {
      this.dropdownOpen.set(false);
    } else {
      this.openDropdown();
    }
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

    const list = this.options();
    if (!this.dropdownOpen()) {
      if (event.key === 'ArrowDown' || event.key === 'ArrowUp' || event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        this.openDropdown();
        if (event.key === 'ArrowUp') {
          this.highlightedIndex.set(Math.max(list.length - 1, 0));
        }
      }
      return;
    }

    if (event.key === 'ArrowDown') {
      event.preventDefault();
      this.highlightedIndex.update(i => Math.min(i + 1, list.length - 1));
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      this.highlightedIndex.update(i => Math.max(i - 1, 0));
    } else if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      const opt = list[this.highlightedIndex()];
      if (opt) {
        this.applySelection(opt.value);
      }
    } else if (event.key === 'Escape') {
      event.preventDefault();
      this.dropdownOpen.set(false);
    }
  }

  selectOption(opt: FormSelectOption, event: MouseEvent): void {
    event.preventDefault();
    this.applySelection(opt.value);
  }

  private openDropdown(): void {
    const list = this.options();
    const currentIndex = list.findIndex(o => o.value === this.selectedValue());
    this.highlightedIndex.set(currentIndex >= 0 ? currentIndex : 0);
    this.dropdownOpen.set(true);
  }

  private applySelection(value: string): void {
    this.selectedValue.set(value);
    this.onChange(value);
    this.onTouched();
    this.dropdownOpen.set(false);
  }
}
