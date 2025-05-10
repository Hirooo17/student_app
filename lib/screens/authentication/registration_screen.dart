// screens/registration_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_app/controllers/registration_controller.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:student_app/screens/student/profile/student_dashboard.dart';
import 'package:student_app/screens/admin/admin_dashboard.dart';
import 'package:student_app/utils/app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final RegistrationController _controller;
  bool _obscurePassword = true;
  bool _isAdmin = false;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();

  // Year options
  String _selectedYear = '1st Year';
  final List<String> _yearOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Irregular'
  ];

  // Course options for students
  final List<String> _courseOptions = ['BSIT', 'BSCS', 'BSCE', 'BEED', 'BSA'];

  // Department options for admins
  String? _selectedDepartment;
  final List<String> _departmentOptions = [
    'College of Computer Studies',
    'College of Engineering',
    'College of Education',
    'College of Business Administration',
    'College of Arts and Sciences'
  ];

  @override
  void initState() {
    super.initState();
    _controller = RegistrationController(
      authService: AuthService(),
      databaseService: DatabaseService(),
    );
    _controller.addListener(_updateState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _nameController.dispose();
    _ageController.dispose();
    _courseController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

 Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _controller.register(
        context: context,
        isAdmin: _isAdmin,
        name: _nameController.text,
        age: _ageController.text,
        address: _addressController.text,
        email: _emailController.text,
        password: _passwordController.text,
        selectedYear: _selectedYear,
        course: _courseController.text.isEmpty ? _courseOptions[0] : _courseController.text,
        selectedDepartment: _selectedDepartment,
        adminCode: _adminCodeController.text,
      );

      if (success) {
        final user = AuthService().getCurrentUser();

        if (user != null) {
          if (_isAdmin) {
            bool isAdmin = await _authService.checkIfAdmin(user.uid);
            if (!isAdmin) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Access Denied', style: TextStyle(color: Colors.red)),
                  content: const Text('This account was not registered as an admin. Please double-check your admin code.\n\nNote: "PLS IMPROVE IN THIS SUBJECT 🔐"'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );

              await AuthService().signOut();
              setState(() {
                _isLoading = false;
              });
              return;
            }

            await _navigateToAdminDashboard(user.uid);
          } else {
            bool isAdmin = await _authService.checkIfAdmin(user.uid);
            if (isAdmin) {
              // Show cute confirmation dialog
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Admin Account Detected ✨'),
                  content: const Text(
                      'You registered as a student but your account has admin privileges. Would you like to go to the admin dashboard instead?'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _navigateToAdminDashboard(user.uid);
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _navigateToStudentDashboard(user.uid);
                      },
                      child: const Text('No'),
                    ),
                  ],
                ),
              );
            } else {
              await _navigateToStudentDashboard(user.uid);
            }
          }
        }
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Error 😢', style: TextStyle(color: Colors.red)),
          content: Text('Oops! Something went wrong while creating your account:\n${e.toString()}'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

Future<void> _navigateToStudentDashboard(String uid) async {
  DocumentSnapshot studentData =
      await FirebaseFirestore.instance.collection('students').doc(uid).get();
      
  // Create a map with the student data
  Map<String, dynamic> studentDataMap = studentData.data() as Map<String, dynamic>;
  
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
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isAdmin ? 'Admin Registration' : 'Student Registration'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.backgroundColor],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          _isAdmin ? Icons.admin_panel_settings : Icons.school,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'EARIST',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _isAdmin
                              ? 'Admin Registration'
                              : 'Student Registration',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User type toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_isAdmin
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            foregroundColor:
                                !_isAdmin ? AppTheme.primaryColor : Colors.grey,
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
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            foregroundColor:
                                _isAdmin ? AppTheme.primaryColor : Colors.grey,
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
                  ),

                  const SizedBox(height: 20),
                  CustomWidgets.modernCard(
                    padding: EdgeInsets.all(24),
                    elevation: 4,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: AppTheme.headingSmall,
                          ),
                          const SizedBox(height: 20),

                          // Name field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person,
                                  color: AppTheme.primaryColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Age field
                          TextFormField(
                            controller: _ageController,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              prefixIcon: Icon(Icons.cake,
                                  color: AppTheme.primaryColor),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your age';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid age';
                              }
                              return null;
                            },
                          ),

                          // Student-specific fields
                          if (!_isAdmin) ...[
                            const SizedBox(height: 16),

                            // Course dropdown
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Course',
                                prefixIcon: Icon(Icons.school,
                                    color: AppTheme.primaryColor),
                              ),
                              value: _courseOptions[0],
                              items: _courseOptions.map((String course) {
                                return DropdownMenuItem<String>(
                                  value: course,
                                  child: Text(course),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _courseController.text = newValue;
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Year dropdown
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Year Level',
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: AppTheme.primaryColor),
                              ),
                              value: _selectedYear,
                              items: _yearOptions.map((String year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedYear = newValue;
                                  });
                                }
                              },
                            ),
                          ],

                          // Admin-specific fields
                          if (_isAdmin) ...[
                            const SizedBox(height: 16),

                            // Department dropdown
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Department',
                                prefixIcon: Icon(Icons.business,
                                    color: AppTheme.primaryColor),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 12), // Add padding
                                border:
                                    OutlineInputBorder(), // Add border for better visual
                              ),
                              isExpanded:
                                  true, // This is the key to fix overflow
                              value: _selectedDepartment,
                              hint: Text('Select department'),
                              items:
                                  _departmentOptions.map((String department) {
                                return DropdownMenuItem<String>(
                                    value: department,
                                    child: Text(
                                      department,
                                      overflow: TextOverflow
                                          .ellipsis, // Handle long text ),
                                    ));
                              }).toList(),
                              validator: (value) {
                                if (_isAdmin &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please select your department';
                                }
                                return null;
                              },
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedDepartment = newValue;
                                  });
                                }
                              },
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Address field
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(Icons.home,
                                  color: AppTheme.primaryColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          // Account Information Section
                          Text(
                            'Account Information',
                            style: AppTheme.headingSmall,
                          ),
                          const SizedBox(height: 20),

                          // Email field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: _isAdmin
                                  ? 'Admin email'
                                  : 'Use your school email',
                              prefixIcon: Icon(Icons.email,
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
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock,
                                  color: AppTheme.primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          // Admin specific fields
                          if (_isAdmin) ...[
                            const SizedBox(height: 16),

                            // Admin verification code
                            TextFormField(
                              controller: _adminCodeController,
                              decoration: InputDecoration(
                                labelText: 'Admin Verification Code',
                                prefixIcon: Icon(Icons.verified_user,
                                    color: AppTheme.primaryColor),
                                hintText: 'Enter admin verification code',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter admin verification code';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 30),

                          // Register button
                          _controller.isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: AppTheme.primaryColor))
                              : CustomWidgets.loadingButton(
                                  isLoading: _controller.isLoading,
                                  onPressed: _register,
                                  text: 'Create Account',
                                  color: AppTheme.primaryColor,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
