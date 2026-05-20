import { Injectable, signal } from '@angular/core';

export interface DialogConfirmOptions {
  confirmLabel?: string;
  cancelLabel?: string;
  confirmVariant?: 'primary' | 'danger';
}

export interface ActiveAlertDialog {
  type: 'alert';
  message: string;
  resolve: () => void;
}

export interface ActiveConfirmDialog {
  type: 'confirm';
  message: string;
  confirmLabel: string;
  cancelLabel: string;
  confirmVariant: 'primary' | 'danger';
  resolve: (confirmed: boolean) => void;
}

export type ActiveDialog = ActiveAlertDialog | ActiveConfirmDialog;

@Injectable({ providedIn: 'root' })
export class DialogService {
  private readonly active = signal<ActiveDialog | null>(null);

  readonly state = this.active.asReadonly();

  alert(message: string): Promise<void> {
    return new Promise(resolve => {
      this.active.set({
        type: 'alert',
        message,
        resolve: () => {
          this.active.set(null);
          resolve();
        },
      });
    });
  }

  confirm(message: string, options: DialogConfirmOptions = {}): Promise<boolean> {
    return new Promise(resolve => {
      this.active.set({
        type: 'confirm',
        message,
        confirmLabel: options.confirmLabel ?? 'OK',
        cancelLabel: options.cancelLabel ?? 'Cancel',
        confirmVariant: options.confirmVariant ?? 'primary',
        resolve: (confirmed: boolean) => {
          this.active.set(null);
          resolve(confirmed);
        },
      });
    });
  }

  closeAlert(): void {
    const dialog = this.active();
    if (dialog?.type === 'alert') {
      dialog.resolve();
    }
  }

  closeConfirm(confirmed: boolean): void {
    const dialog = this.active();
    if (dialog?.type === 'confirm') {
      dialog.resolve(confirmed);
    }
  }
}
