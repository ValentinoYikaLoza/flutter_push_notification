class AuthResponse {
    final int status;
    final String message;
    final User user;

    AuthResponse({
        required this.status,
        required this.message,
        required this.user,
    });

    factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        status: json["status"],
        message: json["message"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "user": user.toJson(),
    };
}

class User {
    final int id;
    final String username;

    User({
        required this.id,
        required this.username,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
    };
}
