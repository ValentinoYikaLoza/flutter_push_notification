
class LoginResponse {
    final int status;
    final String message;
    final int userId;
    final String token;

    LoginResponse({
        required this.status,
        required this.message,
        required this.userId,
        required this.token,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        status: json["status"],
        message: json["message"],
        userId: json["userId"],
        token: json["token"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "userId": userId,
        "token": token,
    };
}
