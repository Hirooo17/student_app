// models/super_user_model.dart
class SuperUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  SuperUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory SuperUser.fromMap(Map<String, dynamic> data, String uid) {
    return SuperUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'superuser',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': 'superuser',
      'createdAt': createdAt,
    };
  }
}