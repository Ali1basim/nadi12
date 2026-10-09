import 'dart:math';

/// In-memory mock server state to allow interactive testing of all business rules
/// when no live backend server is accessible.
class MockBackendHandler {
  static final MockBackendHandler _instance = MockBackendHandler._internal();
  factory MockBackendHandler() => _instance;
  MockBackendHandler._internal();

  bool simulate401NextRequest = false;
  bool isMemberSubscriptionActive = true;

  // Mock Bookings list
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 101,
      'class_id': 1,
      'class_name': 'Strength Foundations',
      'starts_at': DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
      'status': 'confirmed',
    },
    {
      'id': 102,
      'class_id': 2,
      'class_name': 'Yoga Flow & Core',
      'starts_at': DateTime.now().add(const Duration(minutes: 90)).toIso8601String(), // < 2h away to test Rule 4!
      'status': 'confirmed',
    },
  ];

  // Mock Check-ins list
  final List<Map<String, dynamic>> _checkIns = [
    {
      'id': 501,
      'checked_in_at': DateTime.now().subtract(const Duration(hours: 26)).toIso8601String(),
      'method': 'qr',
    },
    {
      'id': 502,
      'checked_in_at': DateTime.now().subtract(const Duration(days: 2, hours: 2)).toIso8601String(),
      'method': 'code',
    },
    {
      'id': 503,
      'checked_in_at': DateTime.now().subtract(const Duration(days: 4, hours: 5)).toIso8601String(),
      'method': 'qr',
    },
    {
      'id': 504,
      'checked_in_at': DateTime.now().subtract(const Duration(days: 6, hours: 1)).toIso8601String(),
      'method': 'qr',
    },
  ];

  // Mock Classes cache per date
  final Map<String, List<Map<String, dynamic>>> _classesByDate = {};

  List<Map<String, dynamic>> getClassesForDate(String dateStr) {
    if (_classesByDate.containsKey(dateStr)) {
      return _classesByDate[dateStr]!;
    }

    final parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
    final y = parsedDate.year;
    final m = parsedDate.month;
    final d = parsedDate.day;

    final initialClasses = [
      {
        'id': 1,
        'name': 'Strength Foundations',
        'starts_at': DateTime(y, m, d, 8, 0).toIso8601String(),
        'ends_at': DateTime(y, m, d, 9, 0).toIso8601String(),
        'capacity': 20,
        'free_places': 5,
      },
      {
        'id': 2,
        'name': 'Yoga Flow & Core',
        'starts_at': DateTime(y, m, d, 9, 30).toIso8601String(),
        'ends_at': DateTime(y, m, d, 10, 30).toIso8601String(),
        'capacity': 15,
        'free_places': 3,
      },
      {
        'id': 3,
        'name': 'CrossFit Conditioning',
        'starts_at': DateTime(y, m, d, 12, 0).toIso8601String(),
        'ends_at': DateTime(y, m, d, 13, 0).toIso8601String(),
        'capacity': 18,
        'free_places': 0, // Fully booked to test Rule 3 (Capacity Limit)!
      },
      {
        'id': 4,
        'name': 'HIIT Cardio Blast',
        'starts_at': DateTime(y, m, d, 17, 30).toIso8601String(),
        'ends_at': DateTime(y, m, d, 18, 30).toIso8601String(),
        'capacity': 25,
        'free_places': 12,
      },
      {
        'id': 5,
        'name': 'Full Body Strength',
        'starts_at': DateTime(y, m, d, 19, 0).toIso8601String(),
        'ends_at': DateTime(y, m, d, 20, 0).toIso8601String(),
        'capacity': 20,
        'free_places': 7,
      },
    ];

    _classesByDate[dateStr] = initialClasses;
    return initialClasses;
  }

  Future<Map<String, dynamic>> handleRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    // Artificial latency for authentic network feel
    await Future.delayed(const Duration(milliseconds: 350));

    // Test Global 401 Interceptor
    if (simulate401NextRequest) {
      simulate401NextRequest = false;
      return {
        'status_code': 401,
        'payload': {
          'success': false,
          'message': 'Unauthorized: Access token has expired or is invalid.',
          'errors': {'auth': 'Token invalid'},
        },
      };
    }

    // Login
    if (path == '/auth/login' && method == 'POST') {
      final email = body?['email'] as String? ?? '';
      if (email.isEmpty) {
        return {
          'status_code': 422,
          'payload': {
            'success': false,
            'message': 'Validation failed: Email is required.',
            'errors': {'email': 'The email field is required.'},
          },
        };
      }
      return {
        'status_code': 200,
        'payload': {
          'success': true,
          'message': 'Login successful.',
          'data': {
            'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
            'user': {
              'id': 1,
              'name': 'Rana Samir',
              'email': email,
              'member_id': 'NADI-84920',
              'role': 'member',
              'is_subscription_active': isMemberSubscriptionActive,
              'subscription_expiry': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
              'plan_name': 'All Access',
            },
          },
        },
      };
    }

    // GET /me/qr-token
    if (path == '/me/qr-token' && method == 'GET') {
      // Rule 1: Expired subscription cannot check in
      if (!isMemberSubscriptionActive) {
        return {
          'status_code': 400,
          'payload': {
            'success': false,
            'message': 'Subscription expired. Please renew your membership to generate a QR check-in token.',
            'errors': {'subscription': 'Subscription is inactive or expired.'},
          },
        };
      }

      // Rule 5: QR tokens are short-lived (60 seconds)
      final expiresAt = DateTime.now().add(const Duration(seconds: 60));
      final randomToken = 'NADI-MEMBER-QR-${Random().nextInt(900000) + 100000}-${DateTime.now().millisecondsSinceEpoch}';
      return {
        'status_code': 200,
        'payload': {
          'success': true,
          'message': 'QR token generated successfully.',
          'data': {
            'token': randomToken,
            'expires_at': expiresAt.toIso8601String(),
          },
        },
      };
    }

    // GET /classes
    if (path == '/classes' && method == 'GET') {
      final dateStr = queryParams?['date'] ?? DateTime.now().toIso8601String().split('T').first;
      final classes = getClassesForDate(dateStr);
      return {
        'status_code': 200,
        'payload': {
          'success': true,
          'message': 'Classes retrieved successfully.',
          'data': classes,
        },
      };
    }

    // POST /classes/{id}/bookings
    final bookingMatch = RegExp(r'^/classes/(\d+)/bookings$').firstMatch(path);
    if (bookingMatch != null && method == 'POST') {
      final classId = int.parse(bookingMatch.group(1)!);

      // Rule 1: Expired subscription cannot book classes
      if (!isMemberSubscriptionActive) {
        return {
          'status_code': 400,
          'payload': {
            'success': false,
            'message': 'Your membership subscription has expired. You cannot book classes.',
            'errors': {'subscription': 'Inactive membership'},
          },
        };
      }

      // Rule 2: Double booking check
      final alreadyBooked = _bookings.any((b) => b['class_id'] == classId && b['status'] == 'confirmed');
      if (alreadyBooked) {
        return {
          'status_code': 400,
          'payload': {
            'success': false,
            'message': 'You have already booked this class session (Double booking not allowed).',
            'errors': {'booking': 'Duplicate reservation'},
          },
        };
      }

      // Find class in cache (or initialize default today cache)
      if (_classesByDate.isEmpty) {
        getClassesForDate(DateTime.now().toIso8601String().split('T').first);
      }

      Map<String, dynamic>? targetClass;
      for (final list in _classesByDate.values) {
        for (final item in list) {
          if (item['id'] == classId) {
            targetClass = item;
            break;
          }
        }
      }

      if (targetClass != null) {
        // Rule 3: Capacity limit check
        if ((targetClass['free_places'] as int) <= 0) {
          return {
            'status_code': 400,
            'payload': {
              'success': false,
              'message': 'This class has reached its maximum capacity. No slots available.',
              'errors': {'capacity': 'Class is full'},
            },
          };
        }

        // Reduce free places
        targetClass['free_places'] = (targetClass['free_places'] as int) - 1;
      }

      final newBookingId = Random().nextInt(8000) + 1000;
      final newBooking = {
        'id': newBookingId,
        'class_id': classId,
        'class_name': targetClass?['name'] ?? 'Strength Foundations',
        'starts_at': targetClass?['starts_at'] ?? DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
        'status': 'confirmed',
      };
      _bookings.insert(0, newBooking);

      return {
        'status_code': 201,
        'payload': {
          'success': true,
          'message': 'Class booked successfully!',
          'data': newBooking,
        },
      };
    }

    // GET /me/bookings
    if (path == '/me/bookings' && method == 'GET') {
      return {
        'status_code': 200,
        'payload': {
          'success': true,
          'message': 'Bookings retrieved successfully.',
          'data': _bookings,
        },
      };
    }

    // DELETE /bookings/{id}
    final cancelMatch = RegExp(r'^/bookings/(\d+)$').firstMatch(path);
    if (cancelMatch != null && method == 'DELETE') {
      final bookingId = int.parse(cancelMatch.group(1)!);
      final index = _bookings.indexWhere((b) => b['id'] == bookingId);

      if (index == -1) {
        return {
          'status_code': 404,
          'payload': {
            'success': false,
            'message': 'Booking not found.',
            'errors': {'id': 'Not found'},
          },
        };
      }

      final booking = _bookings[index];
      final startsAt = DateTime.parse(booking['starts_at']);
      final difference = startsAt.difference(DateTime.now());

      // Rule 4: Cancellation Deadline (up to 2 hours before class start time)
      if (difference.inMinutes < 120) {
        return {
          'status_code': 400,
          'payload': {
            'success': false,
            'message': 'Cancellations are only allowed up to 2 hours prior to class start time.',
            'errors': {'deadline': 'Less than 2 hours remaining before class starts'},
          },
        };
      }

      // Restock capacity if class found
      final classId = booking['class_id'] as int;
      for (final list in _classesByDate.values) {
        for (final item in list) {
          if (item['id'] == classId) {
            item['free_places'] = (item['free_places'] as int) + 1;
            break;
          }
        }
      }

      _bookings.removeAt(index);

      return {
        'status_code': 200,
        'payload': {
          'success': true,
          'message': 'Booking cancelled successfully.',
          'data': {'id': bookingId},
        },
      };
    }

    // GET /me/check-ins
    if (path == '/me/check-ins' && method == 'GET') {
      return {
        'status_code': 200,
        'payload': {
          'success': true,
          'message': 'Attendance history retrieved successfully.',
          'data': _checkIns,
        },
      };
    }

    // GET /me/profile
    if (path == '/me/profile' && method == 'GET') {
      return {
        'status_code': 200,
        'payload': {
          'success': true,
          'message': 'Profile retrieved successfully.',
          'data': {
            'id': 1,
            'name': 'Rana Samir',
            'email': 'rana.samir@example.com',
            'member_id': 'NADI-84920',
            'role': 'member',
            'is_subscription_active': isMemberSubscriptionActive,
            'subscription_expiry': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'plan_name': 'All Access',
          },
        },
      };
    }

    return {
      'status_code': 404,
      'payload': {
        'success': false,
        'message': 'Endpoint not found: $path',
      },
    };
  }

  void resetBookings() {
    _bookings.clear();
  }

  void resetCheckIns() {
    _checkIns.clear();
  }
}
