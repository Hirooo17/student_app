// services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/super_user_model.dart';

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
    bool isVerified = false, // Add isVerified parameter with default value
  }) async {
    await _firestore.collection('students').doc(userId).set({
      'name': name,
      'age': age,
      'course': course,
      'year': year,
      'address': address,
      'subjects': subjects,
      'email': email,
      'isVerified': isVerified, // Add isVerified field
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
    bool? isVerified, // Add isVerified parameter
  }) async {
    Map<String, dynamic> updateData = {};

    if (name != null) updateData['name'] = name;
    if (age != null) updateData['age'] = age;
    if (course != null) updateData['course'] = course;
    if (year != null) updateData['year'] = year;
    if (address != null) updateData['address'] = address;
    if (subjects != null) updateData['subjects'] = subjects;
    if (isVerified != null) updateData['isVerified'] = isVerified; // Add isVerified to update data

    updateData['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('students').doc(userId).update(updateData);
  }

  // Update student verification status
  Future<void> updateStudentVerification({
    required String userId,
    required bool isVerified,
  }) async {
    await _firestore.collection('students').doc(userId).update({
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get student data
  Future<DocumentSnapshot> getStudentData(String userId) {
    return _firestore.collection('students').doc(userId).get();
  }

  // Get all students (for admin and superuser)
  Stream<QuerySnapshot> getAllStudents() {
    return _firestore.collection('students').orderBy('name').snapshots();
  }

  // Search students by name (for admin and superuser)
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

  // Save admin/teacher data with department
  Future<void> saveAdminData({
    required String userId,
    required String name,
    required int age,
    required String address,
    required String email,
    required String department,
    bool isVerified = false, // Add isVerified parameter with default value
  }) async {
    await _firestore.collection('teachers').doc(userId).set({
      'name': name,
      'age': age,
      'address': address,
      'email': email,
      'department': department,
      'role': 'admin',
      'isVerified': isVerified, // Add isVerified field
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update teacher data (for superuser)
  Future<void> updateTeacherData({
    required String userId,
    String? name,
    int? age,
    String? address,
    String? department,
    bool? isVerified, // Add isVerified parameter
  }) async {
    Map<String, dynamic> updateData = {};

    if (name != null) updateData['name'] = name;
    if (age != null) updateData['age'] = age;
    if (address != null) updateData['address'] = address;
    if (department != null) updateData['department'] = department;
    if (isVerified != null) updateData['isVerified'] = isVerified; // Add isVerified to update data

    updateData['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('teachers').doc(userId).update(updateData);
  }

  // Update teacher verification status
  Future<void> updateTeacherVerification({
    required String userId,
    required bool isVerified,
  }) async {
    await _firestore.collection('teachers').doc(userId).update({
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get teacher data
  Future<DocumentSnapshot> getTeacherData(String userId) {
    return _firestore.collection('teachers').doc(userId).get();
  }

  // Get all teachers (for superuser)
  Stream<QuerySnapshot> getAllTeachers() {
    return _firestore.collection('teachers').orderBy('name').snapshots();
  }

  // Search teachers by name (for superuser)
  Stream<QuerySnapshot> searchTeachersByName(String searchTerm) {
    return _firestore
        .collection('teachers')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots();
  }

  // Filter teachers by department (for superuser)
  Stream<QuerySnapshot> filterTeachersByDepartment(String department) {
    return _firestore
        .collection('teachers')
        .where('department', isEqualTo: department)
        .orderBy('name')
        .snapshots();
  }

  // Set user as admin in the admins collection
  Future<void> setUserAsAdmin(String userId) async {
    await _firestore.collection('admins').doc(userId).set({
      'isAdmin': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Super User Functions
  
  // Save super user data
  Future<void> saveSuperUserData({
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

  // Set user as superuser in the superusers collection
  Future<void> setUserAsSuperUser(String userId) async {
    await _firestore.collection('superusers').doc(userId).set({
      'isSuperUser': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Check if user is a superuser
  Future<bool> checkIfSuperUser(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('superusers').doc(uid).get();
    return userDoc.exists;
  }

  // Get superuser data
  Future<SuperUser?> getSuperUserData(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('superusers').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return SuperUser.fromMap(doc.data() as Map<String, dynamic>, userId);
    }
    return null;
  }
}