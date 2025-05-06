// screens/student/announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:student_app/utils/app_theme.dart';

class AnnouncementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcements')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildAnnouncementItem(
            'Exam Schedule Update',
            'The final exams for Mathematics and Physics have been rescheduled...',
            '2024-03-15'
          ),
          _buildAnnouncementItem(
            'Campus Maintenance',
            'There will be scheduled power outages next week...',
            '2024-03-14'
          ),
          _buildAnnouncementItem(
            'Scholarship Applications',
            'Deadline for scholarship applications extended to March 30th...',
            '2024-03-13'
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(String title, String content, String date) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(Icons.announcement, color: AppTheme.primaryColor),
        title: Text(title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(date, style: TextStyle(color: AppTheme.textSecondaryColor)),
        children: [
          Padding(
            padding: EdgeInsets.all(16).copyWith(top: 0),
            child: Text(content, style: AppTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}