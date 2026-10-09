import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/check_in_model.dart';
import 'api_client.dart';

class CheckInService {
  final ApiClient _apiClient = ApiClient();

  /// Endpoint: GET /me/check-ins
  Future<ApiResponse<List<CheckInModel>>> fetchCheckIns() async {
    return _apiClient.get<List<CheckInModel>>(
      endpoint: ApiConfig.myCheckInsEndpoint,
      fromDataJson: (json) {
        final list = json as List<dynamic>;
        return list.map((item) => CheckInModel.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }
}
