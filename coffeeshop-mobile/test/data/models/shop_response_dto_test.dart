import 'package:coffeeshop_mobile/data/models/shop_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShopResponseDto', () {
    final validJson = {
      'id': 'shop-456',
      'name': 'Central Perk',
      'address': '123 Main St',
      'city': 'New York',
      'phoneNumber': '+1-555-0100',
      'email': 'info@centralperk.com',
      'averageRating': 4.5,
      'reviewCount': 42,
      'memberCount': 128,
      'favouriteByCurrentUser': true,
    };

    test('fromJson parses valid JSON correctly', () {
      final dto = ShopResponseDto.fromJson(validJson);
      expect(dto.id, 'shop-456');
      expect(dto.name, 'Central Perk');
      expect(dto.address, '123 Main St');
      expect(dto.city, 'New York');
      expect(dto.phoneNumber, '+1-555-0100');
      expect(dto.email, 'info@centralperk.com');
      expect(dto.averageRating, 4.5);
      expect(dto.reviewCount, 42);
      expect(dto.memberCount, 128);
      expect(dto.favouriteByCurrentUser, isTrue);
    });

    test('fromJson handles minimal JSON with defaults', () {
      final minimalJson = {
        'id': 'shop-min',
        'name': 'Minimal Shop',
        'address': '1 Min St',
        'city': 'Mini City',
      };
      final dto = ShopResponseDto.fromJson(minimalJson);
      expect(dto.reviewCount, 0);
      expect(dto.memberCount, 0);
      expect(dto.favouriteByCurrentUser, isFalse);
      expect(dto.averageRating, isNull);
      expect(dto.phoneNumber, isNull);
      expect(dto.email, isNull);
    });

    test('fromJson handles nested objects', () {
      final jsonWithNested = Map<String, dynamic>.from(validJson)
        ..['events'] = [
          {'eventId': 'evt-1', 'eventName': 'Coffee Tasting'}
        ]
        ..['tables'] = [
          {'id': 'tbl-1', 'number': 1, 'capacity': 4}
        ]
        ..['reviews'] = [
          {'id': 'rev-1', 'rating': 5, 'title': 'Great!'}
        ];
      final dto = ShopResponseDto.fromJson(jsonWithNested);
      expect(dto.events, isNotNull);
      expect(dto.events!.length, 1);
      expect(dto.events![0]['eventName'], 'Coffee Tasting');
      expect(dto.tables, isNotNull);
      expect(dto.tables!.length, 1);
      expect(dto.tables![0]['number'], 1);
    });

    test('toJson produces valid JSON', () {
      final dto = ShopResponseDto.fromJson(validJson);
      final json = dto.toJson();
      expect(json['id'], 'shop-456');
      expect(json['name'], 'Central Perk');
      expect(json['favouriteByCurrentUser'], true);
      expect(json['reviewCount'], 42);
      expect(json['memberCount'], 128);
    });

    test('round-trip serialization preserves data', () {
      final dto = ShopResponseDto.fromJson(validJson);
      final json = dto.toJson();
      final dto2 = ShopResponseDto.fromJson(json);
      expect(dto2.id, dto.id);
      expect(dto2.name, dto.name);
      expect(dto2.address, dto.address);
      expect(dto2.city, dto.city);
      expect(dto2.averageRating, dto.averageRating);
    });

    test('equality works correctly', () {
      final a = ShopResponseDto.fromJson(validJson);
      final b = ShopResponseDto.fromJson(validJson);
      expect(a, equals(b));
    });
  });

  group('ShopSummaryDto', () {
    final validJson = {
      'id': 'shop-sum',
      'name': 'Summary Shop',
      'address': '10 Sum St',
      'city': 'Sum City',
      'phoneNumber': '+1-555-0200',
      'email': 'sum@example.com',
    };

    test('fromJson parses valid JSON correctly', () {
      final dto = ShopSummaryDto.fromJson(validJson);
      expect(dto.id, 'shop-sum');
      expect(dto.name, 'Summary Shop');
      expect(dto.address, '10 Sum St');
      expect(dto.city, 'Sum City');
      expect(dto.phoneNumber, '+1-555-0200');
      expect(dto.email, 'sum@example.com');
    });

    test('toJson produces valid JSON', () {
      final dto = ShopSummaryDto.fromJson(validJson);
      final json = dto.toJson();
      expect(json['id'], 'shop-sum');
      expect(json['name'], 'Summary Shop');
    });
  });

  group('ShopCreateRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'New Shop',
        'address': '456 New Ave',
        'city': 'New City',
        'ownerUserId': 'user-1',
        'loyaltyPlanId': 'plan-1',
      };
      final dto = ShopCreateRequest.fromJson(json);
      expect(dto.name, 'New Shop');
      expect(dto.address, '456 New Ave');
      expect(dto.city, 'New City');
      expect(dto.ownerUserId, 'user-1');
      expect(dto.loyaltyPlanId, 'plan-1');
    });

    test('toJson produces valid JSON for API', () {
      final dto = ShopCreateRequest.fromJson({
        'name': 'New Shop',
        'address': '456 New Ave',
        'city': 'New City',
      });
      final json = dto.toJson();
      expect(json['name'], 'New Shop');
      expect(json['address'], '456 New Ave');
      expect(json['city'], 'New City');
      expect(json['phoneNumber'], isNull);
      expect(json['email'], isNull);
    });
  });

  group('ShopUpdateRequest', () {
    test('fromJson parses partial update correctly', () {
      final json = {
        'name': 'Updated Shop',
      };
      final dto = ShopUpdateRequest.fromJson(json);
      expect(dto.name, 'Updated Shop');
      expect(dto.address, isNull);
      expect(dto.city, isNull);
    });
  });

  group('ShopSearchParams', () {
    test('fromJson parses with defaults', () {
      final json = <String, dynamic>{};
      final dto = ShopSearchParams.fromJson(json);
      expect(dto.page, 0);
      expect(dto.size, 20);
      expect(dto.q, isNull);
    });

    test('fromJson parses with search query', () {
      final json = {'q': 'coffee', 'page': 1, 'size': 10};
      final dto = ShopSearchParams.fromJson(json);
      expect(dto.q, 'coffee');
      expect(dto.page, 1);
      expect(dto.size, 10);
    });
  });
}
