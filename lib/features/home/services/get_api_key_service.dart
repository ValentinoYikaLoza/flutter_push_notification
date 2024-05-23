import 'package:push_app_notification/config/api/api_key.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';

final api = ApiKey();

class GetApiKeyService {
  Future<String> getApiKey() async {
    try {
      final response = await api.get('/');

      if (response.statusCode == 200) {
        // print('> correcto ${response.data}');
      } else {
        print('> ${response.statusCode}, ${response.statusMessage}');
      }

      return response.data;
      // Verifica el código de estado de la respuesta
    } catch (e) {
      // Maneja errores de conexión aquí
      throw ServiceException('Error de conexión: $e');
    }
  }
}
