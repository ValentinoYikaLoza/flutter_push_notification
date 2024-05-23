import 'package:push_app_notification/features/home/models/push_message.dart';

class GetNotificationsResponse {
  final int status;
  final List<PushMessage> notifications;

  GetNotificationsResponse({
    required this.status,
    required this.notifications,
  });

  factory GetNotificationsResponse.fromJson(Map<String, dynamic> json) =>
      GetNotificationsResponse(
        status: json["status"],
        notifications: List<PushMessage>.from(
            json["notifications"].map((x) => PushMessage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "notifications":
            List<dynamic>.from(notifications.map((x) => x.toJson())),
      };
}