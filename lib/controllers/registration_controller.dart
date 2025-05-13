// controllers/registration_controller.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class RegistrationController {
  final AuthService _authService;
  final DatabaseService _databaseService;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RegistrationController({
    required AuthService authService,
    required DatabaseService databaseService,
  }) : _authService = authService, _databaseService = databaseService;

  Future<bool> register({
    required BuildContext context,
    required bool isAdmin,
    required String name,
    required String age,
    required String address,
    required String email,
    required String password,
    String? selectedYear,
    String? course,
    String? selectedDepartment,
    String? adminCode,
    bool isVerified = false, // Default to false for new registrations
  }) async {
    if (isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // For admin registration, verify the admin code first
      if (isAdmin) {
        const adminCode = "EARIST123"; // Example code
        
        if (adminCode != adminCode) {
          _showError(context, 'Invalid admin code');
          return false;
        }
        
        // Validate department selection for admin
        if (selectedDepartment == null || selectedDepartment.isEmpty) {
          _showError(context, 'Please select your department');
          return false;
        }
      }

      // Register user with Firebase Auth
      final user = await _authService.registerWithEmailAndPassword(email, password);

      if (user != null) {
        if (isAdmin) {
          // Save admin data to Firestore
          await _databaseService.saveAdminData(
            userId: user.uid,
            name: name,
            age: int.parse(age),
            address: address,
            email: email,
            department: selectedDepartment!,
            isVerified: isVerified, // Add isVerified parameter
          );
          
          // Add the user to the 'admins' collection
          await _databaseService.setUserAsAdmin(user.uid);
        } else {
          // Convert year value to integer for student
          final yearValue = _convertYearToInt(selectedYear ?? '1st Year');
              
          // Save student data to Firestore
          await _databaseService.saveStudentData(
            userId: user.uid,
            name: name,
            age: int.parse(age),
            course: course ?? 'BSIT',
            year: yearValue,
            address: address,
            subjects: [],
            email: email,
            isVerified: isVerified, // Add isVerified parameter
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      _showError(context, 'Registration failed: ${e.toString()}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _convertYearToInt(String year) {
    switch (year) {
      case '1st Year': return 1;
      case '2nd Year': return 2;
      case '3rd Year': return 3;
      case '4th Year': return 4;
      case 'Irregular': return 0;
      default: return 1;
    }
  }

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