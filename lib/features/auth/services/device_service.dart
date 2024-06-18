import 'package:dio/dio.dart';
import 'package:push_app_notification/config/api/api.dart';
// import 'package:push_app_notification/features/auth/models/delete_device_response.dart';
import 'package:push_app_notification/features/home/models/added_element_model.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';

final api = Api();

class DeviceService {
  static Future<AddedElementResponse> addDevice({
    required String deviceToken,
  }) async {
    try {
      Map<String, dynamic> form = {'device_token': deviceToken};

      final response = await api.post(
        '/addDevice',
        data: form,
      );

      // Verifica el código de estado de la respuesta
      if (response.statusCode == 201) {
        return AddedElementResponse.fromJson(response.data);
      } else {
        throw ServiceException(
            'Error al guardar el dispositivo: ${response.statusCode}');
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
