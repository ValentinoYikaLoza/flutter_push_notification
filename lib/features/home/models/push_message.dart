class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data; // Hacer data opcional

  PushMessage({
    required this.messageId,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data, // Hacer data opcional
  });

  // Método fromJson para crear una instancia de PushMessage desde un JSON
  factory PushMessage.fromJson(Map<String, dynamic> json) {
    return PushMessage(
      messageId: json['notification_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      data: json['data_sent'] != null ? Map<String, dynamic>.from(json['data_sent'] as Map) : null, // Manejar data opcional
    );
  }

  // Método toJson para convertir una instancia de PushMessage a un JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'notification_id': messageId,
      'title': title,
      'body': body,
    };
    if (imageUrl != null) {
      json['image_url'] = imageUrl;
    }
    if (data != null) { // Agregar data al JSON solo si no es null
      json['data_sent'] = data;
    }
    return json;
  }
}