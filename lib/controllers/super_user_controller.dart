// controllers/super_user_controller.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/super_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperUserController {
  final AuthService _authService;
  final DatabaseService _databaseService;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  SuperUser? _currentSuperUser;
  SuperUser? get currentSuperUser => _currentSuperUser;

  SuperUserController({
    required AuthService authService,
    required DatabaseService databaseService,
  }) : _authService = authService, _databaseService = databaseService;

  // Register a new super user
  Future<bool> registerSuperUser({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String superUserCode,
  }) async {
    if (isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Verify the super user code
      const validSuperUserCode = "SUPER_ADMIN_123"; // Example super user code
      
      if (superUserCode != validSuperUserCode) {
        _showError(context, 'Invalid super user code');
        return false;
      }

      // Register the super user
      final user = await _authService.registerSuperUser(email, password, name);
      
      if (user != null) {
        return true;
      }
      return false;
    } catch (e) {
      _showError(context, 'Super user registration failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in super user
  Future<bool> signInSuperUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    if (isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      
      if (user != null) {
        // Check if the user is a super user
        bool isSuperUser = await _authService.checkIfSuperUser(user.uid);
        
        if (isSuperUser) {
          // Get super user data
          _currentSuperUser = await _authService.getCurrentSuperUserData();
          return true;
        } else {
          await _authService.signOut();
          _showError(context, 'You are not authorized as a super user');
          return false;
        }
      }
      return false;
    } catch (e) {
      _showError(context, 'Sign in failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out super user
  Future<void> signOut() async {
    await _authService.signOut();
    _currentSuperUser = null;
  }

  // Get all students
  Stream<QuerySnapshot> getAllStudents() {
    return _databaseService.getAllStudents();
  }

  // Get all teachers
  Stream<QuerySnapshot> getAllTeachers() {
    return _databaseService.getAllTeachers();
  }
  
  // Search teachers by name - Added method
  Stream<QuerySnapshot> searchTeachersByName(String query) {
    return _databaseService.searchTeachersByName(query);
  }
  
  // Filter teachers by department - Added method
  Stream<QuerySnapshot> filterTeachersByDepartment(String department) {
    return _databaseService.filterTeachersByDepartment(department);
  }

  // Search teachers by name - Added method
  Stream<QuerySnapshot> searchStudentsByName(String query) {
    return _databaseService.searchStudentsByName(query);
  }
  
  // Filter teachers by department - Added method
  Stream<QuerySnapshot> filterStudentsByCourse(String course) {
    return _databaseService.filterStudentsByCourse(course);
  }


  // Update student verification status
  Future<void> updateStudentVerification({
    required String studentId,
    required bool isVerified,
  }) async {
    await _databaseService.updateStudentVerification(
      userId: studentId,
      isVerified: isVerified,
    );
  }

  // Update teacher verification status
  Future<void> updateTeacherVerification({
    required String teacherId,
    required bool isVerified,
  }) async {
    await _databaseService.updateTeacherVerification(
      userId: teacherId,
      isVerified: isVerified,
    );
  }
  
  // Update teacher details
  Future<void> updateTeacherDetails({
    required String teacherId,
    String? name,
    int? age,
    String? address,
    String? department,
  }) async {
    await _databaseService.updateTeacherData(
      userId: teacherId,
      name: name,
      age: age,
      address: address,
      department: department,
    );
  }

  // Helper to show error message
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // For state management
  final List<VoidCallback> _listeners = [];
  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}