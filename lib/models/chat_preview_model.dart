// // ignore_for_file: public_member_api_docs, sort_constructors_first
// class ChatPreview {
//   final String userId;
//   final String name;
//   final String? image;
//   final String latestMessage;
//   final DateTime createdAt;
//   final int unreadCount;

//   ChatPreview({
//     required this.userId,
//     required this.name,
//     this.image,
//     required this.latestMessage,
//     required this.createdAt,
//     required this.unreadCount,
//   });

//   factory ChatPreview.fromJson(Map<String, dynamic> json) {
//     return ChatPreview(
//       userId: json['userId'] as String,
//       name: json['name'] as String,
//       image: json['imageUrl'] as String,
//       latestMessage: json['latestMessage'] as String,
//       createdAt: DateTime.parse(json['createdAt']),
//       unreadCount: json['unreadCount'] as int,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'name': name,
//       //'imageUrl': imageUrl,
//       'latestMessage': latestMessage,
//       'createdAt': createdAt.toIso8601String(),
//       'unreadCount': unreadCount,
//     };
//   }

//   // ✅ Add copyWith method
//   // ChatPreview copyWith({
//   //   String? userId,
//   //   String? name,
//   //   String? imageUrl,
//   //   String? latestMessage,
//   //   DateTime? createdAt,
//   //   int? unreadCount,
//   // }) {
//   //   return ChatPreview(
//   //     userId: userId ?? this.userId,
//   //     name: name ?? this.name,
//   //     //imageUrl: imageUrl ?? this.imageUrl,
//   //     latestMessage: latestMessage ?? this.latestMessage,
//   //     createdAt: createdAt ?? this.createdAt,
//   //     unreadCount: unreadCount ?? this.unreadCount,
//   //   );
//   // }

//   ChatPreview copyWith({
//     String? userId,
//     String? name,
//     String? image,
//     String? latestMessage,
//     DateTime? createdAt,
//     int? unreadCount,
//   }) {
//     return ChatPreview(
//       userId: userId ?? this.userId,
//       name: name ?? this.name,
//       image: image ?? this.image,
//       latestMessage: latestMessage ?? this.latestMessage,
//       createdAt: createdAt ?? this.createdAt,
//       unreadCount: unreadCount ?? this.unreadCount,
//     );
//   }
// }
class ChatPreview {
  final String userId;
  final String name;
  final String latestMessage;
  final String imageUrl;
  final DateTime createdAt;
  final int unreadCount;

  ChatPreview({
    required this.userId,
    required this.name,
    required this.latestMessage,
    required this.imageUrl,
    required this.createdAt,
    required this.unreadCount,
  });

  ChatPreview copyWith({
    String? userId,
    String? name,
    String? latestMessage,
    String? imageUrl,
    DateTime? createdAt,
    int? unreadCount,
  }) {
    return ChatPreview(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      latestMessage: latestMessage ?? this.latestMessage,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// ✅ Factory constructor to create from JSON
  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      userId: json['userId'] as String,
      name: json['name'] as String,
      latestMessage: json['latestMessage'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      unreadCount: json['unreadCount'] as int,
    );
  }

  /// ✅ Optional: Convert to JSON (useful for saving to local storage or sending to API)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'latestMessage': latestMessage,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
