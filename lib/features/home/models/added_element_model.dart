class AddedElementResponse {
  final int status;
  final String message;
  
  AddedElementResponse({
    required this.status,
    required this.message,
  });

  factory AddedElementResponse.fromJson(Map<String, dynamic> json) =>
      AddedElementResponse(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
