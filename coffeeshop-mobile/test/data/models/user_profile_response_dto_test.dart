import 'package:coffeeshop_mobile/data/models/user_profile_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileResponseDto', () {
    final goProfileJson = {
      'id': 'user-123',
      'name': 'John Doe',
      'username': 'johndoe',
      'email': 'john@example.com',
      'userType': 'CUSTOMER',
      'roles': [],
      'favouriteShops': [],
      'reviews': [],
      'reservations': [],
    };

    test('fromJson parses Go profile response', () {
      final dto = UserProfileResponseDto.fromJson(goProfileJson);
      expect(dto.id, 'user-123');
      expect(dto.name, 'John Doe');
      expect(dto.username, 'johndoe');
      expect(dto.email, 'john@example.com');
      expect(dto.userType, 'CUSTOMER');
      expect(dto.favouriteShops, isEmpty);
    });

    test('fromJson parses favouriteShops', () {
      final json = Map<String, dynamic>.from(goProfileJson)
        ..['favouriteShops'] = [
          {
            'id': 'shop-1',
            'name': 'Central Perk',
            'city': 'New York',
          },
        ];
      final dto = UserProfileResponseDto.fromJson(json);
      expect(dto.favouriteShops, hasLength(1));
      expect(dto.favouriteShops.first.id, 'shop-1');
      expect(dto.favouriteShops.first.name, 'Central Perk');
    });

    test('fromJson handles shop owner user type', () {
      final json = Map<String, dynamic>.from(goProfileJson)
        ..['userType'] = 'SHOP_OWNER';
      final dto = UserProfileResponseDto.fromJson(json);
      expect(dto.userType, 'SHOP_OWNER');
    });

    test('toJson produces camelCase userType', () {
      final dto = UserProfileResponseDto.fromJson(goProfileJson);
      final json = dto.toJson();
      expect(json['userType'], 'CUSTOMER');
      expect(json.containsKey('user_type'), isFalse);
    });
  });
}
