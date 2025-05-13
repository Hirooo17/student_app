// screens/teacher/grade_viewer_screen.dart
import 'package:flutter/material.dart';
import 'package:student_app/models/Grade.model.dart';
import 'package:student_app/services/Grades/grade_service.dart';
import 'package:student_app/services/database_service.dart';
import 'package:student_app/utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GradeViewerScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const GradeViewerScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  _GradeViewerScreenState createState() => _GradeViewerScreenState();
}

class _GradeViewerScreenState extends State<GradeViewerScreen> with SingleTickerProviderStateMixin {
  final GradeService _gradeService = GradeService();
  final DatabaseService _databaseService = DatabaseService();
  TabController? _tabController;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  String _filterSubject = 'All Subjects';
  List<String> _subjects = ['All Subjects'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoading = true);
    try {
      final studentDoc = await _databaseService.getStudentData(widget.studentId);
      setState(() {
        _studentData = studentDoc.data() as Map<String, dynamic>;
        if (_studentData != null && _studentData!.containsKey('subjects')) {
          _subjects = ['All Subjects', ...(List<String>.from(_studentData!['subjects'] ?? []))];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading student data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text('${widget.studentName}\'s Grades'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'All Grades'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Analytics'),
            Tab(icon: Icon(Icons.timeline), text: 'Progress'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Student Info Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 24,
                        child: Text(
                          widget.studentName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.studentName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _studentData?['course'] ?? 'Student',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder<List<Grade>>(
                        stream: _gradeService.getGrades(widget.studentId),
                        builder: (context, snapshot) {
                          final gradeCount = snapshot.data?.length ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.grade,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$gradeCount Grade${gradeCount == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Filter Dropdown
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterSubject,
                        isExpanded: true,
                        icon: const Icon(Icons.filter_list),
                        style: TextStyle(color: AppTheme.textPrimaryColor, fontSize: 16),
                        onChanged: (String? newValue) {
                          setState(() {
                            _filterSubject = newValue!;
                          });
                        },
                        items: _subjects
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'All Subjects' ? Icons.apps : Icons.book,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All Grades Tab
                      _buildGradesList(),
                      
                      // Analytics Tab
                      _buildAnalytics(),
                      
                      // Progress Tab
                      _buildProgress(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGradesList() {
    return StreamBuilder<List<Grade>>(
      stream: _gradeService.getGrades(widget.studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }
        
        final grades = snapshot.data ?? [];
        
        if (grades.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No grades available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        // Filter grades by subject if needed
        final filteredGrades = _filterSubject == 'All Subjects'
            ? grades
            : grades.where((grade) => grade.subject == _filterSubject).toList();
        
        if (filteredGrades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No grades for $_filterSubject',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredGrades.length,
          itemBuilder: (context, index) {
            final grade = filteredGrades[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getGradeColor(grade.grade),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          grade.grade.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            grade.subject,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getGradeIcon(grade.grade),
                                size: 16,
                                color: _getGradeColor(grade.grade),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getGradeDescription(grade.grade),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Grade: ${_gradeToLetter(grade.grade)}',
                            style: TextStyle(
                              color: _getGradeColor(grade.grade),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                                                  Text(
                          DateFormat('MMM d, yyyy').format(grade.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('h:mm a').format(grade.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
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

  Widget _buildAnalytics() {
    return StreamBuilder<List<Grade>>(
      stream: _gradeService.getGrades(widget.studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final grades = snapshot.data ?? [];
        
        if (grades.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No grades available for analysis',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        // Filter grades by subject if needed
        final filteredGrades = _filterSubject == 'All Subjects'
            ? grades
            : grades.where((grade) => grade.subject == _filterSubject).toList();
        
        if (filteredGrades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No grades for $_filterSubject',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        // Calculate analytics
        final double averageGrade = filteredGrades.fold(0.0, (sum, grade) => sum + grade.grade) / filteredGrades.length;
        final double highestGrade = filteredGrades.map((g) => g.grade).reduce((a, b) => a > b ? a : b);
        final double lowestGrade = filteredGrades.map((g) => g.grade).reduce((a, b) => a < b ? a : b);
        
        // Group by subject for the chart
        final Map<String, List<Grade>> gradesBySubject = {};
        for (var grade in grades) {
          if (!gradesBySubject.containsKey(grade.subject)) {
            gradesBySubject[grade.subject] = [];
          }
          gradesBySubject[grade.subject]!.add(grade);
        }
        
        // Calculate average by subject
        final Map<String, double> averageBySubject = {};
        gradesBySubject.forEach((subject, grades) {
          double sum = grades.fold(0.0, (sum, grade) => sum + grade.grade);
          averageBySubject[subject] = sum / grades.length;
        });
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  _buildAnalyticsCard(
                    'Average',
                    averageGrade.toStringAsFixed(1),
                    _getGradeColor(averageGrade),
                    Icons.analytics,
                  ),
                  const SizedBox(width: 12),
                  _buildAnalyticsCard(
                    'Highest',
                    highestGrade.toStringAsFixed(1),
                    _getGradeColor(highestGrade),
                    Icons.arrow_upward,
                  ),
                  const SizedBox(width: 12),
                  _buildAnalyticsCard(
                    'Lowest',
                    lowestGrade.toStringAsFixed(1),
                    _getGradeColor(lowestGrade),
                    Icons.arrow_downward,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Subject Chart
              if (gradesBySubject.length > 1) ...[
                const Text(
                  'Performance by Subject',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String subject = averageBySubject.keys.elementAt(groupIndex);
                            return BarTooltipItem(
                              '$subject\n${rod.toY.toStringAsFixed(1)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value < averageBySubject.length) {
                                String subject = averageBySubject.keys.elementAt(value.toInt());
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Transform.rotate(
                                    angle: 0.6,
                                    child: SizedBox(
                                      width: 40,
                                      child: Text(
                                        subject.length > 5 ? subject.substring(0, 5) + '...' : subject,
                                        style: TextStyle(
                                          color: AppTheme.textPrimaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 20,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: List.generate(
                        averageBySubject.length,
                        (index) {
                          final subject = averageBySubject.keys.elementAt(index);
                          final value = averageBySubject[subject]!;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: value,
                                color: _getGradeColor(value),
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Grade Distribution
              const Text(
                'Grade Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildGradeDistribution(filteredGrades),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGradeLegend('A', Colors.green),
                        _buildGradeLegend('B', Colors.blue),
                        _buildGradeLegend('C', Colors.amber),
                        _buildGradeLegend('D', Colors.orange),
                        _buildGradeLegend('F', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgress() {
    return StreamBuilder<List<Grade>>(
      stream: _gradeService.getGrades(widget.studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final grades = snapshot.data ?? [];
        
        if (grades.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No grades available to track progress',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        // Filter grades by subject if needed
        final filteredGrades = _filterSubject == 'All Subjects'
            ? grades
            : grades.where((grade) => grade.subject == _filterSubject).toList();
        
        if (filteredGrades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No grades for $_filterSubject',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        // Group grades by subject and sort by date
        Map<String, List<Grade>> gradesBySubject = {};
        
        for (var grade in filteredGrades) {
          if (!gradesBySubject.containsKey(grade.subject)) {
            gradesBySubject[grade.subject] = [];
          }
          gradesBySubject[grade.subject]!.add(grade);
        }
        
        // Sort grades by date within each subject
        gradesBySubject.forEach((subject, grades) {
          grades.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        });
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_filterSubject == 'All Subjects') ...[
                // Show progress chart for each subject
                ...gradesBySubject.entries.map((entry) {
                  final subject = entry.key;
                  final subjectGrades = entry.value;
                  
                  if (subjectGrades.length < 2) {
                    return Container(); // Skip subjects with only one grade
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _buildLineChart(subjectGrades),
                      ),
                    ],
                  );
                }).toList(),
              ] else ...[
                // Show single chart for selected subject
                Container(
                  height: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _buildLineChart(filteredGrades),
                ),
                const SizedBox(height: 24),
                _buildProgressSummary(filteredGrades),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineChart(List<Grade> grades) {
    // Sort grades by date if not already sorted
    grades.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < grades.length) {
                  final date = grades[value.toInt()].createdAt;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: grades.length - 1.0,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(grades.length, (index) {
              return FlSpot(index.toDouble(), grades[index].grade);
            }),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.primaryLightColor,
              ],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryLightColor.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                if (flSpot.x >= 0 && flSpot.x < grades.length) {
                  final grade = grades[flSpot.x.toInt()];
                  return LineTooltipItem(
                    '${grade.grade.toStringAsFixed(1)}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('MMM d, yyyy').format(grade.createdAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSummary(List<Grade> grades) {
    if (grades.length < 2) {
      return Container();
    }
    
    final firstGrade = grades.first.grade;
    final lastGrade = grades.last.grade;
    final improvement = lastGrade - firstGrade;
    final isImproved = improvement > 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Progress Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                'First Grade',
                firstGrade.toStringAsFixed(1),
                _gradeToLetter(firstGrade),
              ),
              Container(
                height: 60,
                width: 1,
                color: Colors.grey.shade300,
              ),
              _buildSummaryItem(
                'Latest Grade',
                lastGrade.toStringAsFixed(1),
                _gradeToLetter(lastGrade),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isImproved ? Icons.trending_up : Icons.trending_down,
                color: isImproved ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '${isImproved ? '+' : ''}${improvement.toStringAsFixed(1)} points',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isImproved ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isImproved
                ? 'Great progress! Keep it up!'
                : 'Needs improvement. Don\'t give up!',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeDistribution(List<Grade> grades) {
    // Count grades by letter grade
    int countA = 0, countB = 0, countC = 0, countD = 0, countF = 0;
    
    for (var grade in grades) {
      String letterGrade = _gradeToLetter(grade.grade);
      switch (letterGrade) {
        case 'A':
          countA++;
          break;
        case 'B':
          countB++;
          break;
        case 'C':
          countC++;
          break;
        case 'D':
          countD++;
          break;
        case 'F':
          countF++;
          break;
      }
    }
    
    return Row(
      children: [
        _buildGradeBar('A', countA, grades.length, Colors.green),
        _buildGradeBar('B', countB, grades.length, Colors.blue),
        _buildGradeBar('C', countC, grades.length, Colors.amber),
        _buildGradeBar('D', countD, grades.length, Colors.orange),
        _buildGradeBar('F', countF, grades.length, Colors.red),
      ],
    );
  }

  Widget _buildGradeBar(String grade, int count, int total, Color color) {
    double percentage = total > 0 ? count / total : 0;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 100,
            width: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 100 * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeLegend(String grade, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          grade,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String value, String letter) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getGradeColor(double.parse(value)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
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
  
  IconData _getGradeIcon(double grade) {
    if (grade >= 90) return Icons.star;
    if (grade >= 80) return Icons.thumb_up;
    if (grade >= 70) return Icons.check_circle;
    if (grade >= 60) return Icons.warning;
    return Icons.error;
  }
  
  String _getGradeDescription(double grade) {
    if (grade >= 90) return 'Excellent';
    if (grade >= 80) return 'Good';
    if (grade >= 70) return 'Satisfactory';
    if (grade >= 60) return 'Needs Improvement';
    return 'Failing';
  }
}

