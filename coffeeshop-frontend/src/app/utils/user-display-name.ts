import { UserSummaryDto } from '../models/user.model';

/** Public display label: username if set, else name. Never email. */
export function formatUserDisplayName(
  user: Pick<UserSummaryDto, 'name' | 'username'> | null | undefined,
): string {
  const username = user?.username?.trim();
  if (username) return username;
  const name = user?.name?.trim();
  if (name) return name;
  return 'User';
}
