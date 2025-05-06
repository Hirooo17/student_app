// services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save student data
  Future<void> saveStudentData({
    required String userId,
    required String name,
    required int age,
    required String course,
    required int year,
    required String address,
    required List<String> subjects,
    required String email,
  }) async {
    await _firestore.collection('students').doc(userId).set({
      'name': name,
      'age': age,
      'course': course,
      'year': year,
      'address': address,
      'subjects': subjects,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update student data
  Future<void> updateStudentData({
    required String userId,
    String? name,
    int? age,
    String? course,
    int? year,
    String? address,
    List<String>? subjects,
  }) async {
    Map<String, dynamic> updateData = {};

    if (name != null) updateData['name'] = name;
    if (age != null) updateData['age'] = age;
    if (course != null) updateData['course'] = course;
    if (year != null) updateData['year'] = year;
    if (address != null) updateData['address'] = address;
    if (subjects != null) updateData['subjects'] = subjects;

    updateData['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('students').doc(userId).update(updateData);
  }

  // Get student data
  Future<DocumentSnapshot> getStudentData(String userId) {
    return _firestore.collection('students').doc(userId).get();
  }

  // Get all students (for admin)
  Stream<QuerySnapshot> getAllStudents() {
    return _firestore.collection('students').orderBy('name').snapshots();
  }

  // Search students by name (for admin)
  Stream<QuerySnapshot> searchStudentsByName(String searchTerm) {
    return _firestore
        .collection('students')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots();
  }

  Stream<QuerySnapshot> filterStudentsByCourse(String course) {
    return _firestore
        .collection('students')
        .where('course', isEqualTo: course)
        .orderBy('name')
        .snapshots();
  }

  // Save admin data with department
  Future<void> saveAdminData({
    required String userId,
    required String name,
    required int age,
    required String address,
    required String email,
    required String department,
  }) async {
    await _firestore.collection('teachers').doc(userId).set({
      'name': name,
      'age': age,
      'address': address,
      'email': email,
      'department': department,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Set user as admin in the admins collection
  Future<void> setUserAsAdmin(String userId) async {
    await _firestore.collection('admins').doc(userId).set({
      'isAdmin': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}