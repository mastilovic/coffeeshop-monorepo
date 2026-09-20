import { describe, expect, it } from 'vitest';
import { formatUserDisplayName } from './user-display-name';

describe('formatUserDisplayName', () => {
  it('prefers username when configured', () => {
    expect(formatUserDisplayName({ name: 'Ada Lovelace', username: 'ada' })).toBe('ada');
  });

  it('falls back to name when username is empty', () => {
    expect(formatUserDisplayName({ name: 'Ada Lovelace', username: '  ' })).toBe('Ada Lovelace');
  });

  it('never returns email and uses User as last resort', () => {
    expect(formatUserDisplayName({ name: '', username: '' })).toBe('User');
    expect(formatUserDisplayName(null)).toBe('User');
  });
});
