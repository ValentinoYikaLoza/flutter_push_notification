import 'package:push_app_notification/features/home/models/push_message.dart';

class GetNotificationsResponse {
  final int status;
  final String message;
  final List<PushMessage>? notifications;

  GetNotificationsResponse({
    required this.status,
    required this.message,
    this.notifications,
  });

  factory GetNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return GetNotificationsResponse(
      status: json["status"],
      message: json["message"],
      notifications: json["notifications"] != null
          ? List<PushMessage>.from(
              json["notifications"].map((x) => PushMessage.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "status": status,
      "message": message,
    };
    if (notifications != null) {
      json["notifications"] = List<dynamic>.from(notifications!.map((x) => x.toJson()));
    }
    return json;
  }
}