// services/superuser_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/models/student_model.dart';
import 'package:student_app/models/super_user_model.dart';
import 'package:student_app/models/teacher_model.dart';

class SuperUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create superuser
  Future<void> createSuperUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('superusers').doc(userId).set({
      'name': name,
      'email': email,
      'role': 'superuser',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Check if user is a superuser
  Future<bool> checkIfSuperUser(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('superusers').doc(uid).get();
    return userDoc.exists;
  }

  // Get superuser data
  Future<SuperUser?> getSuperUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('superusers').doc(uid).get();
    if (doc.exists) {
      return SuperUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Get all students
  Stream<List<Student>> getAllStudents() {
    return _firestore
        .collection('students')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all teachers
  Stream<List<Teacher>> getAllTeachers() {
    return _firestore
        .collection('teachers')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Teacher.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update student verification status
  Future<void> updateStudentVerificationStatus(String studentId, bool isVerified) async {
    await _firestore.collection('students').doc(studentId).update({
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update teacher verification status
  Future<void> updateTeacherVerificationStatus(String teacherId, bool isVerified) async {
    await _firestore.collection('teachers').doc(teacherId).update({
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update teacher department
  Future<void> updateTeacherDepartment(String teacherId, String department) async {
    await _firestore.collection('teachers').doc(teacherId).update({
      'department': department,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get student details
  Future<Student?> getStudentDetails(String studentId) async {
    DocumentSnapshot doc = await _firestore.collection('students').doc(studentId).get();
    if (doc.exists) {
      return Student.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Get teacher details
  Future<Teacher?> getTeacherDetails(String teacherId) async {
    DocumentSnapshot doc = await _firestore.collection('teachers').doc(teacherId).get();
    if (doc.exists) {
      return Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Search students by name
  Stream<List<Student>> searchStudentsByName(String searchTerm) {
    return _firestore
        .collection('students')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Search teachers by name
  Stream<List<Teacher>> searchTeachersByName(String searchTerm) {
    return _firestore
        .collection('teachers')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Teacher.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Filter teachers by department
  Stream<List<Teacher>> filterTeachersByDepartment(String department) {
    return _firestore
        .collection('teachers')
        .where('department', isEqualTo: department)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Teacher.fromMap(doc.data(), doc.id))
            .toList());
  }
}