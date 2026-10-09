import 'package:flutter/material.dart';
import '../models/check_in_model.dart';
import '../services/check_in_service.dart';
import '../widgets/state_view_handler.dart';

class AttendanceProvider extends ChangeNotifier {
  final CheckInService _checkInService = CheckInService();

  ViewStatus _status = ViewStatus.initial;
  List<CheckInModel> _checkIns = [];
  String? _errorMessage;

  ViewStatus get status => _status;
  List<CheckInModel> get checkIns => _checkIns;
  String? get errorMessage => _errorMessage;

  int get totalCheckIns => _checkIns.length;

  int get qrCheckInsCount =>
      _checkIns.where((c) => c.method.toLowerCase() == 'qr').length;

  int get codeCheckInsCount =>
      _checkIns.where((c) => c.method.toLowerCase() == 'code').length;

  Future<void> fetchCheckIns() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _checkInService.fetchCheckIns();

      if (response.success && response.data != null) {
        _checkIns = response.data!;
        // Sort chronologically descending
        _checkIns.sort((a, b) => b.checkedInAt.compareTo(a.checkedInAt));

        if (_checkIns.isEmpty) {
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
      _errorMessage = 'Failed to load attendance history: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Helper to test the Empty state on Screen 4
  void clearHistoryForEmptyTest() {
    _checkIns.clear();
    _status = ViewStatus.empty;
    notifyListeners();
  }
}
