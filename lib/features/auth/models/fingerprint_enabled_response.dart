class FingerprintTokenResponse {
    final int status;
    final String message;

    FingerprintTokenResponse({
        required this.status,
        required this.message,
    });

    factory FingerprintTokenResponse.fromJson(Map<String, dynamic> json) => FingerprintTokenResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
