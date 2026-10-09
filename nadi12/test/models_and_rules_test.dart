import 'package:flutter_test/flutter_test.dart';
import 'package:nadi_gym/models/api_response.dart';
import 'package:nadi_gym/models/booking_model.dart';
import 'package:nadi_gym/models/check_in_model.dart';
import 'package:nadi_gym/models/gym_class_model.dart';
import 'package:nadi_gym/models/qr_token_model.dart';
import 'package:nadi_gym/services/mock_backend_handler.dart';

void main() {
  group('Data Models Tests', () {
    test('QrTokenModel parses correctly and computes expiration', () {
      final now = DateTime.now();
      final futureTime = now.add(const Duration(seconds: 45));
      final json = {
        'token': 'TEST_TOKEN_123',
        'expires_at': futureTime.toIso8601String(),
      };

      final model = QrTokenModel.fromJson(json);
      expect(model.token, 'TEST_TOKEN_123');
      expect(model.expiresAt.isAfter(now), isTrue);
      expect(model.isExpired, isFalse);
      expect(model.remainingSeconds, greaterThan(40));
    });

    test('GymClassModel handles capacity and freePlaces', () {
      final json = {
        'id': 10,
        'name': 'HIIT blast',
        'starts_at': '2026-10-10T10:00:00Z',
        'ends_at': '2026-10-10T11:00:00Z',
        'capacity': 20,
        'free_places': 0,
      };

      final model = GymClassModel.fromJson(json);
      expect(model.id, 10);
      expect(model.name, 'HIIT blast');
      expect(model.capacity, 20);
      expect(model.freePlaces, 0);
      expect(model.isFull, isTrue);

      final withSlots = model.copyWith(freePlaces: 5);
      expect(withSlots.isFull, isFalse);
      expect(withSlots.freePlaces, 5);
    });

    test('BookingModel enforces Rule 4 (Cancellation Deadline)', () {
      // More than 2 hours in future -> canCancel is TRUE
      final futureBooking = BookingModel(
        id: 1,
        classId: 10,
        className: 'Yoga Flow',
        startsAt: DateTime.now().add(const Duration(hours: 3)),
        status: 'confirmed',
      );
      expect(futureBooking.canCancel, isTrue);

      // Less than 2 hours in future (e.g. 90 minutes) -> canCancel is FALSE
      final soonBooking = BookingModel(
        id: 2,
        classId: 11,
        className: 'Power Lift',
        startsAt: DateTime.now().add(const Duration(minutes: 90)),
        status: 'confirmed',
      );
      expect(soonBooking.canCancel, isFalse);
    });

    test('CheckInModel parses method and timestamps', () {
      final json = {
        'id': 7,
        'checked_in_at': '2026-10-09T08:30:00Z',
        'method': 'qr',
      };
      final model = CheckInModel.fromJson(json);
      expect(model.id, 7);
      expect(model.method, 'qr');
    });
  });

  group('ApiResponse Wrapper Tests', () {
    test('Parses standard success payload', () {
      final json = {
        'success': true,
        'message': 'Request completed successfully',
        'data': {'token': 'TOKEN_XYZ', 'expires_at': '2026-10-10T00:00:00Z'},
      };

      final response = ApiResponse<QrTokenModel>.fromJson(
        json,
        200,
        (data) => QrTokenModel.fromJson(data as Map<String, dynamic>),
      );

      expect(response.success, isTrue);
      expect(response.statusCode, 200);
      expect(response.message, 'Request completed successfully');
      expect(response.data?.token, 'TOKEN_XYZ');
    });

    test('Parses standard error payload', () {
      final json = {
        'success': false,
        'message': 'Subscription expired',
        'errors': {'subscription': 'Membership inactive'},
      };

      final response = ApiResponse<dynamic>.fromJson(json, 400, null);
      expect(response.success, isFalse);
      expect(response.statusCode, 400);
      expect(response.message, 'Subscription expired');
      expect(response.errors?['subscription'], 'Membership inactive');
    });
  });

  group('Business Rules Tests', () {
    final mockBackend = MockBackendHandler();

    test('Rule 1: Expired subscription cannot generate QR check-in or book classes', () async {
      mockBackend.isMemberSubscriptionActive = false;

      // QR Check-in test
      final qrRes = await mockBackend.handleRequest(method: 'GET', path: '/me/qr-token');
      expect(qrRes['status_code'], 400);
      expect(qrRes['payload']['success'], isFalse);

      // Booking test
      final bookRes = await mockBackend.handleRequest(method: 'POST', path: '/classes/1/bookings');
      expect(bookRes['status_code'], 400);
      expect(bookRes['payload']['success'], isFalse);

      // Re-enable for subsequent tests
      mockBackend.isMemberSubscriptionActive = true;
    });

    test('Rule 3: Capacity limit blocks booking when class is full', () async {
      mockBackend.isMemberSubscriptionActive = true;

      // Class ID 3 in mock handler is initialized with free_places: 0
      final bookRes = await mockBackend.handleRequest(method: 'POST', path: '/classes/3/bookings');
      expect(bookRes['status_code'], 400);
      expect(bookRes['payload']['success'], isFalse);
      expect(bookRes['payload']['message'], contains('capacity'));
    });

    test('Rule 4: Booking cancellation blocked if < 2 hours before class start', () async {
      // Mock booking ID 102 is configured with starts_at 90 mins away (< 2h)
      final cancelRes = await mockBackend.handleRequest(method: 'DELETE', path: '/bookings/102');
      expect(cancelRes['status_code'], 400);
      expect(cancelRes['payload']['success'], isFalse);
      expect(cancelRes['payload']['message'], contains('2 hours'));
    });
  });
}
