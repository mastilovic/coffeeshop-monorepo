import 'package:flutter/material.dart';

enum UserRole {
  customer,
  shop_owner,
  admin;

  static UserRole fromString(String raw) {
    switch (raw.toUpperCase()) {
      case 'CUSTOMER':
        return UserRole.customer;
      case 'SHOP_OWNER':
        return UserRole.shop_owner;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

extension UserRoleDisplay on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.shop_owner:
        return 'Shop Owner';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Color displayColor(BuildContext context) {
    switch (this) {
      case UserRole.admin:
        return Colors.red.shade100;
      case UserRole.shop_owner:
        return Colors.blue.shade100;
      case UserRole.customer:
        return Theme.of(context).colorScheme.secondaryContainer;
    }
  }
}
