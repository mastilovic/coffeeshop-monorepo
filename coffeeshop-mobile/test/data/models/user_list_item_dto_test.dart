import 'package:coffeeshop_mobile/data/models/user_list_item_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserListItemDto', () {
    final validJson = {
      'id': 'user-123',
      'name': 'John Doe',
      'username': 'johndoe',
      'userType': 'CUSTOMER',
    };

    test('fromJson parses Go-shaped JSON correctly', () {
      final dto = UserListItemDto.fromJson(validJson);
      expect(dto.id, 'user-123');
      expect(dto.name, 'John Doe');
      expect(dto.username, 'johndoe');
      expect(dto.userType, 'CUSTOMER');
    });

    test('toJson produces camelCase keys', () {
      final dto = UserListItemDto.fromJson(validJson);
      final json = dto.toJson();
      expect(json['userType'], 'CUSTOMER');
    });
  });
}
