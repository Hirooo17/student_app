// widgets/stats_summary_widget.dart
import 'package:flutter/material.dart';

class StatsSummaryWidget extends StatelessWidget {
  final int totalTeachers;
  final int verifiedTeachers;
  final int totalStudents;
  final int verifiedStudents;

  const StatsSummaryWidget({
    Key? key,
    required this.totalTeachers,
    required this.verifiedTeachers,
    required this.totalStudents,
    required this.verifiedStudents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                context: context,
                title: 'Teachers',
                total: totalTeachers,
                verified: verifiedTeachers,
                color: Colors.blue,
              ),
              _buildStatCard(
                context: context,
                title: 'Students',
                total: totalStudents,
                verified: verifiedStudents,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required int total,
    required int verified,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (verified / total * 100).toStringAsFixed(1) : '0.0';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(title == 'Teachers' ? Icons.school : Icons.person, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildProgressBar(verified, total, color),
            SizedBox(height: 8),
            Text(
              'Verified: $verified out of $total ($percentage%)',
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: 4),
            Text(
              'Pending: ${total - verified}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int verified, int total, Color color) {
    double percentage = total > 0 ? verified / total : 0;
    
    return Container(
      height: 10,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: FractionallySizedBox(
        widthFactor: percentage,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}