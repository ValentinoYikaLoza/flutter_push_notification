import 'package:push_app_notification/config/api/api.dart';
import 'package:push_app_notification/features/auth/models/auth_response.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';

final api = Api();

class UserService{
  static Future<AuthResponse> getUser() async {
    try {
      final response = await api.get('/getUser');

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        // print(response.data);
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServiceException('Usuario o contraseña incorrecta');
      }
    } catch (e) {
      throw ServiceException('Algo salió mal. $e');
    }
  }
}