import 'dart:async';
import 'package:flutter/material.dart';
import '../models/qr_token_model.dart';
import '../services/qr_service.dart';
import '../widgets/state_view_handler.dart';

class QrProvider extends ChangeNotifier {
  final QrService _qrService = QrService();

  ViewStatus _status = ViewStatus.initial;
  QrTokenModel? _qrToken;
  String? _errorMessage;
  int _remainingSeconds = 0;
  Timer? _countdownTimer;
  bool _isAutoRefreshing = false;

  ViewStatus get status => _status;
  QrTokenModel? get qrToken => _qrToken;
  String? get errorMessage => _errorMessage;
  int get remainingSeconds => _remainingSeconds;
  bool get isAutoRefreshing => _isAutoRefreshing;

  double get progressPercentage {
    // Standard lifespan 60 seconds
    const totalDuration = 60.0;
    return (_remainingSeconds / totalDuration).clamp(0.0, 1.0);
  }

  Future<void> fetchQrToken({bool isSilentRefresh = false}) async {
    if (!isSilentRefresh) {
      _status = ViewStatus.loading;
      _errorMessage = null;
      notifyListeners();
    } else {
      _isAutoRefreshing = true;
      notifyListeners();
    }

    _stopCountdown();

    try {
      final response = await _qrService.fetchQrToken();

      if (response.success && response.data != null) {
        _qrToken = response.data;
        _remainingSeconds = _qrToken!.remainingSeconds;

        if (_qrToken!.token.isEmpty) {
          _status = ViewStatus.empty;
        } else {
          _status = ViewStatus.success;
          _startCountdown();
        }
      } else {
        _status = ViewStatus.error;
        _errorMessage = response.message;
      }
    } catch (e) {
      _status = ViewStatus.error;
      _errorMessage = 'Failed to load QR token: $e';
    } finally {
      _isAutoRefreshing = false;
      notifyListeners();
    }
  }

  void _startCountdown() {
    _stopCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _stopCountdown();
        // Rule 5: Auto-refresh when countdown reaches 0
        fetchQrToken(isSilentRefresh: true);
      }
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void manualRefresh() {
    fetchQrToken(isSilentRefresh: false);
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }
}
