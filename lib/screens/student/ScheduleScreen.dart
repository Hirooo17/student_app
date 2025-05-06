// screens/student/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_app/utils/app_theme.dart';

class Schedulescreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Class Schedule')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildScheduleItem('Mathematics', '09:00 AM', 'Room 301'),
          _buildScheduleItem('Physics', '11:00 AM', 'Room 205'),
          _buildScheduleItem('Computer Science', '02:00 PM', 'Lab 4'),
          _buildScheduleItem('English', '04:00 PM', 'Room 102'),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String subject, String time, String location) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.schedule, color: AppTheme.primaryColor),
        title: Text(subject, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time),
            SizedBox(height: 4),
            Text(location, style: TextStyle(color: AppTheme.textSecondaryColor)),
          ],
        ),
      ),
    );
  }
}