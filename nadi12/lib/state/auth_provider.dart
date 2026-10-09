import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/mock_backend_handler.dart';
import '../services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();
  final MockBackendHandler _mockBackend = MockBackendHandler();

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _unauthorizedSub;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _unauthorizedSub = _apiClient.onUnauthorized.listen((_) {
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
    });
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final hasToken = await _authService.isLoggedIn();
    if (hasToken) {
      final userData = await _storage.getUserData();
      _user = UserModel(
        id: 1,
        name: userData['name'] as String,
        email: userData['email'] as String,
        memberId: 'NADI-84920',
        isSubscriptionActive: userData['is_subscription_active'] as bool,
        subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
        planName: 'All Access',
      );
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email: email, password: password);
      _isLoading = false;

      if (response.success && response.data != null) {
        final userJson = response.data!['user'] as Map<String, dynamic>?;
        if (userJson != null) {
          _user = UserModel.fromJson(userJson);
        } else {
          _user = UserModel(
            id: 1,
            name: 'Rana Samir',
            email: email,
            memberId: 'NADI-84920',
            isSubscriptionActive: _mockBackend.isMemberSubscriptionActive,
            subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
            planName: 'All Access',
          );
        }
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred during login. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _isAuthenticated = false;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Rule 1 Testing Helper: Toggle active / expired membership to verify business rules
  void toggleSubscriptionStatus() {
    if (_user != null) {
      final newStatus = !_user!.isSubscriptionActive;
      _user = _user!.copyWith(isSubscriptionActive: newStatus);
      _mockBackend.isMemberSubscriptionActive = newStatus;
      _storage.saveUserData(
        email: _user!.email,
        name: _user!.name,
        isSubscriptionActive: newStatus,
      );
      notifyListeners();
    }
  }

  /// Global 401 Testing Helper
  void triggerSimulated401() {
    _mockBackend.simulate401NextRequest = true;
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    super.dispose();
  }
}
