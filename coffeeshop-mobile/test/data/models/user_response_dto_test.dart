import 'package:coffeeshop_mobile/data/models/user_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserResponseDto', () {
    final validJson = {
      'id': 'user-123',
      'name': 'John Doe',
      'username': 'johndoe',
      'email': 'john@example.com',
      'userType': 'CUSTOMER',
    };

    test('fromJson parses valid JSON correctly', () {
      final dto = UserResponseDto.fromJson(validJson);
      expect(dto.id, 'user-123');
      expect(dto.name, 'John Doe');
      expect(dto.username, 'johndoe');
      expect(dto.email, 'john@example.com');
      expect(dto.userType, 'CUSTOMER');
    });

    test('fromJson handles shop owner user type', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['userType'] = 'SHOP_OWNER';
      final dto = UserResponseDto.fromJson(json);
      expect(dto.userType, 'SHOP_OWNER');
    });

    test('toJson produces valid JSON', () {
      final dto = UserResponseDto.fromJson(validJson);
      final json = dto.toJson();
      expect(json['id'], 'user-123');
      expect(json['name'], 'John Doe');
      expect(json['userType'], 'CUSTOMER');
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
    });
  });
}
