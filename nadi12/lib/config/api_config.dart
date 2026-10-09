class ApiConfig {
  /// Base URL configured via compile-time environment variable,
  /// with a default fallback to production or local development gateway.
  static const String baseUrl = String.fromEnvironment(
    'NADI_API_BASE_URL',
    defaultValue: 'https://api.nadi-gym.com/v1',
  );

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String qrTokenEndpoint = '/me/qr-token';
  static const String classesEndpoint = '/classes';
  static const String myBookingsEndpoint = '/me/bookings';
  static const String myCheckInsEndpoint = '/me/check-ins';
  static const String userProfileEndpoint = '/me/profile';

  static String classBookingEndpoint(int classId) => '/classes/$classId/bookings';
  static String cancelBookingEndpoint(int bookingId) => '/bookings/$bookingId';

  // Request timeout
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
