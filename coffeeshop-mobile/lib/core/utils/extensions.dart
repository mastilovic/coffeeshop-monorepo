import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String formatDate() => DateFormat('MMM d, yyyy').format(this);
  String formatDateTime() => DateFormat('MMM d, yyyy h:mm a').format(this);
  String formatTime() => DateFormat('h:mm a').format(this);
  String formatRelative() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate();
  }

  /// Day-based relative label vs today (never falls back to a second date).
  String formatRelativeAroundNow() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(year, month, day);
    final days = thatDay.difference(today).inDays;

    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days == -1) return 'Yesterday';
    if (days > 0) return 'In $days days';
    return '${-days} days ago';
  }
}

/// Formats an ISO event date string for display; returns [raw] if unparseable.
String formatEventDateTime(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return parsed.formatDateTime();
}

/// Absolute event date plus days-from-today, or null if missing/unparseable.
String? formatEventDateWithRelative(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  return '${parsed.formatDate()} · ${parsed.formatRelativeAroundNow()}';
}

/// Relative countdown for event cards (elapsed 24h periods, not calendar days).
///
/// Future: `in 5 days`, `in 3 hours`, `in 20 min`
/// Past: `5 days ago`, `3 hours ago`, `20 min ago`
/// Under 1 minute: `now` (future) / `just now` (past)
/// Returns null when [raw] is missing or unparseable.
String? formatEventCountdown(String? raw, {DateTime? now}) {
  if (raw == null || raw.isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;

  final reference = now ?? DateTime.now();
  final diff = parsed.difference(reference);
  final isFuture = !diff.isNegative;
  final abs = diff.abs();

  if (abs.inMinutes < 1) {
    return isFuture ? 'now' : 'just now';
  }

  String unitLabel(int value, String singular, String plural) =>
      value == 1 ? singular : plural;

  if (abs.inHours < 1) {
    final mins = abs.inMinutes;
    final label = unitLabel(mins, 'min', 'min');
    return isFuture ? 'in $mins $label' : '$mins $label ago';
  }

  if (abs.inDays < 1) {
    final hours = abs.inHours;
    final label = unitLabel(hours, 'hour', 'hours');
    return isFuture ? 'in $hours $label' : '$hours $label ago';
  }

  final days = abs.inDays;
  final label = unitLabel(days, 'day', 'days');
  return isFuture ? 'in $days $label' : '$days $label ago';
}

/// Shop line for event cards, e.g. `at Bean Bar · Belgrade`.
String? formatEventShopLabel(String? shopName, {String? shopCity}) {
  if (shopName == null || shopName.trim().isEmpty) return null;
  final name = shopName.trim();
  final city = shopCity?.trim();
  if (city != null && city.isNotEmpty) {
    return 'at $name · $city';
  }
  return 'at $name';
}

String normalizeUserType(String raw) {
  switch (raw.toUpperCase()) {
    case 'CUSTOMER':
      return 'customer';
    case 'SHOP_OWNER':
      return 'shop_owner';
    case 'ADMIN':
      return 'admin';
    default:
      return raw.toLowerCase();
  }
}

/// Public display label for a user summary: username if set, else name. Never email.
String formatUserDisplayName({String? username, String? name}) {
  final trimmedUsername = username?.trim();
  if (trimmedUsername != null && trimmedUsername.isNotEmpty) {
    return trimmedUsername;
  }
  final trimmedName = name?.trim();
  if (trimmedName != null && trimmedName.isNotEmpty) {
    return trimmedName;
  }
  return 'User';
}

/// Same as [formatUserDisplayName] for a JSON user/author map from the API.
String formatUserDisplayNameFromMap(Map<String, dynamic>? user) {
  if (user == null) return 'User';
  return formatUserDisplayName(
    username: user['username'] as String?,
    name: user['name'] as String?,
  );
}

extension StringExtension on String {
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension NumExtension on num {
  String get compact {
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}k';
    }
    return toString();
  }
}
