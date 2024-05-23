class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime sentDate;
  final Map<String, dynamic> data;
  final String? imageUrl;

  PushMessage({
    required this.messageId,
    required this.title,
    required this.body,
    required this.sentDate,
    required this.data,
    this.imageUrl,
  });

  // Método fromJson para crear una instancia de PushMessage desde un JSON
  factory PushMessage.fromJson(Map<String, dynamic> json) {
    return PushMessage(
      messageId: json['messageId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      sentDate: DateTime.parse(json['sentDate'] as String),
      data: Map<String, dynamic>.from(json['data'] as Map),
      imageUrl: json['imageUrl'] as String,
    );
  }

  // Método toJson para convertir una instancia de PushMessage a un JSON
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'title': title,
      'body': body,
      'sentDate': sentDate.toIso8601String(),
      'data': data,
      'imageUrl': imageUrl,
    };
  }
}
