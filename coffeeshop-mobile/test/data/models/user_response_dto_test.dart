import 'package:coffeeshop_mobile/data/models/user_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserResponseDto', () {
    final validJson = {
      'id': 'user-123',
      'name': 'John Doe',
      'username': 'johndoe',
      'email': 'john@example.com',
      'user_type': 'customer',
      'is_active': true,
      'created_at': '2024-01-15T10:30:00Z',
      'updated_at': '2024-03-20T14:45:00Z',
    };

    test('fromJson parses valid JSON correctly', () {
      final dto = UserResponseDto.fromJson(validJson);
      expect(dto.id, 'user-123');
      expect(dto.name, 'John Doe');
      expect(dto.username, 'johndoe');
      expect(dto.email, 'john@example.com');
      expect(dto.userType, 'customer');
      expect(dto.isActive, isTrue);
      expect(dto.createdAt, DateTime.parse('2024-01-15T10:30:00Z'));
      expect(dto.updatedAt, DateTime.parse('2024-03-20T14:45:00Z'));
    });

    test('fromJson handles inactive user', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['is_active'] = false;
      final dto = UserResponseDto.fromJson(json);
      expect(dto.isActive, isFalse);
    });

    test('fromJson handles shop_owner user type', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['user_type'] = 'shop_owner';
      final dto = UserResponseDto.fromJson(json);
      expect(dto.userType, 'shop_owner');
    });

    test('toJson produces valid JSON', () {
      final dto = UserResponseDto.fromJson(validJson);
      final json = dto.toJson();
      expect(json['id'], 'user-123');
      expect(json['name'], 'John Doe');
      expect(json['user_type'], 'customer');
      expect(json['is_active'], true);
    });

    test('round-trip serialization preserves data', () {
      final dto = UserResponseDto.fromJson(validJson);
      final json = dto.toJson();
      final dto2 = UserResponseDto.fromJson(json);
      expect(dto2.id, dto.id);
      expect(dto2.name, dto.name);
      expect(dto2.username, dto.username);
      expect(dto2.email, dto.email);
      expect(dto2.userType, dto.userType);
      expect(dto2.isActive, dto.isActive);
    });
  });
}
