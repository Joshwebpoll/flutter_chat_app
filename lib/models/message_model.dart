class Message {
  final String id;
  final String sender;
  final String receiver;
  final String message;

  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,

    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] as String,
      sender: json['sender'] as String,
      receiver: json['receiver'] as String,
      message: json['message'] as String,

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'receiver': receiver,
      'message': message,

      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
