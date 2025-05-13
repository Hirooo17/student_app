// screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:student_app/screens/teacher/admin_dashboard.dart';
import 'package:student_app/screens/authentication/registration_screen.dart';
import 'package:student_app/screens/super_user/login.dart';
import 'package:student_app/screens/super_user/register.dart';
import 'package:student_app/screens/student/profile/student_dashboard.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:student_app/utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isAdmin = false; // Added to track if user is logging in as admin
  bool _isSuperUser = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Header section
                Center(
                  child: Lottie.network(
                    'https://assets1.lottiefiles.com/packages/lf20_jcikwtux.json',
                    height: 180,
                    controller: _animationController,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: -0.2,
                      end: 0,
                      duration: 800.ms,
                      curve: Curves.easeOutQuad,
                    ),

                const SizedBox(height: 40),

                Text(
                  'Welcome back',
                  style: AppTheme.headingLarge,
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

                const SizedBox(height: 8),

                Text(
                  _isAdmin
                      ? 'Sign in to access your admin account'
                      : 'Sign in to access your student account',
                  style: AppTheme.bodyLarge
                      .copyWith(color: AppTheme.textSecondaryColor),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                const SizedBox(height: 40),

                // User type toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isAdmin
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          foregroundColor: !_isAdmin
                              ? Colors.white
                              : AppTheme.textSecondaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(8)),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isAdmin = false;
                          });
                        },
                        child: Text('Student'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAdmin
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          foregroundColor: _isAdmin
                              ? Colors.white
                              : AppTheme.textSecondaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(8)),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isAdmin = true;
                          });
                        },
                        child: Text('Admin'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 450.ms),

                const SizedBox(height: 24),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.primaryColor),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 500.ms)
                          .slideX(
                            begin: -0.1,
                            end: 0,
                            duration: 600.ms,
                            delay: 500.ms,
                            curve: Curves.easeOutQuad,
                          ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: AppTheme.primaryColor),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .slideX(
                            begin: -0.1,
                            end: 0,
                            duration: 600.ms,
                            delay: 600.ms,
                            curve: Curves.easeOutQuad,
                          ),

                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Forgot password functionality coming soon!')),
                            );
                          },
                          child: Text('Forgot Password?'),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 700.ms),

                      const SizedBox(height: 24),

                      CustomWidgets.loadingButton(
                        isLoading: _isLoading,
                        onPressed: _login,
                        text: 'Sign In',
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 800.ms)
                          .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 600.ms,
                            delay: 800.ms,
                            curve: Curves.easeOutQuad,
                          ),

                      const SizedBox(height: 40),

                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          'Or',
                          style: AppTheme.bodyMedium
                              .copyWith(color: AppTheme.textSecondaryColor),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SuperUserRegistrationScreen()),
                          );
                        },
                        icon: Icon(Icons.admin_panel_settings_outlined),
                        label: Text(
                          'Login as Super User',
                          style: AppTheme.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Only show registration option for students
                      if (!_isAdmin)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New student? ',
                              style: AppTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegistrationScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Create an account',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          if (_isAdmin) {
            bool isAdmin = await _authService.checkIfAdmin(user.uid);
            if (!isAdmin) {
              // Not an admin, show error and sign out
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Access Denied'),
                  content: Text('This account does not have admin privileges.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              );
              await _authService.signOut();
              setState(() {
                _isLoading = false;
              });
              return;
            }

            await _navigateToAdminDashboard(user.uid);
          } else {
            bool isAdmin = await _authService.checkIfAdmin(user.uid);
            if (isAdmin) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Admin Account Detected'),
                  content: Text(
                      'This account has admin privileges. Would you like to login to the admin dashboard instead?'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _navigateToAdminDashboard(user.uid);
                      },
                      child: Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _navigateToStudentDashboard(user.uid);
                      },
                      child: Text('No'),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }

            await _navigateToStudentDashboard(user.uid);
          }
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Error'),
            content: Text('Failed to sign in: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fix for the _navigateToStudentDashboard method in login_screen.dart
  Future<void> _navigateToStudentDashboard(String uid) async {
    DocumentSnapshot studentData =
        await FirebaseFirestore.instance.collection('students').doc(uid).get();

    // Create a map with the student data
    Map<String, dynamic> studentDataMap =
        studentData.data() as Map<String, dynamic>;

    // Add the uid to the student data map explicitly
    studentDataMap['uid'] = uid;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDashboard(
          studentData: studentDataMap,
        ),
      ),
    );
  }

  Future<void> _navigateToAdminDashboard(String uid) async {
    DocumentSnapshot adminData =
        await FirebaseFirestore.instance.collection('teachers').doc(uid).get();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdminDashboard(
          adminData: adminData.data() as Map<String, dynamic>?,
        ),
      ),
    );
  }
}
