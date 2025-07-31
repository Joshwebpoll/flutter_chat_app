class SingleModel {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final String status;
  final DateTime lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  SingleModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    required this.status,
    required this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SingleModel.fromJson(Map<String, dynamic> json) {
    return SingleModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      isVerified: json['isverified'],
      status: json['status'],
      lastLogin: DateTime.parse(json['lastLogin']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'isverified': isVerified,
      'status': status,
      'lastLogin': lastLogin.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
