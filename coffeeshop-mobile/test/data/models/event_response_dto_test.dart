import 'package:coffeeshop_mobile/data/models/event_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventResponseDto', () {
    final validJson = {
      'eventId': 'evt-123',
      'eventName': 'Coffee Tasting Workshop',
      'eventDate': '2024-06-15T18:00:00Z',
      'description': 'Learn about coffee brewing',
      'shopId': 'shop-456',
      'shopName': 'Central Perk',
      'shopCity': 'New York',
    };

    test('fromJson parses valid JSON correctly', () {
      final dto = EventResponseDto.fromJson(validJson);
      expect(dto.eventId, 'evt-123');
      expect(dto.eventName, 'Coffee Tasting Workshop');
      expect(dto.eventDate, '2024-06-15T18:00:00Z');
      expect(dto.description, 'Learn about coffee brewing');
      expect(dto.shopId, 'shop-456');
      expect(dto.shopName, 'Central Perk');
      expect(dto.shopCity, 'New York');
    });

    test('fromJson handles optional fields', () {
      final minimalJson = {
        'eventId': 'evt-min',
        'eventName': 'Min Event',
        'eventDate': '2024-07-01T12:00:00Z',
      };
      final dto = EventResponseDto.fromJson(minimalJson);
      expect(dto.description, isNull);
      expect(dto.shopId, isNull);
      expect(dto.shopName, isNull);
      expect(dto.shopCity, isNull);
    });

    test('fromJson handles empty-string shop fields from Go API', () {
      final json = {
        'eventId': 'evt-empty-shop',
        'eventName': 'Standalone Event',
        'eventDate': '2024-07-01T12:00:00Z',
        'description': '',
        'shopId': '',
        'shopName': '',
        'shopCity': '',
      };
      final dto = EventResponseDto.fromJson(json);
      expect(dto.eventId, 'evt-empty-shop');
      expect(dto.shopId, '');
      expect(dto.shopName, '');
      expect(dto.shopCity, '');
    });

    test('toJson produces valid JSON', () {
      final dto = EventResponseDto.fromJson(validJson);
      final json = dto.toJson();
      expect(json['eventId'], 'evt-123');
      expect(json['eventName'], 'Coffee Tasting Workshop');
      expect(json['eventDate'], '2024-06-15T18:00:00Z');
      expect(json['shopName'], 'Central Perk');
    });

    test('round-trip serialization preserves data', () {
      final dto = EventResponseDto.fromJson(validJson);
      final json = dto.toJson();
      final dto2 = EventResponseDto.fromJson(json);
      expect(dto2.eventId, dto.eventId);
      expect(dto2.eventName, dto.eventName);
      expect(dto2.eventDate, dto.eventDate);
    });
  });

  group('EventCreateRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'eventName': 'New Event',
        'eventDate': '2024-08-01T15:00:00Z',
        'description': 'A fun event',
        'shopId': 'shop-1',
      };
      final dto = EventCreateRequest.fromJson(json);
      expect(dto.eventName, 'New Event');
      expect(dto.eventDate, '2024-08-01T15:00:00Z');
      expect(dto.description, 'A fun event');
      expect(dto.shopId, 'shop-1');
    });

    test('toJson produces valid JSON', () {
      final dto = EventCreateRequest.fromJson({
        'eventName': 'New Event',
        'eventDate': '2024-08-01T15:00:00Z',
      });
      final json = dto.toJson();
      expect(json['eventName'], 'New Event');
      expect(json['eventDate'], '2024-08-01T15:00:00Z');
    });
  });

  group('EventUpdateRequest', () {
    test('fromJson parses partial update correctly', () {
      final json = {
        'eventName': 'Updated Event Name',
      };
      final dto = EventUpdateRequest.fromJson(json);
      expect(dto.eventName, 'Updated Event Name');
      expect(dto.eventDate, isNull);
      expect(dto.description, isNull);
    });
  });

  group('EventSearchParams', () {
    test('fromJson parses with defaults', () {
      final json = <String, dynamic>{};
      final dto = EventSearchParams.fromJson(json);
      expect(dto.page, 0);
      expect(dto.size, 20);
      expect(dto.q, isNull);
      expect(dto.dateFrom, isNull);
      expect(dto.dateTo, isNull);
    });

    test('fromJson parses with date filters', () {
      final json = {
        'dateFrom': '2024-06-01',
        'dateTo': '2024-06-30',
        'page': 1,
      };
      final dto = EventSearchParams.fromJson(json);
      expect(dto.dateFrom, '2024-06-01');
      expect(dto.dateTo, '2024-06-30');
      expect(dto.page, 1);
    });

    test('toJson produces valid JSON', () {
      final dto = EventSearchParams.fromJson({
        'q': 'coffee',
        'dateFrom': '2024-06-01',
      });
      final json = dto.toJson();
      expect(json['q'], 'coffee');
      expect(json['dateFrom'], '2024-06-01');
    });
  });
}
