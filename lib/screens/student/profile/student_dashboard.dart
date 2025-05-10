import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:student_app/screens/student/AnnouncementScreen.dart';
import 'package:student_app/screens/student/ScheduleScreen.dart';
import 'package:student_app/screens/student/Homework/Homework_list.dart';
import 'package:student_app/screens/student/grades.dart';
import 'package:student_app/services/auth_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:student_app/services/Grades/grade_service.dart';
import 'package:student_app/screens/student/profile/edit_profile_screen.dart';
import 'package:student_app/screens/authentication/login_screen.dart';
import 'package:student_app/utils/app_theme.dart';
import 'package:student_app/models/Grade.model.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData;
  
  const StudentDashboard({required this.studentData, Key? key}) : super(key: key);
  
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final GradeService _gradeService = GradeService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildSchoolHeader(),
                const SizedBox(height: 24),
                _buildProfileHeader(widget.studentData),
                const SizedBox(height: 16),
                _buildGradeOverview(),
                const SizedBox(height: 16),
                _buildNavigationButtons(),
                const SizedBox(height: 16),
                _buildSubjectsList(widget.studentData),
                const SizedBox(height: 16),
                _buildPersonalInfo(widget.studentData),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fadeAnimation,
        child: FloatingActionButton(
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => _navigateToEditProfile(),
          elevation: 4,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Student Dashboard', style: AppTheme.headingMedium.copyWith(color: Colors.white)),
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      centerTitle: true,
      actions: [
        IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController,
            color: Colors.white,
          ),
          onPressed: _confirmSignOut,
        ),
      ],
    );
  }

  Widget _buildSchoolHeader() {
    return CustomWidgets.modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                'EARIST',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Center(
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            studentData['name'] ?? 'Student',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 8),
          Text(
            studentData['email'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Text(
              '${studentData['course'] ?? 'N/A'} - Year ${studentData['year'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildGradeOverview() {
  return StreamBuilder<List<Grade>>(
    stream: _gradeService.getGrades(widget.studentData['uid']),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildShimmerGradeCard();
      }

      if (snapshot.hasError) {
        return CustomWidgets.modernCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading grades', style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ),
        );
      }

      final grades = snapshot.data ?? [];
      if (grades.isEmpty) {
        return CustomWidgets.modernCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.grade, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No grades available yet', style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ),
        );
      }

      return CustomWidgets.modernCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text('Grade Overview', style: AppTheme.headingSmall),
                  const Spacer(),
                  TextButton(
                    child: Text('View All', style: TextStyle(color: AppTheme.primaryColor)),
                    onPressed: () => _navigateTo(GradeViewerScreen(
                      studentId: widget.studentData['uid'],
                      studentName: widget.studentData['name'],
                    )),
                  ),
                ],
              ),
              const Divider(height: 24),
              SizedBox(
                height: 260,
                child: BarChart(
                  BarChartData(
                    barGroups: grades.asMap().entries.map((entry) {
                      final index = entry.key;
                      final grade = entry.value;
                      final color = _getBarColor(grade.grade);
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: grade.grade,
                            width: 18,
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 100,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < grades.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  grades[index].subject,
                                  style: const TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          getTitlesWidget: (value, _) => Text('${value.toInt()}'),
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                    maxY: 100,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...grades.where((g) => g.grade < 75).map((g) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ Please improve in ${g.subject}',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
    },
  );
}

Color _getBarColor(double grade) {
  if (grade >= 90) return Colors.green;
  if (grade >= 80) return Colors.blue;
  if (grade >= 70) return Colors.amber;
  if (grade >= 60) return Colors.orange;
  return Colors.red;
}


  Widget _buildGradeDistributionPieChart(List<Grade> grades) {
    final gradeCounts = {
      'A': grades.where((g) => g.grade >= 90).length,
      'B': grades.where((g) => g.grade >= 80).length,
      'C': grades.where((g) => g.grade >= 70).length,
      'D': grades.where((g) => g.grade >= 60).length,
      'F': grades.where((g) => g.grade < 60).length,
    };

    return SizedBox(
      height: 150,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: gradeCounts.entries.map((e) => PieChartSectionData(
            color: _getGradeColorByLetter(e.key),
            value: e.value.toDouble(),
            title: '${e.value} ${e.key}',
            radius: 20,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
          )).toList(),
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (event is FlTapUpEvent && pieTouchResponse?.touchedSection != null) {
                  // Handle tap on pie chart section
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGradeCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CustomWidgets.modernCard(
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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
              const SizedBox(width: 8),
              Text('Personal Information', style: AppTheme.headingSmall),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow('Age', '${studentData['age'] ?? 'N/A'}'),
          _buildInfoRow('Course', studentData['course'] ?? 'N/A'),
          _buildInfoRow('Year Level', '${studentData['year'] ?? 'N/A'}'),
          _buildInfoRow('Address', studentData['address'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildSubjectsList(Map<String, dynamic> studentData) {
    return CustomWidgets.modernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text('Enrolled Subjects', style: AppTheme.headingSmall),
            ],
          ),
          const Divider(height: 24),
          if (studentData['subjects'] != null && (studentData['subjects'] as List).isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: (studentData['subjects'] as List).length,
              itemBuilder: (context, index) {
                final subject = (studentData['subjects'] as List)[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryLightColor.withOpacity(0.1),
                        AppTheme.primaryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryLightColor.withOpacity(0.3)),
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

  Widget _buildNavigationButtons() {
    return CustomWidgets.modernCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Quick Access', style: AppTheme.headingSmall),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            children: [
              _buildNavigationButton(
                icon: Icons.schedule,
                label: 'Schedule',
                onTap: () => _navigateTo(Schedulescreen()),
              ),
              _buildNavigationButton(
                icon: Icons.grade,
                label: 'Grades',
                onTap: () => _navigateTo(GradeViewerScreen(
                  studentId: widget.studentData['uid'],
                  studentName: widget.studentData['name'],
                )),
              ),
              _buildNavigationButton(
                icon: Icons.announcement,
                label: 'Announcements',
                onTap: () => _navigateTo(AnnouncementsScreen()),
              ),
              _buildNavigationButton(
                icon: Icons.assignment,
                label: 'To-Do',
                onTap: () => _navigateTo(StudentHomeworkListScreen(studentData: widget.studentData)),
              ),
              _buildNavigationButton(
                icon: Icons.book,
                label: 'Subjects',
                onTap: () => _scrollToSubjects(),
              ),
              _buildNavigationButton(
                icon: Icons.person,
                label: 'Profile',
                onTap: () => _navigateTo(EditProfileScreen(studentId: widget.studentData['uid'])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryLightColor.withOpacity(0.2),
                AppTheme.primaryColor.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(label, style: AppTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToSubjects() {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToProfile() {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(studentId: widget.studentData['uid']),
      ),
    ).then((_) => setState(() {}));
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout', style: AppTheme.headingSmall),
        content: Text('Are you sure you want to logout?', style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondaryColor)),
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

  String _gradeToLetter(double grade) {
    if (grade >= 90) return 'A';
    if (grade >= 80) return 'B';
    if (grade >= 70) return 'C';
    if (grade >= 60) return 'D';
    return 'F';
  }

  Color _getGradeColorByLetter(String letter) {
    switch (letter) {
      case 'A': return Colors.green;
      case 'B': return Colors.lightGreen;
      case 'C': return Colors.orange;
      case 'D': return Colors.orangeAccent;
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }
}