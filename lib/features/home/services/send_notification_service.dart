import 'package:push_app_notification/config/api/api_FMC.dart';
import 'package:push_app_notification/features/home/models/send_notification_model.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';

final api = ApiFMC();

class SendNotificationService {
  static Future<SendNotificationResponse> sendNotification({
    required Map<String, dynamic> message,
  }) async {
    try {
      Map<String, dynamic> form = {"message": message};

      print("> Sending request with data: $form");

      final response = await api.post('/messages:send', data: form);
      print("> Response: ${response.data}");

      if (response.statusCode != 200) {
        print(
            "> Failed to send notification. Status code: ${response.statusCode}");
        print("Response data: ${response.data}");
        throw ServiceException('Failed to send notification');
      }

      return SendNotificationResponse.fromJson(response.data);
    } catch (e) {
      print("> Error in sendNotification: $e");
      throw ServiceException('> ocurrió un error: $e');
    }
  }
}
