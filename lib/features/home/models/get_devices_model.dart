class GetDevicesResponse {
  final int status;
  final String message;
  final List<Device>? devices;

  GetDevicesResponse({
    required this.status,
    required this.message,
    this.devices,
  });

  factory GetDevicesResponse.fromJson(Map<String, dynamic> json) {
    return GetDevicesResponse(
      status: json["status"],
      message: json["message"],
      devices: json["devices"] != null
          ? List<Device>.from(json["devices"].map((x) => Device.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "status": status,
      "message": message,
    };
    if (devices != null) {
      json["devices"] = List<dynamic>.from(devices!.map((x) => x.toJson()));
    }
    return json;
  }
}

class Device {
  final int id;
  final int userId;
  final String deviceToken;

  Device({
    required this.id,
    required this.userId,
    required this.deviceToken,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json["id"],
      userId: json["user_id"],
      deviceToken: json["device_token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "device_token": deviceToken,
    };
  }
}