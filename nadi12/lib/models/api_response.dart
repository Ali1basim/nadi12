class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final Map<String, dynamic>? errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode,
    T Function(dynamic dataJson)? fromDataJson,
  ) {
    final success = json['success'] as bool? ?? (statusCode >= 200 && statusCode < 300);
    final message = json['message'] as String? ?? (success ? 'Success' : 'An error occurred');
    final errors = json['errors'] is Map<String, dynamic>
        ? json['errors'] as Map<String, dynamic>
        : null;

    T? parsedData;
    if (json.containsKey('data') && json['data'] != null && fromDataJson != null) {
      parsedData = fromDataJson(json['data']);
    } else if (json['data'] != null && json['data'] is T) {
      parsedData = json['data'] as T;
    }

    return ApiResponse<T>(
      success: success,
      data: parsedData,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    int statusCode = 400,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      data: null,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }
}
