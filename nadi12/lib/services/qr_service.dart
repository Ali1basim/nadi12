import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/qr_token_model.dart';
import 'api_client.dart';

class QrService {
  final ApiClient _apiClient = ApiClient();

  /// Endpoint: GET /me/qr-token
  Future<ApiResponse<QrTokenModel>> fetchQrToken() async {
    return _apiClient.get<QrTokenModel>(
      endpoint: ApiConfig.qrTokenEndpoint,
      fromDataJson: (json) => QrTokenModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
