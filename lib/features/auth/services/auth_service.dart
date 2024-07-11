import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:push_app_notification/config/constants/environment.dart';
import 'package:push_app_notification/features/auth/models/fingerprint_users_response.dart';
import 'package:push_app_notification/features/auth/models/login_response.dart';
import 'package:push_app_notification/features/auth/models/register_response.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

final dio = Dio(BaseOptions(baseUrl: Environment.urlBASE));

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

      final response = await dio.post('/register', data: form);
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
      Map<String, dynamic> form = {'username': user, 'password': password};

      final response = await dio.post('/login', data: form);
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

      final response = await dio.post('/registerGoogle', data: form);
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

  static Future<LoginResponse> loginGoogleAccount(
      {required String idToken}) async {
    try {
      Map<String, dynamic> form = {
        'id_token': idToken,
      };

      final response = await dio.post('/loginGoogle', data: form);
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

  static Future<RegisterResponse> registerFacebookAccount({
    required String accessToken,
  }) async {
    try {
      Map<String, dynamic> form = {
        'access_token': accessToken,
      };

      final response = await dio.post('/registerFacebook', data: form);
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

  static Future<LoginResponse> loginFacebookAccount(
      {required String accessToken}) async {
    try {
      Map<String, dynamic> form = {
        'access_token': accessToken,
      };

      final response = await dio.post('/loginFacebook', data: form);
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

  static Future<LoginResponse> loginWithFingerprint({
    required String username,
    required String deviceInfoToken,
  }) async {
    try {
      Map<String, dynamic> form = {
        'username': username,
        'device_info_token': deviceInfoToken
      };

      final response = await dio.post('/loginWithFingerprint', data: form);
      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw ServiceException('Usuario o contraseña incorrecta');
      }
    } on DioException catch (e) {
      String errorMessage = '';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Usuario no encontrado';
      } else {
        errorMessage = 'La huella digital no está habilitada para este usuario';
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

    // Calcula el tiempo restante hasta la expiración en segundos
    int timeRemainingInSeconds = expirationTimestamp - currentTimestamp;

    if (timeRemainingInSeconds <= 0) {
      return (false, 0);
    }
    return (true, timeRemainingInSeconds);
  }

  static Future<FingerprintUsersResponse> getUsersWithFingerprintToken({
    required String deviceInfoToken,
  }) async {
    try {
      Map<String, dynamic> form = {'device_info_token': deviceInfoToken};
      final response = await dio.get('/usersWithFingerprintToken', data: form);

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        return FingerprintUsersResponse.fromJson(response.data);
      } else {
        throw ServiceException('Usuarios no encontrados');
      }
    } catch (e) {
      throw ServiceException('Algo salió mal. $e');
    }
  }
}
