import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../models/gym_class_model.dart';
import '../services/class_service.dart';
import '../widgets/state_view_handler.dart';

class ScheduleProvider extends ChangeNotifier {
  final ClassService _classService = ClassService();

  ViewStatus _status = ViewStatus.initial;
  List<GymClassModel> _classes = [];
  String? _errorMessage;

  DateTime _selectedDate = DateTime.now();

  // Track which class ID is currently processing booking action
  final Set<int> _bookingInProgressClassIds = {};

  ViewStatus get status => _status;
  List<GymClassModel> get classes => _classes;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  bool isBooking(int classId) => _bookingInProgressClassIds.contains(classId);

  String get formattedSelectedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void selectDate(DateTime date) {
    if (!DateUtils.isSameDay(_selectedDate, date)) {
      _selectedDate = date;
      notifyListeners();
      fetchClasses();
    }
  }

  Future<void> fetchClasses() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateParam = formattedSelectedDate;
      final response = await _classService.fetchClasses(date: dateParam);

      if (response.success && response.data != null) {
        _classes = response.data!;
        if (_classes.isEmpty) {
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
      _errorMessage = 'Failed to load class schedule: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Book class action
  /// Returns a record: (success, message, BookingModel?)
  Future<({bool success, String message, BookingModel? booking})> bookClass(
    GymClassModel gymClass,
  ) async {
    final classId = gymClass.id;
    _bookingInProgressClassIds.add(classId);
    notifyListeners();

    try {
      final response = await _classService.bookClass(classId: classId);

      if (response.success && response.data != null) {
        // Success: Decrement free places locally to reflect updated capacity immediately
        final index = _classes.indexWhere((c) => c.id == classId);
        if (index != -1) {
          final current = _classes[index];
          final updatedFreePlaces = current.freePlaces > 0 ? current.freePlaces - 1 : 0;
          _classes[index] = current.copyWith(freePlaces: updatedFreePlaces);
        }

        notifyListeners();
        return (
          success: true,
          message: response.message,
          booking: response.data,
        );
      } else {
        return (
          success: false,
          message: response.message,
          booking: null,
        );
      }
    } catch (e) {
      return (
        success: false,
        message: 'Network error occurred while booking: $e',
        booking: null,
      );
    } finally {
      _bookingInProgressClassIds.remove(classId);
      notifyListeners();
    }
  }

  /// Callback when a booking is cancelled from bookings screen: restore slot
  void restoreSlotForClass(int classId) {
    final index = _classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      final current = _classes[index];
      _classes[index] = current.copyWith(freePlaces: current.freePlaces + 1);
      notifyListeners();
    }
  }
}
