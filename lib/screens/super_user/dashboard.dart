// screens/super_user_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/controllers/super_user_controller.dart';
import 'package:student_app/models/super_user_model.dart';
import 'package:student_app/widgets/stat_summary_widget.dart';

class SuperUserDashboard extends StatefulWidget {
  final SuperUser superUser;
  final SuperUserController controller;

  const SuperUserDashboard({
    Key? key,
    required this.superUser,
    required this.controller,
  }) : super(key: key);

  @override
  _SuperUserDashboardState createState() => _SuperUserDashboardState();
}

class _SuperUserDashboardState extends State<SuperUserDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedCourse = 'All';

  // Stats
  int _totalTeachers = 0;
  int _verifiedTeachers = 0;
  int _totalStudents = 0;
  int _verifiedStudents = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  void _loadStats() {
    // Load teacher stats
    widget.controller.getAllTeachers().listen((snapshot) {
      if (mounted) {
        setState(() {
          _totalTeachers = snapshot.docs.length;
          _verifiedTeachers = snapshot.docs
              .where((doc) =>
                  doc.data() is Map<String, dynamic> &&
                  (doc.data() as Map<String, dynamic>)['isVerified'] == true)
              .length;
        });
      }
    });

    // Load student stats
    widget.controller.getAllStudents().listen((snapshot) {
      if (mounted) {
        setState(() {
          _totalStudents = snapshot.docs.length;
          _verifiedStudents = snapshot.docs
              .where((doc) =>
                  doc.data() is Map<String, dynamic> &&
                  (doc.data() as Map<String, dynamic>)['isVerified'] == true)
              .length;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, size: 24),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super User Dashboard',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  widget.superUser.name,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              setState(() {
                _loadStats();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refreshing data...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await widget.controller.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.school),
              text: 'Teachers',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Students',
            ),
          ],
          indicatorWeight: 3,
        ),
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeachersTab(),
                _buildStudentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StatsSummaryWidget(
        totalTeachers: _totalTeachers,
        verifiedTeachers: _verifiedTeachers,
        totalStudents: _totalStudents,
        verifiedStudents: _verifiedStudents,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 8),
          _tabController.index == 0
              ? _buildDepartmentDropdown()
              : _buildCourseDropdown(),
        ],
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedDepartment,
          items: [
            'All',
            'College of Computer Studies',
            'College of Engineering',
            'College of Education',
            'College of Business Administration',
            'College of Arts and Sciences'
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedDepartment = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCourse,
          items: ['All', 'BSIT', 'BSCS', 'BSCE', 'BEED', 'BSA']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCourse = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTeachersTab() {
    Stream<QuerySnapshot> teachersStream;
 if (_searchQuery.isNotEmpty) {
      teachersStream = widget.controller.searchTeachersByName(_searchQuery);
    } else if (_selectedDepartment != 'All') {
      teachersStream = widget.controller.filterTeachersByDepartment(_selectedDepartment);
    } else {
      teachersStream = widget.controller.getAllTeachers();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: teachersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No teachers found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isVerified = data['isVerified'] ?? false;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isVerified
                      ? Colors.green.shade300
                      : Colors.orange.shade300,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'No Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Email: ${data['email'] ?? 'No Email'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              isVerified ? 'Verified' : 'Pending',
                              style: TextStyle(
                                color:
                                    isVerified ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: isVerified,
                              activeColor: Colors.green,
                              onChanged: (value) async {
                                await widget.controller
                                    .updateTeacherVerification(
                                  teacherId: doc.id,
                                  isVerified: value,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Department: ${data['department'] ?? 'Not specified'}'),
                              Text(
                                  'Age: ${data['age']?.toString() ?? 'Not specified'}'),
                              Text(
                                  'Address: ${data['address'] ?? 'Not specified'}'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit Teacher',
                          onPressed: () => _showEditTeacherDialog(doc.id, data),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentsTab() {
    Stream<QuerySnapshot> studentsStream;

    if (_searchQuery.isNotEmpty) {
      studentsStream = widget.controller.searchStudentsByName(_searchQuery);
    } else if (_selectedCourse != 'All') {
      studentsStream =
          widget.controller.filterStudentsByCourse(_selectedCourse);
    } else {
      studentsStream = widget.controller.getAllStudents();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: studentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No students found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isVerified = data['isVerified'] ?? false;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isVerified
                      ? Colors.green.shade300
                      : Colors.orange.shade300,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'No Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Email: ${data['email'] ?? 'No Email'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              isVerified ? 'Verified' : 'Pending',
                              style: TextStyle(
                                color:
                                    isVerified ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: isVerified,
                              activeColor: Colors.green,
                              onChanged: (value) async {
                                await widget.controller
                                    .updateStudentVerification(
                                  studentId: doc.id,
                                  isVerified: value,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Course: ${data['course'] ?? 'Not specified'}'),
                              Text(
                                  'Year: ${data['year']?.toString() ?? 'Not specified'}'),
                              Text(
                                  'Age: ${data['age']?.toString() ?? 'Not specified'}'),
                              Text(
                                  'Address: ${data['address'] ?? 'Not specified'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTeacherDialog(
      String teacherId, Map<String, dynamic> teacherData) {
    final nameController = TextEditingController(text: teacherData['name']);
    final ageController =
        TextEditingController(text: teacherData['age']?.toString() ?? '');
    final addressController =
        TextEditingController(text: teacherData['address']);

    String selectedDepartment =
        teacherData['department'] ?? 'College of Computer Studies';
    List<String> departments = [
      'All',
      'College of Computer Studies',
      'College of Engineering',
      'College of Education',
      'College of Business Administration',
      'College of Arts and Sciences'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Edit Teacher Profile'),
          ],
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teacher ID: $teacherId',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 12),
                  Text('Department:', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedDepartment,
                        items: departments.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedDepartment = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.save),
            label: Text('SAVE CHANGES'),
            onPressed: () async {
              int? age;
              if (ageController.text.isNotEmpty) {
                age = int.tryParse(ageController.text);
              }

              await widget.controller.updateTeacherDetails(
                teacherId: teacherId,
                name: nameController.text,
                age: age,
                address: addressController.text,
                department: selectedDepartment,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Teacher details updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
