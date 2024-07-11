class AuthResponse {
  final int status;
  final String message;
  final User user;
  final bool hasFingerprintToken;

  AuthResponse({
    required this.status,
    required this.message,
    required this.user,
    required this.hasFingerprintToken
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        status: json["status"],
        message: json["message"],
        user: User.fromJson(json["user"]),
        hasFingerprintToken: json["hasFingerprintToken"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "user": user.toJson(),
        "hasFingerprintToken": hasFingerprintToken,
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

  // Método toJson para convertir una instancia de PushMessage a un JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
      };
}
