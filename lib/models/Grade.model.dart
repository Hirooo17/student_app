import 'package:cloud_firestore/cloud_firestore.dart';

class Grade {
  final String id;
  final String studentId;
  final String subject;
  final double grade;
  final String teacherId;
  final DateTime createdAt;

  Grade({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.grade,
    required this.teacherId,
    required this.createdAt,
  });

  factory Grade.fromMap(Map<String, dynamic> data, String id) {
    return Grade(
      id: id,
      studentId: data['studentId'],
      subject: data['subject'],
      grade: (data['grade'] as num).toDouble(),
      teacherId: data['teacherId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'subject': subject,
      'grade': grade,
      'teacherId': teacherId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}