// screens/student/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/services/database_service.dart';
import 'package:student_app/utils/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final String studentId;

  EditProfileScreen({required this.studentId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Student data
  List<String> _subjects = [];
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      DocumentSnapshot doc = await _databaseService.getStudentData(widget.studentId);
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _courseController.text = data['course'] ?? '';
          _yearController.text = data['year']?.toString() ?? '';
          _addressController.text = data['address'] ?? '';
          _email = data['email'] ?? '';

          if (data['subjects'] != null) {
            _subjects = List<String>.from(data['subjects']);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Edit Profile'),
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
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            _nameController.text.isEmpty ? "S" : _nameController.text[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomWidgets.modernCard(
                    padding: EdgeInsets.all(24),
                    elevation: 4,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Information',
                            style: AppTheme.headingSmall,
                          ),
                          const SizedBox(height: 20),
                          
                          // Name field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
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
                              prefixIcon: Icon(Icons.cake, color: AppTheme.primaryColor),
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
                          const SizedBox(height: 16),
                          
                          // Course field (read-only)
                          TextFormField(
                            controller: _courseController,
                            decoration: InputDecoration(
                              labelText: 'Course',
                              prefixIcon: Icon(Icons.school, color: AppTheme.primaryColor),
                              suffixIcon: Tooltip(
                                message: 'Only admin can change this',
                                child: Icon(Icons.lock, color: AppTheme.textSecondaryColor),
                              ),
                            ),
                            readOnly: true,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          
                          // Year field (read-only)
                          TextFormField(
                            controller: _yearController,
                            decoration: InputDecoration(
                              labelText: 'Year Level',
                              prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                              suffixIcon: Tooltip(
                                message: 'Only admin can change this',
                                child: Icon(Icons.lock, color: AppTheme.textSecondaryColor),
                              ),
                            ),
                            readOnly: true,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          
                          // Address field
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(Icons.home, color: AppTheme.primaryColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Subjects display (read-only)
                          if (_subjects.isNotEmpty) ...[
                            Text(
                              'Your Subjects:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _subjects
                                    .map((subject) => Chip(
                                          label: Text(subject),
                                          backgroundColor: AppTheme.primaryLightColor.withOpacity(0.2),
                                          labelStyle: TextStyle(color: AppTheme.primaryDarkColor),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 30),
                          
                          // Save button
                          _isLoading
                              ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                              : CustomWidgets.loadingButton(
                                  isLoading: _isLoading,
                                  onPressed: _saveChanges,
                                  text: 'Save Changes',
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

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _databaseService.updateStudentData(
          userId: widget.studentId,
          name: _nameController.text,
          age: int.parse(_ageController.text),
          course: _courseController.text,
          year: int.parse(_yearController.text),
          address: _addressController.text,
          subjects: _subjects, // Keep existing subjects
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppTheme
            .errorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}