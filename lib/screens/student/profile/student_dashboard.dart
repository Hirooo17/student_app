// screens/student/student_dashboard.dart
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_app/screens/student/AnnouncementScreen.dart';
import 'package:student_app/screens/student/ScheduleScreen.dart';
import 'package:student_app/screens/student/Homework/Homework_list.dart';
import 'package:student_app/screens/student/grades.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:student_app/screens/student/profile/edit_profile_screen.dart';
import 'package:student_app/screens/authentication/login_screen.dart';
import 'package:student_app/utils/app_theme.dart';

class StudentDashboard extends StatefulWidget {
   final Map<String, dynamic> studentData;

  
   StudentDashboard({required this.studentData});

  
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
  padding: EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSchoolHeader(),
      SizedBox(height: 24),
      _buildProfileHeader(widget.studentData),
      SizedBox(height: 24),
      _buildPersonalInfo(widget.studentData),
      _buildNavigationButtons(),
      SizedBox(height: 20),
      _buildSubjectsList(widget.studentData),
    ],
  ),
),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(studentId: widget.studentData['uid']),
            ),
          ).then((_) {
            // Refresh the page when returning from edit profile
            setState(() {});
          });
        },
        tooltip: 'Edit Profile',
      ),
    );
  }
  
  Widget _buildSchoolHeader() {
    return CustomWidgets.modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                'EARIST',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Eulogio "Amang" Rodriguez Institute of Science and Technology',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> studentData) {
    return CustomWidgets.modernCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryLightColor,
            child: Icon(Icons.person, size: 70, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            studentData['name'] ?? 'Student',
            style: AppTheme.headingMedium,
          ),
          SizedBox(height: 8),
          Text(
            studentData['email'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${studentData['course'] ?? 'N/A'} - Year ${studentData['year'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalInfo(Map<String, dynamic> studentData) {
    return CustomWidgets.modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Personal Information',
                style: AppTheme.headingSmall,
              ),
            ],
          ),
          Divider(height: 24),
          _buildInfoRow('Age', '${studentData['age'] ?? 'N/A'}'),
          _buildInfoRow('Course', studentData['course'] ?? 'N/A'),
          _buildInfoRow('Year Level', '${studentData['year'] ?? 'N/A'}'),
          _buildInfoRow('Address', studentData['address'] ?? 'N/A'),
        ],
      ),
    );
  }
  
  Widget _buildSubjectsList(Map<String, dynamic> studentData) {
    return CustomWidgets.modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Enrolled Subjects',
                style: AppTheme.headingSmall,
              ),
            ],
          ),
          Divider(height: 24),
          if (studentData['subjects'] != null &&
              (studentData['subjects'] as List).isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: (studentData['subjects'] as List).length,
              itemBuilder: (context, index) {
                final subject = (studentData['subjects'] as List)[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryLightColor.withOpacity(0.5)),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        subject.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No subjects enrolled',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
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



  // Add this widget in the _StudentDashboardState class
Widget _buildNavigationButtons() {
  return CustomWidgets.modernCard(
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Quick Access', style: AppTheme.headingSmall),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          children: [
            _buildNavigationButton(
              icon: Icons.schedule,
              label: 'Schedule',
              onTap: () => _navigateTo(Schedulescreen()),
            ),
            _buildNavigationButton(
              icon: Icons.grade,
              label: 'Grades',
              onTap: () => _navigateTo(GradesScreen()),
            ),
            _buildNavigationButton(
              icon: Icons.announcement,
              label: 'Announcements',
              onTap: () => _navigateTo(AnnouncementsScreen()),
            ),
               _buildNavigationButton(
              icon: Icons.assignment,
              label: 'To-Do',
              onTap: () => _navigateTo(StudentHomeworkListScreen( studentData: widget.studentData,)),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildNavigationButton({required IconData icon, required String label, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryLightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: AppTheme.primaryColor),
          SizedBox(height: 8),
          Text(label, style: AppTheme.bodyMedium),
        ],
      ),
    ),
  );
}

void _navigateTo(Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}
}
