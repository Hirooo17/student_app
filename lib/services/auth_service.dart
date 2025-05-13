// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/super_user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Sign in error: $e');
      throw e;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Registration error: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is admin
  Future<bool> checkIfAdmin(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('admins').doc(uid).get();
    return userDoc.exists;
  }

  // Check if user is superuser
  Future<bool> checkIfSuperUser(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('superusers').doc(uid).get();
    return userDoc.exists;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user type (student, teacher, superuser)
  Future<String> getUserType(String uid) async {
    bool isSuperUser = await checkIfSuperUser(uid);
    if (isSuperUser) return 'superuser';
    
    bool isAdmin = await checkIfAdmin(uid);
    if (isAdmin) return 'teacher';
    
    // Check if user exists in students collection
    DocumentSnapshot studentDoc = await _firestore.collection('students').doc(uid).get();
    if (studentDoc.exists) return 'student';
    
    return 'unknown';
  }

  // Register a new superuser
  Future<User?> registerSuperUser(String email, String password, String name) async {
    try {
      // Register user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Save super user data to Firestore
        await _firestore.collection('superusers').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': 'superuser',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Add the user to the 'superusers' collection
        await _firestore.collection('superusers').doc(user.uid).set({
          'isSuperUser': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return user;
    } catch (e) {
      print('Super user registration error: $e');
      throw e;
    }
  }

  // Get current superuser data
  Future<SuperUser?> getCurrentSuperUserData() async {
    User? user = getCurrentUser();
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('superusers').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return SuperUser.fromMap(doc.data() as Map<String, dynamic>, user.uid);
      }
    }
    return null;
  }
}