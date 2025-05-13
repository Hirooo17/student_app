// models/student_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final int age;
  final String course;
  final int year;
  final String address;
  final List<String> subjects;
  final String email;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.name,
    required this.age,
    required this.course,
    required this.year,
    required this.address,
    required this.subjects,
    required this.email,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromMap(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      course: data['course'] ?? '',
      year: data['year'] ?? 1,
      address: data['address'] ?? '',
      subjects: List<String>.from(data['subjects'] ?? []),
      email: data['email'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'course': course,
      'year': year,
      'address': address,
      'subjects': subjects,
      'email': email,
      'isVerified': isVerified,
      'updatedAt': updatedAt,
    };
  }

  Student copyWith({
    String? name,
    int? age,
    String? course,
    int? year,
    String? address,
    List<String>? subjects,
    String? email,
    bool? isVerified,
  }) {
    return Student(
      id: this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      course: course ?? this.course,
      year: year ?? this.year,
      address: address ?? this.address,
      subjects: subjects ?? this.subjects,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}