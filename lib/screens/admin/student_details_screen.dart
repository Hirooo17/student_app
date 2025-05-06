// screens/admin/student_details_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> studentData;
  
  const StudentDetailsScreen({
    Key? key,
    required this.studentId,
    required this.studentData,
  }) : super(key: key);

  @override
  _StudentDetailsScreenState createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  late Map<String, dynamic> _studentData;
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  final List<String> _earistCourses = ['BSIT', 'BSCS', 'BSCE', 'BEED', 'BSA'];
  final Color _primaryColor = const Color(0xFFD32F2F); // Light red
  final Color _accentColor = const Color(0xFFFFCDD2); // Light red accent

  @override
  void initState() {
    super.initState();
    _studentData = Map<String, dynamic>.from(widget.studentData);
  }

  Future<void> _updateStudentData(Map<String, dynamic> updatedData) async {
    setState(() => _isLoading = true);
    
    try {
      await _databaseService.updateStudentData(
        userId: widget.studentId,
        course: updatedData['course'],
        subjects: List<String>.from(updatedData['subjects'] ?? []),
      );
      
      setState(() {
        _studentData = {..._studentData, ...updatedData};
        _isLoading = false;
      });
      
      _showSnackBar('Student information updated successfully', isError: false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error updating student information: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[800] : Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _editCourse() {
    String currentCourse = _studentData['course'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Select Course', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: DropdownButtonFormField<String>(
              value: currentCourse.isNotEmpty ? currentCourse : null,
              decoration: InputDecoration(
                labelText: 'EARIST Courses',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.school, color: _primaryColor),
              ),
              items: _earistCourses.map((course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateStudentData({'course': newValue});
                  Navigator.pop(context);
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _editSubjects() {
    List<String> currentSubjects = List<String>.from(_studentData['subjects'] ?? []);
    List<String> editedSubjects = List<String>.from(currentSubjects);
    final TextEditingController _subjectController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Manage Subjects', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  )),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Add Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add, color: _primaryColor),
                        onPressed: () {
                          if (_subjectController.text.isNotEmpty) {
                            setState(() {
                              editedSubjects.add(_subjectController.text);
                              _subjectController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (editedSubjects.isNotEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: editedSubjects.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.book, color: _primaryColor),
                            title: Text(editedSubjects[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[400]),
                              onPressed: () {
                                setState(() => editedSubjects.removeAt(index));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No subjects added yet'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      _updateStudentData({'subjects': editedSubjects});
                      Navigator.pop(context);
                    },
                    child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        title: const Text('Student Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 24),
                  _buildSubjectsSection(),
                  const SizedBox(height: 24),
                  _buildSystemInfoSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentColor,
                border: Border.all(color: _primaryColor, width: 2),
              ),
              child: Icon(Icons.person, size: 50, color: _primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              _studentData['name'] ?? 'Student Name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _studentData['email'] ?? 'No email',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                _studentData['course'] ?? 'No course',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: _primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoTile('Age', '${_studentData['age'] ?? 'N/A'}', Icons.cake),
            _buildEditableInfoTile('Course', _studentData['course'] ?? 'Not set', Icons.school, _editCourse),
            _buildInfoTile('Year Level', 'Year ${_studentData['year'] ?? 'N/A'}', Icons.class_),
            _buildInfoTile('Address', _studentData['address'] ?? 'Not provided', Icons.home),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.book, color: _primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Enrolled Subjects',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: _primaryColor),
                  onPressed: _editSubjects,
                ),
              ],
            ),
            const Divider(),
            if (_studentData['subjects'] != null && _studentData['subjects'].isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_studentData['subjects'] as List).map((subject) {
                  return Chip(
                    label: Text(subject.toString()),
                    backgroundColor: _accentColor,
                    shape: StadiumBorder(
                      side: BorderSide(color: _primaryColor.withOpacity(0.2)),
                    ),
                  );
                }).toList(),
              )
            else
              const Text('No subjects enrolled'),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: _primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'System Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoTile('Student ID', widget.studentId, Icons.badge),
            _buildInfoTile('Created', _formatTimestamp(_studentData['createdAt']), Icons.timer),
            _buildInfoTile('Last Updated', _formatTimestamp(_studentData['updatedAt']), Icons.update),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _primaryColor),
      title: Text(title, style: TextStyle(color: Colors.grey[600])),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEditableInfoTile(String title, String value, IconData icon, VoidCallback onEdit) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _primaryColor),
      title: Text(title, style: TextStyle(color: Colors.grey[600])),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: IconButton(
        icon: Icon(Icons.edit, size: 20, color: _primaryColor),
        onPressed: onEdit,
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot doc = await _databaseService.getStudentData(widget.studentId);
      setState(() {
        _studentData = doc.data() as Map<String, dynamic>;
        _isLoading = false;
      });
      _showSnackBar('Data refreshed successfully', isError: false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error refreshing data: $e', isError: true);
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return 'Not available';
  }
}