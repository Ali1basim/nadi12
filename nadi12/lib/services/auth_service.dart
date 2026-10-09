import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'secure_storage_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint: ApiConfig.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
      fromDataJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'] as String?;
      if (token != null) {
        await _storage.saveToken(token);
      }
      final userJson = response.data!['user'] as Map<String, dynamic>?;
      if (userJson != null) {
        final user = UserModel.fromJson(userJson);
        await _storage.saveUserData(
          userId: user.id.toString(),
          email: user.email,
          name: user.name,
          isSubscriptionActive: user.isSubscriptionActive,
        );
      }
    }

    return response;
  }

  Future<ApiResponse<UserModel>> fetchProfile() async {
    return _apiClient.get<UserModel>(
      endpoint: ApiConfig.userProfileEndpoint,
      fromDataJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }
}
