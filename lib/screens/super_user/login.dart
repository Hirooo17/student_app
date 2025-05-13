// screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:student_app/controllers/super_user_controller.dart';
import 'package:student_app/screens/super_user/dashboard.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';

class SuperUserLoin extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const SuperUserLoin ({
    Key? key,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SuperUserLoin > {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  late SuperUserController _superUserController;

  @override
  void initState() {
    super.initState();
    _superUserController = SuperUserController(
      authService: widget.authService,
      databaseService: widget.databaseService,
    );
    _superUserController.addListener(_update);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _superUserController.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

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
      // Navigate directly to SuperUserDashboard without named routes
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SuperUserDashboard(
            superUser: _superUserController.currentSuperUser!,
            controller: _superUserController,
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Super User Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo or icon
                Icon(
                  Icons.admin_panel_settings,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 32),
                
                Text(
                  'Super User Access',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
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
                SizedBox(height: 24),
                
                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}