import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/booking_model.dart';
import '../models/gym_class_model.dart';
import 'api_client.dart';

class ClassService {
  final ApiClient _apiClient = ApiClient();

  /// Endpoint: GET /classes?date={YYYY-MM-DD}
  Future<ApiResponse<List<GymClassModel>>> fetchClasses({required String date}) async {
    return _apiClient.get<List<GymClassModel>>(
      endpoint: ApiConfig.classesEndpoint,
      queryParams: {'date': date},
      fromDataJson: (json) {
        final list = json as List<dynamic>;
        return list.map((item) => GymClassModel.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Endpoint: POST /classes/{id}/bookings
  Future<ApiResponse<BookingModel>> bookClass({required int classId}) async {
    return _apiClient.post<BookingModel>(
      endpoint: ApiConfig.classBookingEndpoint(classId),
      fromDataJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
