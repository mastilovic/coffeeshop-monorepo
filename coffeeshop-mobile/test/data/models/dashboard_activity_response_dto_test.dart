import 'package:coffeeshop_mobile/data/models/dashboard_activity_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardActivityResponse', () {
    final validJson = {
      'aggregate': {
        'shopCount': 3,
        'reviewCount': 12,
        'averageRating': 4.2,
        'eventCount': 5,
        'memberCount': 40,
      },
      'activities': [
        {
          'type': 'REVIEW',
          'timestamp': '2024-06-01T10:00:00Z',
          'shopId': 'shop-1',
          'shopName': 'Central Perk',
          'title': 'New review',
          'actorName': 'Jane',
          'rating': 5,
        },
      ],
      'topShops': [
        {
          'shopId': 'shop-1',
          'shopName': 'Central Perk',
          'city': 'New York',
          'averageRating': 4.8,
          'reviewCount': 20,
        },
      ],
      'upcomingEvents': [
        {
          'eventId': 'evt-1',
          'eventName': 'Coffee Tasting',
          'eventDate': '2024-07-01T18:00:00Z',
          'shopId': 'shop-1',
          'shopName': 'Central Perk',
        },
      ],
      'personalSummary': {
        'favouriteShops': 2,
        'reservations': 1,
        'reviewsWritten': 3,
      },
      'notifications': [
        {
          'type': 'PENDING_REQUEST',
          'message': 'You have pending requests',
          'count': 2,
          'link': '/reservations',
        },
      ],
    };

    test('fromJson parses Go-shaped dashboard JSON', () {
      final dto = DashboardActivityResponse.fromJson(validJson);
      expect(dto.aggregate.shopCount, 3);
      expect(dto.aggregate.reviewCount, 12);
      expect(dto.aggregate.averageRating, 4.2);
      expect(dto.activities.length, 1);
      expect(dto.activities.first.shopId, 'shop-1');
      expect(dto.activities.first.actorName, 'Jane');
      expect(dto.topShops.length, 1);
      expect(dto.topShops.first.shopName, 'Central Perk');
      expect(dto.upcomingEvents.length, 1);
      expect(dto.upcomingEvents.first.eventId, 'evt-1');
      expect(dto.personalSummary?.favouriteShops, 2);
      expect(dto.personalSummary?.reviewsWritten, 3);
      expect(dto.notifications.first.count, 2);
    });

    test('fromJson handles minimal response with defaults', () {
      final dto = DashboardActivityResponse.fromJson({
        'aggregate': {
          'shopCount': 0,
          'reviewCount': 0,
          'eventCount': 0,
          'memberCount': 0,
        },
      });
      expect(dto.activities, isEmpty);
      expect(dto.topShops, isEmpty);
      expect(dto.upcomingEvents, isEmpty);
      expect(dto.notifications, isEmpty);
      expect(dto.personalSummary, isNull);
    });
  });
}
