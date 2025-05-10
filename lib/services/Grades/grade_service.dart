// services/grade_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/models/Grade.model.dart';

class GradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update a grade for a student
  Future<void> addGrade({
    required String studentId,
    required String subject,
    required double grade,
    required String teacherId,
  }) async {
    final gradeData = Grade(
      id: '', // Will be set by Firestore
      studentId: studentId,
      subject: subject,
      grade: grade,
      teacherId: teacherId,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('grades')
        .add(gradeData.toMap());
  }

  // Get all grades for a student
  Stream<List<Grade>> getGrades(String studentId) {
    return _firestore
        .collection('students')
        .doc(studentId)
        .collection('grades')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Grade.fromMap(doc.data(), doc.id))
            .toList());
  }
}