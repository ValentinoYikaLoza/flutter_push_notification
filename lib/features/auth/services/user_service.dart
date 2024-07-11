import 'package:push_app_notification/config/api/api.dart';
import 'package:push_app_notification/features/auth/models/auth_response.dart';
import 'package:push_app_notification/features/auth/models/fingerprint_enabled_response.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';

final api = Api();

class UserService {
  static Future<AuthResponse> getUser() async {
    try {
      final response = await api.get('/getUser');

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServiceException('Usuario no encontrado');
      }
    } catch (e) {
      throw ServiceException('Algo salió mal. $e');
    }
  }

  static Future<FingerprintTokenResponse> toggleFingerprint({
    required String deviceInfoToken,
  }) async {
    try {
      Map<String, dynamic> form = {'device_info_token': deviceInfoToken};
      final response = await api.post('/toggleFingerprint', data: form);

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        return FingerprintTokenResponse.fromJson(response.data);
      } else {
        throw ServiceException('Usuario no encontrado');
      }
    } catch (e) {
      throw ServiceException('Algo salió mal. $e');
    }
  }
}
