import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'mock_backend_handler.dart';
import 'secure_storage_service.dart';

typedef UnauthorizedCallback = void Function();

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final SecureStorageService _storage = SecureStorageService();
  final MockBackendHandler _mockHandler = MockBackendHandler();
  final http.Client _httpClient = http.Client();

  /// Global 401 Interceptor Stream
  final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();
  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  /// Optional custom callback
  UnauthorizedCallback? unauthorizedCallback;

  /// Prefer mock when development mode or offline
  bool useMockMode = true;

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _storage.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _handle401() async {
    // Clear credentials globally
    await _storage.clearAll();
    _unauthorizedController.add(null);
    unauthorizedCallback?.call();
  }

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, String>? queryParams,
    T Function(dynamic dataJson)? fromDataJson,
  }) async {
    return _sendRequest<T>(
      method: 'GET',
      endpoint: endpoint,
      queryParams: queryParams,
      fromDataJson: fromDataJson,
    );
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    Map<String, dynamic>? body,
    T Function(dynamic dataJson)? fromDataJson,
  }) async {
    return _sendRequest<T>(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      fromDataJson: fromDataJson,
    );
  }

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    Map<String, dynamic>? body,
    T Function(dynamic dataJson)? fromDataJson,
  }) async {
    return _sendRequest<T>(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      fromDataJson: fromDataJson,
    );
  }

  Future<ApiResponse<T>> _sendRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(dynamic dataJson)? fromDataJson,
  }) async {
    // If mock mode is active, use the MockBackendHandler
    if (useMockMode) {
      final mockResponse = await _mockHandler.handleRequest(
        method: method,
        path: endpoint,
        body: body,
        queryParams: queryParams,
      );

      final statusCode = mockResponse['status_code'] as int;
      final payload = mockResponse['payload'] as Map<String, dynamic>;

      if (statusCode == 401) {
        _handle401();
      }

      return ApiResponse<T>.fromJson(payload, statusCode, fromDataJson);
    }

    // Live HTTP Request
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(
        queryParameters: queryParams,
      );
      final headers = await _buildHeaders();

      http.Response response;
      switch (method) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers).timeout(ApiConfig.connectTimeout);
          break;
        case 'POST':
          response = await _httpClient
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(ApiConfig.connectTimeout);
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(uri, headers: headers, body: jsonEncode(body))
              .timeout(ApiConfig.connectTimeout);
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported.');
      }

      final statusCode = response.statusCode;
      Map<String, dynamic> jsonBody;
      try {
        jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        jsonBody = {
          'success': statusCode >= 200 && statusCode < 300,
          'message': response.body,
        };
      }

      // Check Global 401 Interceptor
      if (statusCode == 401) {
        _handle401();
      }

      return ApiResponse<T>.fromJson(jsonBody, statusCode, fromDataJson);
    } on SocketException {
      // If live backend is unreachable, seamlessly fall back to mock handler
      final mockResponse = await _mockHandler.handleRequest(
        method: method,
        path: endpoint,
        body: body,
        queryParams: queryParams,
      );
      final statusCode = mockResponse['status_code'] as int;
      final payload = mockResponse['payload'] as Map<String, dynamic>;
      if (statusCode == 401) {
        _handle401();
      }
      return ApiResponse<T>.fromJson(payload, statusCode, fromDataJson);
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Network error: $e',
        statusCode: 500,
      );
    }
  }
}
