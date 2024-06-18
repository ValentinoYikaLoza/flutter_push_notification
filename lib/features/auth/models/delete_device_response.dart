class DeleteDeviceResponse {
    final int status;
    final String message;

    DeleteDeviceResponse({
        required this.status,
        required this.message,
    });

    factory DeleteDeviceResponse.fromJson(Map<String, dynamic> json) => DeleteDeviceResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
