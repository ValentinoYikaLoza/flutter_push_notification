class RegisterResponse {
    final int status;
    final String message;

    RegisterResponse({
        required this.status,
        required this.message,
    });

    factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
