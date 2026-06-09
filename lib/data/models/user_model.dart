class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at']?.toString();
    final updatedAt = json['updated_at']?.toString();
    final emailVerifiedAt = json['email_verified_at'];

    return User(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      isVerified: json['is_verified'] == true || emailVerifiedAt != null,
      createdAt: createdAt != null
          ? DateTime.tryParse(createdAt) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: updatedAt != null
          ? DateTime.tryParse(updatedAt) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isMember => role == 'member';
  bool get isEmailVerified => isVerified;
}
