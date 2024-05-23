import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

import '../models/login_response.dart';

class AuthService {
  static Future<LoginResponse> login({
    required String user,
    required String password,
  }) async {
    try {
      Map<String, dynamic> form = {
        'username': user,
        'password': password,
      };

      final dio = Dio();

      final response = await dio.post('https://9375-190-237-20-41.ngrok-free.app/login', data: form);
      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw ServiceException('Usuario o contraseña incorrecta');
      }
    } on DioException catch (e) {
      String errorMessage = '';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Usuario o contraseña incorrecta';
      } else {
        errorMessage = 'Hubo un error en la conexión.';
      }
      throw ServiceException(errorMessage);
    } catch (e) {
      throw ServiceException('Algo salió mal.');
    }
  }

  //JSON WEB TOKENS
  static Future<(bool, int)> verifyToken() async {
    final userToken = await StorageService.get<String>('userToken');
    if (userToken == null) return (false, 0);

    Map<String, dynamic> decodedToken = JwtDecoder.decode(userToken);

    // Obtiene la marca de tiempo de expiración del token
    int expirationTimestamp = decodedToken['exp'];

    // Obtiene la marca de tiempo actual
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    //si el token es invalido

    // Calcula el tiempo restante hasta la expiración en segundos
    int timeRemainingInSeconds = expirationTimestamp - currentTimestamp;

    if (timeRemainingInSeconds <= 0) {
      return (false, 0);
    }
    return (true, timeRemainingInSeconds);
  }
}
