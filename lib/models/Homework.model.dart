// models/homework.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Homework {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String course;
  final String createdBy;
  final DateTime createdAt;
  final String? fileUrl; // For future file attachments

  Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.course,
    required this.createdBy,
    required this.createdAt,
    this.fileUrl,
  });

  factory Homework.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Homework(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      course: data['course'],
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      fileUrl: data['fileUrl'],
    );
  }
}