// widgets/student_detail_card.dart
import 'package:flutter/material.dart';

class StudentDetailCard extends StatelessWidget {
  final String studentId;
  final String name;
  final String email;
  final String age;
  final String course;
  final String year;
  final bool isVerified;
  final Function(bool) onVerify;

  const StudentDetailCard({
    Key? key,
    required this.studentId,
    required this.name,
    required this.email,
    required this.age,
    required this.course,
    required this.year,
    required this.isVerified,
    required this.onVerify,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildVerificationBadge(),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.school, 'Course', course),
            _buildInfoRow(Icons.calendar_today, 'Year', year),
            _buildInfoRow(Icons.cake, 'Age', age),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => onVerify(!isVerified),
                  icon: Icon(
                    isVerified ? Icons.verified_user : Icons.person_outline,
                    size: 20,
                  ),
                  label: Text(isVerified ? 'Unverify' : 'Verify'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_user : Icons.pending_actions,
            size: 16,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isVerified ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}