import 'package:dio/dio.dart';
import 'package:push_app_notification/config/api/api_auth.dart';
import 'package:push_app_notification/features/home/models/get_notifications_model.dart';
import 'package:push_app_notification/features/home/models/push_message.dart';
import 'package:push_app_notification/features/home/models/saved_notification_model.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';

final api = ApiAuth();

class SaveNotificationService {
  static Future<SavedNotificationResponse> saveNotification({
    required int userId,
    required PushMessage message,
  }) async {
    try {
      Map<String, dynamic> form = {"message": message};

      final response = await api.post(
        '/save-notification/$userId',
        data: form,
      );

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 201) {
        return SavedNotificationResponse.fromJson(response.data);
      } else {
        throw ServiceException('Error al guardar la notificación: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Hubo un error en la conexión.';
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errorMessage = 'Solicitud incorrecta: ${e.response!.data}';
            break;
          case 401:
            errorMessage = 'Usuario o contraseña incorrecta';
            break;
          case 403:
            errorMessage = 'Acceso denegado';
            break;
          case 404:
            errorMessage = 'Usuario no encontrado';
            break;
          default:
            errorMessage = 'Error del servidor: ${e.response!.statusCode}';
        }
      }
      throw ServiceException(errorMessage);
    } catch (e) {
      throw ServiceException('Algo salió mal: $e');
    }
  }
}

class GetNotificationsService {
  static Future<GetNotificationsResponse> getNotifications({
    required int userId,
  }) async {
    try {
      final response = await api.get(
        '/get-notifications/$userId',
      );

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        return GetNotificationsResponse.fromJson(response.data);
      } else {
        throw ServiceException('Error al obtener las notificaciones: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Hubo un error en la conexión.';
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errorMessage = 'Solicitud incorrecta: ${e.response!.data}';
            break;
          case 401:
            errorMessage = 'Usuario o contraseña incorrecta';
            break;
          case 403:
            errorMessage = 'Acceso denegado';
            break;
          case 404:
            errorMessage = 'Usuario no encontrado';
            break;
          default:
            errorMessage = 'Error del servidor: ${e.response!.statusCode}';
        }
      }
      throw ServiceException(errorMessage);
    } catch (e) {
      throw ServiceException('Algo salió mal: $e');
    }
  }
}
