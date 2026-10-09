import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../widgets/state_view_handler.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  ViewStatus _status = ViewStatus.initial;
  List<BookingModel> _bookings = [];
  String? _errorMessage;

  // Track which booking ID is currently being cancelled
  final Set<int> _cancellingBookingIds = {};

  ViewStatus get status => _status;
  List<BookingModel> get bookings => _bookings;
  String? get errorMessage => _errorMessage;

  bool isCancelling(int bookingId) => _cancellingBookingIds.contains(bookingId);

  Future<void> fetchMyBookings() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _bookingService.fetchMyBookings();

      if (response.success && response.data != null) {
        _bookings = response.data!;
        if (_bookings.isEmpty) {
          _status = ViewStatus.empty;
        } else {
          _status = ViewStatus.success;
        }
      } else {
        _status = ViewStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = ViewStatus.error;
      _errorMessage = 'Failed to load bookings: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Cancel booking action enforcing Rule 4
  Future<({bool success, String message, int? classId})> cancelBooking(
    BookingModel booking,
  ) async {
    final bookingId = booking.id;
    final classId = booking.classId;

    // Rule 4 (Cancellation Deadline): A booking can only be cancelled up to 2 hours before the class start time.
    if (!booking.canCancel) {
      return (
        success: false,
        message: 'Cancellation deadline passed: Classes can only be cancelled up to 2 hours prior to start time.',
        classId: null,
      );
    }

    _cancellingBookingIds.add(bookingId);
    notifyListeners();

    try {
      final response = await _bookingService.cancelBooking(bookingId: bookingId);

      if (response.success) {
        _bookings.removeWhere((b) => b.id == bookingId);
        if (_bookings.isEmpty) {
          _status = ViewStatus.empty;
        }
        notifyListeners();
        return (
          success: true,
          message: response.message,
          classId: classId,
        );
      } else {
        return (
          success: false,
          message: response.message,
          classId: null,
        );
      }
    } catch (e) {
      return (
        success: false,
        message: 'Network error occurred during cancellation: $e',
        classId: null,
      );
    } finally {
      _cancellingBookingIds.remove(bookingId);
      notifyListeners();
    }
  }

  /// Add new booking to list when booked from schedule screen
  void addBooking(BookingModel newBooking) {
    _bookings.insert(0, newBooking);
    _status = ViewStatus.success;
    notifyListeners();
  }
}
