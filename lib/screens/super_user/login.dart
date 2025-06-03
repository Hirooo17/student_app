// screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:student_app/controllers/super_user_controller.dart';
import 'package:student_app/screens/super_user/dashboard.dart';
import 'package:student_app/screens/super_user/register.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Add this package for animations

class SuperUserLogin extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const SuperUserLogin({
    Key? key,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SuperUserLogin> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late SuperUserController _superUserController;

  @override
  void initState() {
    super.initState();
    _superUserController = SuperUserController(
      authService: widget.authService,
      databaseService: widget.databaseService,
    );
    _superUserController.addListener(_update);
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _superUserController.removeListener(_update);
    _animationController.dispose();
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Haptic feedback when pressing login button
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _superUserController.signInSuperUser(
        context: context,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && _superUserController.currentSuperUser != null) {
        // Navigate directly to SuperUserDashboard with page transition
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => SuperUserDashboard(
              superUser: _superUserController.currentSuperUser!,
              controller: _superUserController,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define our light red theme colors
    final primaryColor = Color(0xFFE57373);
    final secondaryColor = Color(0xFFFFCDD2);
    final accentColor = Color(0xFFD32F2F);
    final backgroundColor = Color(0xFFFFF5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App logo with animation
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 70,
                          color: accentColor,
                        ).animate()
                          .scale(duration: 600.ms, curve: Curves.easeOutBack)
                          .then(delay: 200.ms)
                          .fade(duration: 300.ms),
                      ),
                    ).animate()
                      .moveY(
                        begin: 20, 
                        end: 0, 
                        duration: 600.ms,
                        curve: Curves.easeOutQuad
                      ),
                    
                    SizedBox(height: 40),
                    
                    // Title with animation
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ).animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .moveY(begin: 10, end: 0, delay: 300.ms, duration: 500.ms),
                      
                    SizedBox(height: 8),
                    
                    Text(
                      'Sign in to your super user account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ).animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms),
                      
                    SizedBox(height: 40),
                    
                    // Email field with animation
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                      ),
                    ).animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms)
                      .moveX(begin: -10, end: 0, delay: 500.ms, duration: 500.ms),
                    
                    SizedBox(height: 16),
                    
                    // Password field with animation
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey[600],
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                    ).animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .moveX(begin: 10, end: 0, delay: 600.ms, duration: 500.ms),
                    
                    SizedBox(height: 8),
                    
                    // Forgot password text
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: accentColor,
                        ),
                        child: Text('Forgot Password?'),
                      ),
                    ).animate()
                      .fadeIn(delay: 700.ms, duration: 500.ms),
                    
                    SizedBox(height: 32),
                    
                    // Login button with animation
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, accentColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ).animate()
                      .fadeIn(delay: 800.ms, duration: 500.ms)
                      .scale(delay: 800.ms, duration: 400.ms),
                    
                    SizedBox(height: 30),
                    
                    // Register text with animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => SuperUserRegistrationScreen()));
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: accentColor,
                            padding: EdgeInsets.zero,
                            minimumSize: Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate()
                      .fadeIn(delay: 900.ms, duration: 500.ms),
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