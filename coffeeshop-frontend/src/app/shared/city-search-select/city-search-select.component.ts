import {
  Component,
  ElementRef,
  forwardRef,
  inject,
  signal,
  ViewChild,
  ChangeDetectionStrategy,
} from '@angular/core';
import {
  ControlValueAccessor,
  NG_VALUE_ACCESSOR,
  NG_VALIDATORS,
  Validator,
  AbstractControl,
  ValidationErrors,
  Validators,
} from '@angular/forms';
import { filterSerbiaCities, isSerbiaCity } from '../../data/serbia-cities';

@Component({
  selector: 'app-city-search-select',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => CitySearchSelectComponent),
      multi: true,
    },
    {
      provide: NG_VALIDATORS,
      useExisting: forwardRef(() => CitySearchSelectComponent),
      multi: true,
    },
  ],
  template: `
    <div class="city-search-select" (focusout)="onFocusOut($event)">
      <input
        #inputEl
        type="text"
        class="form-input"
        [class.invalid]="showInvalid()"
        [value]="displayText()"
        [attr.aria-expanded]="dropdownOpen()"
        aria-autocomplete="list"
        aria-haspopup="listbox"
        role="combobox"
        placeholder="Search city..."
        (input)="onInput($event)"
        (focus)="onFocus()"
        (keydown)="onKeydown($event)"
      />
      @if (dropdownOpen() && filtered().length > 0) {
        <ul class="city-dropdown" role="listbox">
          @for (city of filtered(); track city; let i = $index) {
            <li
              role="option"
              class="city-option"
              [class.active]="i === highlightedIndex()"
              [attr.aria-selected]="i === highlightedIndex()"
              (mousedown)="selectCity(city, $event)">
              {{ city }}
            </li>
          }
        </ul>
      }
      @if (showInvalid()) {
        <span class="city-error">Select a city from the list</span>
      }
    </div>
  `,
})
export class CitySearchSelectComponent implements ControlValueAccessor, Validator {
  private readonly elementRef = inject(ElementRef);

  @ViewChild('inputEl') inputEl?: ElementRef<HTMLInputElement>;

  readonly displayText = signal('');
  readonly dropdownOpen = signal(false);
  readonly filtered = signal<string[]>([]);
  readonly highlightedIndex = signal(0);
  readonly touched = signal(false);

  private selectedValue = '';
  private required = false;

  private onChange: (value: string) => void = () => {};
  private onTouched: () => void = () => {};

  writeValue(value: string | null): void {
    this.selectedValue = value ?? '';
    this.displayText.set(this.selectedValue);
  }

  registerOnChange(fn: (value: string) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    const input = this.inputEl?.nativeElement;
    if (input) {
      input.disabled = isDisabled;
    }
  }

  validate(control: AbstractControl): ValidationErrors | null {
    this.required = control.hasValidator(Validators.required);
    const value = control.value as string | null;
    if (value == null || value === '') {
      return null;
    }
    return isSerbiaCity(value) ? null : { serbiaCity: true };
  }

  showInvalid(): boolean {
    if (!this.touched()) {
      return false;
    }
    const text = this.displayText().trim();
    if (!text && this.required) {
      return true;
    }
    if (text && !isSerbiaCity(this.selectedValue)) {
      return true;
    }
    return false;
  }

  onInput(event: Event): void {
    const text = (event.target as HTMLInputElement).value;
    this.displayText.set(text);
    this.selectedValue = '';
    this.onChange('');
    const matches = filterSerbiaCities(text);
    this.filtered.set(matches);
    this.highlightedIndex.set(0);
    this.dropdownOpen.set(true);
  }

  onFocus(): void {
    this.filtered.set(filterSerbiaCities(this.displayText()));
    this.highlightedIndex.set(0);
    this.dropdownOpen.set(true);
  }

  onFocusOut(event: FocusEvent): void {
    const related = event.relatedTarget as Node | null;
    if (related && this.elementRef.nativeElement.contains(related)) {
      return;
    }
    this.touched.set(true);
    this.onTouched();
    this.dropdownOpen.set(false);
    this.commitOrClear();
  }

  onKeydown(event: KeyboardEvent): void {
    if (!this.dropdownOpen()) {
      if (event.key === 'ArrowDown' || event.key === 'Enter') {
        this.filtered.set(filterSerbiaCities(this.displayText()));
        this.dropdownOpen.set(true);
        event.preventDefault();
      }
      return;
    }

    const list = this.filtered();
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      this.highlightedIndex.update(i => Math.min(i + 1, list.length - 1));
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      this.highlightedIndex.update(i => Math.max(i - 1, 0));
    } else if (event.key === 'Enter') {
      event.preventDefault();
      const city = list[this.highlightedIndex()];
      if (city) {
        this.applySelection(city);
      }
    } else if (event.key === 'Escape') {
      event.preventDefault();
      this.dropdownOpen.set(false);
    }
  }

  selectCity(city: string, event: MouseEvent): void {
    event.preventDefault();
    this.applySelection(city);
    this.inputEl?.nativeElement.focus();
  }

  private applySelection(city: string): void {
    this.selectedValue = city;
    this.displayText.set(city);
    this.onChange(city);
    this.dropdownOpen.set(false);
    this.touched.set(true);
    this.onTouched();
  }

  private commitOrClear(): void {
    const text = this.displayText().trim();
    if (!text) {
      this.selectedValue = '';
      this.onChange('');
      return;
    }
    if (isSerbiaCity(text)) {
      this.applySelection(text);
      return;
    }
    const exact = this.filtered().find(c => c.toLowerCase() === text.toLowerCase());
    if (exact) {
      this.applySelection(exact);
      return;
    }
    this.selectedValue = '';
    this.onChange('');
  }
}
