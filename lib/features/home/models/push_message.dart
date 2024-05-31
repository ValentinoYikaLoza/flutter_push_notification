class PushMessage {
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data; // Hacer data opcional

  PushMessage({
    required this.title,
    required this.body,
    this.imageUrl,
    this.data, // Hacer data opcional
  });

  // Método fromJson para crear una instancia de PushMessage desde un JSON
  factory PushMessage.fromJson(Map<String, dynamic> json) {
    return PushMessage(
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      data: json['data'] != null ? Map<String, dynamic>.from(json['data'] as Map) : null, // Manejar data opcional
    );
  }

  // Método toJson para convertir una instancia de PushMessage a un JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'title': title,
      'body': body,
    };
    if (imageUrl != null) {
      json['image_url'] = imageUrl;
    }
    if (data != null) { // Agregar data al JSON solo si no es null
      json['data'] = data;
    }
    return json;
  }
}