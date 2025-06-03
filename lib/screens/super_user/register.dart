// screens/super_user_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/controllers/super_user_controller.dart';
import 'package:student_app/screens/super_user/login.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:animate_do/animate_do.dart';

class SuperUserRegistrationScreen extends StatefulWidget {
  const SuperUserRegistrationScreen({Key? key}) : super(key: key);

  @override
  _SuperUserRegistrationScreenState createState() =>
      _SuperUserRegistrationScreenState();
}

class _SuperUserRegistrationScreenState
    extends State<SuperUserRegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _superUserCodeController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late SuperUserController _superUserController;

  // Light red color scheme exactly as specified
  final Color _primaryColor = const Color(0xFFE57373);
  final Color _secondaryColor = const Color(0xFFFFCDD2);
  final Color _accentColor = const Color(0xFFD32F2F);
  final Color _backgroundColor = const Color(0xFFFFF5F5);

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    final databaseService = DatabaseService();
    _superUserController = SuperUserController(
      authService: authService,
      databaseService: databaseService,
    );

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
    _superUserController.addListener(_refresh);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _superUserCodeController.dispose();
    _superUserController.removeListener(_refresh);
    _animationController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _isLoading = _superUserController.isLoading;
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Add haptic feedback
      HapticFeedback.mediumImpact();
      
      bool success = await _superUserController.registerSuperUser(
        context: context,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        superUserCode: _superUserCodeController.text.trim(),
      );

      if (success && mounted) {
        // Success animation and feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Registration successful!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Animate out before navigating back
        _animationController.reverse().then((_) {
          Navigator.pop(context);
        });
      }
    }
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _primaryColor),
      prefixIcon: Icon(icon, color: _primaryColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _secondaryColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Header
                    FadeIn(
                      delay: Duration(milliseconds: 300),
                      child: ShakeX(
                        from: 10,
                        duration: Duration(milliseconds: 1500),
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 80,
                          color: _accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeIn(
                      delay: Duration(milliseconds: 400),
                      child: Text(
                        'Super User Registration',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _accentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    FadeIn(
                      delay: Duration(milliseconds: 500),
                      child: Text(
                        'Create your account to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 36),
                    
                    // Form Fields
                    FadeInLeft(
                      delay: Duration(milliseconds: 600),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: _getInputDecoration('Full Name', Icons.person),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    FadeInRight(
                      delay: Duration(milliseconds: 700),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: _getInputDecoration('Email', Icons.email),
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    FadeInLeft(
                      delay: Duration(milliseconds: 800),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: _primaryColor),
                          prefixIcon: Icon(Icons.lock, color: _primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: _primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _secondaryColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _accentColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    FadeInRight(
                      delay: Duration(milliseconds: 900),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: _primaryColor),
                          prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: _primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _secondaryColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _accentColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    FadeInLeft(
                      delay: Duration(milliseconds: 1000),
                      child: TextFormField(
                        controller: _superUserCodeController,
                        decoration: _getInputDecoration('Super User Code', Icons.code),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the super user code';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 36),
                    
                    // Register Button
                    FadeInUp(
                      delay: Duration(milliseconds: 1100),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: _accentColor.withOpacity(0.5),
                          disabledBackgroundColor: _accentColor.withOpacity(0.5),
                        ),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'CREATE ACCOUNT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Login Link
                    FadeInUp(
                      delay: Duration(milliseconds: 1200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Add haptic feedback
                              HapticFeedback.lightImpact();
                              
                              // Animate out
                              _animationController.reverse().then((_) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => SuperUserLogin(
                                      authService: AuthService(),
                                      databaseService: DatabaseService(),
                                    ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              });
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: _accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}