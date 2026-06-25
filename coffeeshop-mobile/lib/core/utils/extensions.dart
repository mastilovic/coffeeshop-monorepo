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
