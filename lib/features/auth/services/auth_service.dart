import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:push_app_notification/features/auth/models/auth_response.dart';
import 'package:push_app_notification/config/api/api.dart';
import 'package:push_app_notification/features/auth/models/login_response.dart';
import 'package:push_app_notification/features/auth/models/register_response.dart';
import 'package:push_app_notification/features/home/models/added_element_model.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

final api = Api();

class AuthService {
  static Future<RegisterResponse> register({
    required String user,
    required String password,
  }) async {
    try {
      Map<String, dynamic> form = {
        'username': user,
        'password': password,
      };

      final dio = Dio();

      final response = await dio.post(
          'https://3464-181-67-60-239.ngrok-free.app/api/register',
          data: form);
      // Verifica el código de estado de la respuesta
      if (response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      } else {
        throw ServiceException('Usuario o contraseña incorrecta');
      }
    } on DioException catch (e) {
      String errorMessage = '';
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          errorMessage = 'El nombre de usuario ya está en uso.';
        } else {
          errorMessage = 'Hubo un error en la conexión.';
        }
      }
      throw ServiceException(errorMessage);
    } catch (e) {
      throw ServiceException('Algo salió mal.');
    }
  }

  static Future<LoginResponse> login({
    required String user,
    String? password,
  }) async {
    try {
      Map<String, dynamic> form = {
        'username': user,
        'password': password
      };

      final dio = Dio();

      final response = await dio.post(
          'https://3464-181-67-60-239.ngrok-free.app/api/login',
          data: form);
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

  static Future<RegisterResponse> registerGoogleAccount({
    required String idToken,
  }) async {
    try {
      Map<String, dynamic> form = {
        'id_token': idToken,
      };

      final dio = Dio();

      final response = await dio.post(
          'https://3464-181-67-60-239.ngrok-free.app/api/registerGoogle',
          data: form);
      // Verifica el código de estado de la respuesta
      if (response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      } else {
        throw ServiceException('Usuario o contraseña incorrecta');
      }
    } on DioException catch (e) {
      String errorMessage = '';
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          errorMessage = 'El nombre de usuario ya está en uso.';
        } else {
          errorMessage = 'Hubo un error en la conexión.';
        }
      }
      throw ServiceException(errorMessage);
    } catch (e) {
      throw ServiceException('Algo salió mal.');
    }
  }

  static Future<LoginResponse> loginGoogleAccount({
    required String idToken
  }) async {
    try {
      Map<String, dynamic> form = {
        'id_token': idToken,
      };

      final dio = Dio();

      final response = await dio.post(
          'https://3464-181-67-60-239.ngrok-free.app/api/loginGoogle',
          data: form);
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

class AddDeviceService {
  static Future<AddedElementResponse> addDevice({
    required String deviceToken,
  }) async {
    try {
      Map<String, dynamic> form = {
        'device_token': deviceToken
      };

      final response = await api.post(
        '/addDevice',
        data: form,
      );

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 201) {
        return AddedElementResponse.fromJson(response.data);
      } else {
        throw ServiceException(
            'Error al guardar la notificación: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Hubo un error en la conexión.';
      if (e.response != null) {
        print(e.response);
      }
      throw ServiceException(errorMessage);
    } catch (e) {
      throw ServiceException('Algo salió mal: $e');
    }
  }
}
