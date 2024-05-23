//Modelo o entidad de usuario
class AuthUser {
  final int id;
  final String user;

  AuthUser({
    required this.id,
    required this.user,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json["id"],
        user: json["user"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
      };
}
