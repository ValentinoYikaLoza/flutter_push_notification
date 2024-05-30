import 'package:dio/dio.dart';
import 'package:push_app_notification/config/api/api.dart';
import 'package:push_app_notification/features/home/models/get_notifications_model.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';

final api = Api();

class GetNotificationsService {
  static Future<GetNotificationsResponse> getNotifications({
    required int userId,
  }) async {
    try {
      final response = await api.get(
        '/getNotifications/$userId',
      );

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 200) {
        print(response.data);
        return GetNotificationsResponse.fromJson(response.data);
      } else {
        throw ServiceException(
            'Error al obtener las notificaciones: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Hubo un error en la conexión.';
      if (e.response != null) {
        if (e.response!.statusCode == 404) {
          return GetNotificationsResponse.fromJson(e.response!.data);
        }
      }
      throw ServiceException(errorMessage);
    } catch (e) {
      throw ServiceException('Algo salió mal: $e');
    }
  }
}

