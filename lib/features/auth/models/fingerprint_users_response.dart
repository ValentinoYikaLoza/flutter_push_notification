class FingerprintUsersResponse {
  final int status;
  final String message;
  final List<User> users;

  FingerprintUsersResponse({
    required this.status,
    required this.message,
    required this.users,
  });

  factory FingerprintUsersResponse.fromJson(Map<String, dynamic> json) =>
      FingerprintUsersResponse(
        status: json["status"],
        message: json["message"],
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
      };
}

class User {
  final String username;
  final String accountType;

  User({
    required this.username,
    required this.accountType,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json["username"],
        accountType: json["account_type"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "account_type": accountType,
      };
}
