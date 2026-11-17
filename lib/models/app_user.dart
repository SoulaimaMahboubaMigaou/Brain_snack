class AppUser {
  const AppUser({
    this.id,
    required this.username,
    required this.password,
    required this.createdAt,
  });

  final int? id;
  final String username;
  final String password;
  final DateTime createdAt;

  AppUser copyWith({
    int? id,
    String? username,
    String? password,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
