import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyJwtToken = 'jwt_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keySubscriptionActive = 'subscription_active';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyJwtToken, value: token);
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyJwtToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyJwtToken);
  }

  Future<void> saveUserData({
    String? userId,
    required String email,
    required String name,
    required bool isSubscriptionActive,
  }) async {
    if (userId != null) {
      await _storage.write(key: _keyUserId, value: userId);
    }
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(
      key: _keySubscriptionActive,
      value: isSubscriptionActive ? 'true' : 'false',
    );
  }

  Future<Map<String, dynamic>> getUserData() async {
    final userId = await _storage.read(key: _keyUserId);
    final email = await _storage.read(key: _keyUserEmail);
    final name = await _storage.read(key: _keyUserName);
    final activeStr = await _storage.read(key: _keySubscriptionActive);
    return {
      'user_id': userId ?? '1',
      'email': email ?? 'rana.samir@example.com',
      'name': name ?? 'Rana Samir',
      'is_subscription_active': activeStr != 'false',
    };
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
