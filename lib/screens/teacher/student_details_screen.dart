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
  
  // Updated color scheme for a modern and cute look
   final Color _primaryColor = const Color(0xFFE57373);
  final Color _secondaryColor = const Color(0xFFFFCDD2);
  final Color _accentColor = const Color(0xFFD32F2F);
  final Color _textColor = const Color(0xFF424242); // Dark grey for text

  @override
  void initState() {
    super.initState();
    _studentData = Map<String, dynamic>.from(widget.studentData);
  }

  Future<void> _updateStudentData(Map<String, dynamic> updatedData) async {
    setState(() => _isLoading = true);
    
    try {
      // For debugging - print subjects before update
      if (updatedData.containsKey('subjects')) {
        print('Updating subjects to: ${updatedData['subjects']}');
      }
      
      await _databaseService.updateStudentData(
        userId: widget.studentId,
        course: updatedData['course'],
        subjects: updatedData.containsKey('subjects') 
            ? List<String>.from(updatedData['subjects']) 
            : null,
      );
      
      setState(() {
        _studentData = {..._studentData, ...updatedData};
        _isLoading = false;
      });
      
      _showSnackBar('Student information updated successfully', isError: false);
    } catch (e) {
      print('Error updating student data: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Error updating student information: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.red[800] : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
        elevation: 4,
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
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Select Course',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: DropdownButtonFormField<String>(
              value: currentCourse.isNotEmpty ? currentCourse : null,
              decoration: InputDecoration(
                labelText: 'EARIST Courses',
                labelStyle: TextStyle(color: _primaryColor.withOpacity(0.8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: _primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: _primaryColor, width: 2),
                ),
                prefixIcon: Icon(Icons.school, color: _primaryColor),
                filled: true,
                fillColor: _accentColor,
              ),
              dropdownColor: Colors.white,
              items: _earistCourses.map((course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(
                    course,
                    style: TextStyle(color: _textColor),
                  ),
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
              child: Text(
                'CANCEL',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editSubjects() {
    // Ensure we're working with a List<String>
    List<String> currentSubjects = [];
    if (_studentData.containsKey('subjects') && _studentData['subjects'] != null) {
      // Convert each item to String to ensure type safety
      currentSubjects = (_studentData['subjects'] as List)
          .map((item) => item.toString())
          .toList();
    }
    
    // Create a new list for editing
    List<String> editedSubjects = List<String>.from(currentSubjects);
    final TextEditingController subjectController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                // Add padding to avoid the keyboard
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar at top
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Manage Subjects',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: subjectController,
                          decoration: InputDecoration(
                            labelText: 'Add Subject',
                            labelStyle: TextStyle(color: _primaryColor.withOpacity(0.8)),
                            hintText: 'Enter subject name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: _primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: _accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          elevation: 4,
                        ),
                        onPressed: () {
                          if (subjectController.text.isNotEmpty) {
                            setState(() {
                              editedSubjects.add(subjectController.text);
                              subjectController.clear();
                            });
                          }
                        },
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (editedSubjects.isNotEmpty) ...[
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: editedSubjects.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _secondaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.book, color: _primaryColor, size: 20),
                              ),
                              title: Text(
                                editedSubjects[index],
                                style: TextStyle(
                                  color: _textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () {
                                  setState(() => editedSubjects.removeAt(index));
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          Icon(Icons.book_outlined, color: Colors.grey[400], size: 50),
                          const SizedBox(height: 16),
                          Text(
                            'No subjects added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                      onPressed: () {
                        // Debug print before updating
                        print('Saving subjects: $editedSubjects');
                        
                        // Update with explicit List<String> type
                        _updateStudentData({'subjects': editedSubjects});
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot doc = await _databaseService.getStudentData(widget.studentId);
      if (doc.exists && doc.data() != null) {
        setState(() {
          _studentData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
        _showSnackBar('Data refreshed successfully', isError: false);
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('Student data not found', isError: true);
      }
    } catch (e) {
      print('Error refreshing data: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Error refreshing data: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 20),
                        _buildPersonalInfoSection(),
                        const SizedBox(height: 20),
                        _buildSubjectsSection(),
                        const SizedBox(height: 20),
                        _buildSystemInfoSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: _primaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Student Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -10,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshData,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_primaryColor, _primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                _getInitials(_studentData['name'] ?? '?'),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _studentData['name'] ?? 'Student Name',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _studentData['email'] ?? 'No email',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _secondaryColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _studentData['course'] ?? 'No course',
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, color: _primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildInfoTile('Age', '${_studentData['age'] ?? 'N/A'}', Icons.cake_outlined),
          _buildEditableInfoTile(
            'Course',
            _studentData['course'] ?? 'Not set',
            Icons.school_outlined,
            _editCourse,
          ),
          _buildInfoTile(
            'Year Level',
            'Year ${_studentData['year'] ?? 'N/A'}',
            Icons.calendar_today_outlined,
          ),
          _buildInfoTile(
            'Address',
            _studentData['address'] ?? 'Not provided',
            Icons.home_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsSection() {
    // Ensure we're working with a List
    List<dynamic> subjects = [];
    if (_studentData.containsKey('subjects') && _studentData['subjects'] != null) {
      subjects = _studentData['subjects'] as List;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.menu_book, color: _primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Enrolled Subjects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.edit_outlined, color: _primaryColor),
                  onPressed: _editSubjects,
                  tooltip: 'Edit Subjects',
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          if (subjects.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: subjects.map((subject) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _secondaryColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.book_outlined, size: 16, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        subject.toString(),
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(Icons.book_outlined, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'No subjects enrolled yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('ADD SUBJECTS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: _editSubjects,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.settings_outlined, color: _primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                'System Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildInfoTile('Student ID', widget.studentId, Icons.badge_outlined),
          _buildInfoTile(
            'Created',
            _formatTimestamp(_studentData['createdAt']),
            Icons.history,
          ),
          _buildInfoTile(
            'Last Updated',
            _formatTimestamp(_studentData['updatedAt']),
            Icons.update_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: _primaryColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoTile(String title, String value, IconData icon, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: _primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit_outlined, size: 16, color: _primaryColor),
            ),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return 'Not available';
  }
  
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    
    return '?';
  }
}