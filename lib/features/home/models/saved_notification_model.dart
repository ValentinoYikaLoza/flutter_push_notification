class SavedNotificationResponse {
  final int status;
  final String message;
  
  SavedNotificationResponse({
    required this.status,
    required this.message,
  });

  factory SavedNotificationResponse.fromJson(Map<String, dynamic> json) =>
      SavedNotificationResponse(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
