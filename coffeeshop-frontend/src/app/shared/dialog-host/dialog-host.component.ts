import {
  ChangeDetectionStrategy,
  Component,
  HostListener,
  inject,
} from '@angular/core';
import { DialogService } from '../../services/dialog.service';

@Component({
  selector: 'app-dialog-host',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (dialog(); as active) {
      <div
        class="confirm-overlay"
        role="dialog"
        aria-modal="true"
        aria-labelledby="app-dialog-message"
        (click)="onBackdropClick(active)">
        <div class="confirm-dialog" (click)="$event.stopPropagation()">
          <p id="app-dialog-message">{{ active.message }}</p>
          <div class="confirm-dialog-actions">
            @if (active.type === 'confirm') {
              <button
                type="button"
                class="btn btn-secondary"
                (click)="dialogService.closeConfirm(false)">
                {{ active.cancelLabel }}
              </button>
              <button
                type="button"
                class="btn"
                [class.btn-primary]="active.confirmVariant === 'primary'"
                [class.btn-danger]="active.confirmVariant === 'danger'"
                (click)="dialogService.closeConfirm(true)">
                {{ active.confirmLabel }}
              </button>
            } @else {
              <button
                type="button"
                class="btn btn-primary"
                (click)="dialogService.closeAlert()">
                OK
              </button>
            }
          </div>
        </div>
      </div>
    }
  `,
})
export class DialogHostComponent {
  readonly dialogService = inject(DialogService);
  readonly dialog = this.dialogService.state;

  @HostListener('document:keydown.escape')
  onEscape(): void {
    const active = this.dialog();
    if (!active) {
      return;
    }
    if (active.type === 'alert') {
      this.dialogService.closeAlert();
    } else {
      this.dialogService.closeConfirm(false);
    }
  }

  onBackdropClick(active: NonNullable<ReturnType<typeof this.dialog>>): void {
    if (active.type === 'alert') {
      this.dialogService.closeAlert();
    } else {
      this.dialogService.closeConfirm(false);
    }
  }
}
