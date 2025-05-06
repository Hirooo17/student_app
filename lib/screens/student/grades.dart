// screens/student/grades_screen.dart
import 'package:flutter/material.dart';
import 'package:student_app/utils/app_theme.dart';

class GradesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grades')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildGradeItem('Mathematics', 'A', 95),
          _buildGradeItem('Physics', 'B+', 87),
          _buildGradeItem('Computer Science', 'A-', 90),
          _buildGradeItem('English', 'B', 82),
        ],
      ),
    );
  }

  Widget _buildGradeItem(String subject, String grade, int score) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryLightColor,
          child: Text(grade, style: TextStyle(color: Colors.white)),
        ),
        title: Text(subject, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        trailing: Text('$score%', style: TextStyle(
          color: _getGradeColor(score),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        )),
      ),
    );
  }

  Color _getGradeColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    return Colors.red;
  }
}