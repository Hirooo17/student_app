import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class HomeworkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new homework assignment
  Future<void> createHomework({
    required String title,
    required String description,
    required String course,
    required DateTime dueDate,
    required String teacherId,
    required String createdBy,
    String? subject,
  }) async {
    await _firestore.collection('homework').add({
      'title': title,
      'description': description,
      'course': course,
      'subject': subject,
      'dueDate': Timestamp.fromDate(dueDate),
      'teacherId': teacherId,
      'createdAt': FieldValue.serverTimestamp(),
      'teacherName': createdBy
    });
  }

  // Get all homework assignments for a specific course
  Stream<QuerySnapshot> getHomeworkByCourse(String course) {
    return _firestore
        .collection('homework')
        .where('course', isEqualTo: course)
        .orderBy('dueDate', descending: false)
        .snapshots();
  }

  // Get all homework assignments (for admin/teacher)
  Stream<QuerySnapshot> getAllHomework() {
    return _firestore
        .collection('homework')
        .orderBy('dueDate', descending: false)
        .snapshots();
  }

  // Get homework assignments created by a specific teacher
  Stream<QuerySnapshot> getHomeworkByTeacher(String teacherId) {
    return _firestore
        .collection('homework')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('dueDate', descending: false)
        .snapshots();
  }

  // Delete a homework assignment
  Future<void> deleteHomework(String homeworkId) async {
    await _firestore.collection('homework').doc(homeworkId).delete();
  }

  // Update a homework assignment
  Future<void> updateHomework({
    required String homeworkId,
    String? title,
    String? description,
    String? course,
    String? subject,
    DateTime? dueDate,
  }) async {
    Map<String, dynamic> updateData = {};
    
    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (course != null) updateData['course'] = course;
    if (subject != null) updateData['subject'] = subject;
    if (dueDate != null) updateData['dueDate'] = Timestamp.fromDate(dueDate);
    
    updateData['updatedAt'] = FieldValue.serverTimestamp();
    
    await _firestore.collection('homework').doc(homeworkId).update(updateData);
  }

  // Mark homework as submitted for a student
  Future<void> submitHomework({
    required String homeworkId,
    required String studentId,
    required String studentName,
    String? comment,
  }) async {
    // Add to submissions subcollection
    await _firestore
        .collection('homework')
        .doc(homeworkId)
        .collection('submissions')
        .doc(studentId)
        .set({
      'studentId': studentId,
      'studentName': studentName,
      'comment': comment ?? '',
      'submittedAt': FieldValue.serverTimestamp(),
      'homeworkId': homeworkId, // Add homeworkId reference
    });
    
    // Also add to student-submissions collection for easy querying
    await _firestore
        .collection('student-submissions')
        .doc('${studentId}_${homeworkId}')
        .set({
      'studentId': studentId,
      'studentName': studentName,
      'comment': comment ?? '',
      'submittedAt': FieldValue.serverTimestamp(),
      'homeworkId': homeworkId,
    });
  }

  // Check if a student has submitted a homework assignment
  Future<bool> hasSubmitted({
    required String homeworkId,
    required String studentId,
  }) async {
    DocumentSnapshot submission = await _firestore
        .collection('homework')
        .doc(homeworkId)
        .collection('submissions')
        .doc(studentId)
        .get();
    
    return submission.exists;
  }

  // Get all submissions for a homework assignment (for teacher)
  Stream<QuerySnapshot> getHomeworkSubmissions(String homeworkId) {
    return _firestore
        .collection('homework')
        .doc(homeworkId)
        .collection('submissions')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }
  
  // Get all submissions by a student (for student submissions tab)
  Stream<QuerySnapshot> getStudentSubmissions(String studentId) {
    return _firestore
        .collection('student-submissions')
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }
  
  // Get homework by ID
  Future<DocumentSnapshot> getHomeworkById(String homeworkId) {
    return _firestore
        .collection('homework')
        .doc(homeworkId)
        .get();
  }
  
  // Get homework by course and subject
  Stream<QuerySnapshot> getHomeworkByCourseAndSubject(String course, String subject) {
    return _firestore
        .collection('homework')
        .where('course', isEqualTo: course)
        .where('subject', isEqualTo: subject)
        .orderBy('dueDate', descending: false)
        .snapshots();
  }
}