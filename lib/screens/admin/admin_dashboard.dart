// screens/admin/admin_dashboard.dart
// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/screens/admin/Homework%20Teacher/create_homework.dart';
import 'package:student_app/screens/admin/Homework%20Teacher/home_work_list_screen.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:student_app/screens/admin/student_details_screen.dart';
import 'package:student_app/screens/authentication/login_screen.dart';
import 'package:student_app/utils/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic>? adminData;

  // ignore: prefer_const_constructors_in_immutables
  AdminDashboard({this.adminData});
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  Stream<QuerySnapshot>? _studentsStream;
  bool _isSearching = false;
  bool _isLoading = false;
  String _filterBy = 'All';
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _studentsStream = _databaseService.getAllStudents();
    _getStudentCount();
  }

  void _getStudentCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('students').get();
    setState(() {
      _totalStudents = snapshot.size;
    });
  }

  void _performSearch(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        _isSearching = false;
        _studentsStream = _databaseService.getAllStudents();
      } else {
        _isSearching = true;
        _studentsStream = _databaseService.searchStudentsByName(searchTerm);
      }
    });
  }

  void _filterStudents(String filter) {
    setState(() {
      _filterBy = filter;
      if (filter == 'All') {
        _studentsStream = _databaseService.getAllStudents();
      } else {
        _studentsStream = _databaseService.filterStudentsByCourse(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: _performSearch,
              )
            : Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _studentsStream = _databaseService.getAllStudents();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin Header
          _buildAdminHeader(),

          // Filter Buttons
          _buildFilterButtons(),

          // Student List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _studentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textSecondaryColor.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          _isSearching
                              ? 'No students found matching your search'
                              : 'No students found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    return CustomWidgets.modernCard(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.primaryLightColor,
                          child: Text(
                            (data['name'] ?? 'S')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          data['name'] ?? 'Student',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                                '${data['course'] ?? 'N/A'} - Year ${data['year'] ?? 'N/A'}'),
                            SizedBox(height: 2),
                            Text(
                              data['email'] ?? 'No email',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.visibility,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailsScreen(
                                    studentId: doc.id,
                                    studentData: data,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
                .collection('teachers')
                .doc(user.uid)
                .get();

            if (adminSnapshot.exists) {
              Map<String, dynamic> adminData = {
                'uid': user.uid,
                ...adminSnapshot.data() as Map<String, dynamic>,
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeworkListScreen(
                    adminData: adminData,
                  ),
                ),
              );
            } else {
              // handle case where teacher document is missing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Admin data not found')),
              );
            }
          } catch (e) {
            print('Error fetching admin data: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to fetch admin data')),
            );
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: Icon(Icons.view_agenda),
        label: Text('See Homeworks'),
      ),
      
      

      
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Text(
                  widget.adminData?['name']?.toString().substring(0, 1) ?? 'A',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.adminData?['name'] ?? 'Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.adminData?['department'] ?? 'Administrator',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$_totalStudents Students',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All'),
          _buildFilterChip('BSIT'),
          _buildFilterChip('BSCS'),
          _buildFilterChip('BSCE'),
          _buildFilterChip('BEED'),
          _buildFilterChip('BSA'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterBy == label;

    return Container(
      margin: EdgeInsets.only(right: 10, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          _filterStudents(label);
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryLightColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out from the admin panel?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CustomWidgets.loadingButton(
            isLoading: _isLoading,
            text: 'Logout',
            width: 100,
            color: AppTheme.accentColor,
            onPressed: () async {
              setState(() => _isLoading = true);
              Navigator.pop(context);
              await _signOut();
              setState(() => _isLoading = false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
