// screens/teacher/grade_input_screen.dart
import 'package:flutter/material.dart';
import 'package:student_app/models/Grade.model.dart';
import 'package:student_app/screens/admin/Grades/grade_viewer.dart';
import 'package:student_app/services/Grades/grade_service.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:student_app/utils/app_theme.dart';

class GradeInputScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const GradeInputScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  _GradeInputScreenState createState() => _GradeInputScreenState();
}

class _GradeInputScreenState extends State<GradeInputScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubject;
  double? _grade;
  final _gradeService = GradeService();
  final _databaseService = DatabaseService();
  final _authService = AuthService();
  List<String> _subjects = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isTeacher = false;
  String? _teacherId;
  Stream<List<Grade>>? _gradesStream;

  @override
  void initState() {
    super.initState();
    _initializeTeacher();
  }

  Future<void> _initializeTeacher() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        _showSnackBar('You must be signed in', isError: true);
        Navigator.pop(context);
        return;
      }
      _teacherId = user.uid;
      _isTeacher = await _authService.checkIfAdmin(_teacherId!);
      if (!_isTeacher) {
        _showSnackBar('Only teachers can assign grades', isError: true);
        Navigator.pop(context);
        return;
      }
      await _fetchStudentSubjects();
      _gradesStream = _gradeService.getGrades(widget.studentId);
    } catch (e) {
      _showSnackBar('Error initializing: $e', isError: true);
      Navigator.pop(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStudentSubjects() async {
    final studentDoc = await _databaseService.getStudentData(widget.studentId);
    final studentData = studentDoc.data() as Map<String, dynamic>;
    setState(() {
      _subjects = List<String>.from(studentData['subjects'] ?? []);
    });
  }

  Future<void> _submitGrade() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSubmitting = true);
      try {
        await _gradeService.addGrade(
          studentId: widget.studentId,
          subject: _selectedSubject!,
          grade: _grade!,
          teacherId: _teacherId!,
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedSubject = null;
          _grade = null;
        });
        _showSnackBar('Grade submitted successfully', isError: false);
      } catch (e) {
        _showSnackBar('Error submitting grade: $e', isError: true);
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text('Grade for ${widget.studentName}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header with student info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 32,
                          child: Text(
                            widget.studentName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.studentName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Add New Grade',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Grade Input Form
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'New Grade Entry',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              // Subject dropdown with better styling
                              DropdownButtonFormField<String>(
                                value: _selectedSubject,
                                hint: const Text('Select Subject'),
                                items: _subjects
                                    .map((subject) => DropdownMenuItem(
                                          value: subject,
                                          child: Text(subject),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSubject = value;
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'Please select a subject' : null,
                                decoration: InputDecoration(
                                  labelText: 'Subject',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.book),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Grade input with slider
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Grade (0-100)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      prefixIcon: const Icon(Icons.grade),
                                      suffixText: _grade != null
                                          ? '${_gradeToLetter(_grade!)} (${_grade!.toStringAsFixed(1)})'
                                          : null,
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a grade';
                                      }
                                      final grade = double.tryParse(value);
                                      if (grade == null || grade < 0 || grade > 100) {
                                        return 'Enter a valid grade between 0 and 100';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      final grade = double.tryParse(value);
                                      if (grade != null && grade >= 0 && grade <= 100) {
                                        setState(() {
                                          _grade = grade;
                                        });
                                      }
                                    },
                                    onSaved: (value) {
                                      _grade = double.parse(value!);
                                    },
                                  ),
                                  if (_grade != null) ...[
                                    const SizedBox(height: 8),
                                    Slider(
                                      value: _grade!,
                                      min: 0,
                                      max: 100,
                                      divisions: 100,
                                      label: _grade!.toStringAsFixed(1),
                                      activeColor: _getGradeColor(_grade!),
                                      onChanged: (value) {
                                        setState(() {
                                          _grade = value;
                                        });
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('0'),
                                        Text('50'),
                                        const Text('100'),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitGrade,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(
                                  _isSubmitting ? 'Submitting...' : 'Submit Grade',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Recent Grades for this student
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Grades',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.history),
                              ],
                            ),
                            const Divider(),
                            StreamBuilder<List<Grade>>(
                              stream: _gradesStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }
                                
                                final grades = snapshot.data ?? [];
                                
                                if (grades.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.grade,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'No grades available yet',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: grades.length > 5 ? 5 : grades.length,
                                  itemBuilder: (context, index) {
                                    final grade = grades[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: _getGradeColor(grade.grade),
                                        child: Text(
                                          _gradeToLetter(grade.grade),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        grade.subject,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        '${grade.grade.toStringAsFixed(1)} / 100',
                                      ),
                                      trailing: Text(
                                        _formatDate(grade.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            if (_gradesStream != null) ...[
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GradeViewerScreen(
                                          studentId: widget.studentId,
                                          studentName: widget.studentName,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.visibility,
                                    color: AppTheme.primaryColor,
                                  ),
                                  label: Text(
                                    'View All Grades',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  String _gradeToLetter(double grade) {
    if (grade >= 90) return 'A';
    if (grade >= 80) return 'B';
    if (grade >= 70) return 'C';
    if (grade >= 60) return 'D';
    return 'F';
  }
  
  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.blue;
    if (grade >= 70) return Colors.amber;
    if (grade >= 60) return Colors.orange;
    return Colors.red;
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

