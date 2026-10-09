import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/booking_model.dart';
import 'api_client.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

  /// Endpoint: GET /me/bookings
  Future<ApiResponse<List<BookingModel>>> fetchMyBookings() async {
    return _apiClient.get<List<BookingModel>>(
      endpoint: ApiConfig.myBookingsEndpoint,
      fromDataJson: (json) {
        final list = json as List<dynamic>;
        return list.map((item) => BookingModel.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Endpoint: DELETE /bookings/{id}
  Future<ApiResponse<dynamic>> cancelBooking({required int bookingId}) async {
    return _apiClient.delete<dynamic>(
      endpoint: ApiConfig.cancelBookingEndpoint(bookingId),
    );
  }
}
