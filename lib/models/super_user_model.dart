// models/superuser_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  SuperUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'superuser',
    required this.createdAt,
  });

  factory SuperUser.fromMap(Map<String, dynamic> data, String id) {
    return SuperUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'superuser',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt,
    };
  }
}