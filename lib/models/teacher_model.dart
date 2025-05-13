// models/teacher_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  final String id;
  final String name;
  final int age;
  final String address;
  final String email;
  final String department;
  final String role;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Teacher({
    required this.id,
    required this.name,
    required this.age,
    required this.address,
    required this.email,
    required this.department,
    this.role = 'teacher',
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Teacher.fromMap(Map<String, dynamic> data, String id) {
    return Teacher(
      id: id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      role: data['role'] ?? 'teacher',
      isVerified: data['isVerified'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'address': address,
      'email': email,
      'department': department,
      'role': role,
      'isVerified': isVerified,
      'updatedAt': DateTime.now(),
    };
  }

  Teacher copyWith({
    String? name,
    int? age,
    String? address,
    String? email,
    String? department,
    String? role,
    bool? isVerified,
  }) {
    return Teacher(
      id: this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      address: address ?? this.address,
      email: email ?? this.email,
      department: department ?? this.department,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}