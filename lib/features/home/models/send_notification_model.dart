class SendNotificationResponse {
    final String name;

    SendNotificationResponse({
        required this.name,
    });

    factory SendNotificationResponse.fromJson(Map<String, dynamic> json) => SendNotificationResponse(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}
