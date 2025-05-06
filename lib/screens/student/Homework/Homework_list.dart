// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_app/screens/student/Homework/Homework_details_student.dart';
import 'package:student_app/services/Homework/home_work_service.dart';
import 'package:student_app/utils/app_theme.dart';

class StudentHomeworkListScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  StudentHomeworkListScreen({required this.studentData});

  @override
  _StudentHomeworkListScreenState createState() =>
      _StudentHomeworkListScreenState();
}

class _StudentHomeworkListScreenState extends State<StudentHomeworkListScreen> with SingleTickerProviderStateMixin {
  final HomeworkService _homeworkService = HomeworkService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text('My Homework'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Assignments'),
            Tab(text: 'My Submissions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeworkList(),
          _buildSubmissionsList(),
        ],
      ),
    );
  }

  Widget _buildHomeworkList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _homeworkService.getHomeworkByCourse(widget.studentData['course']),
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
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppTheme.textSecondaryColor.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  'No homework for ${widget.studentData['course']}',
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
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            DateTime dueDate = (data['dueDate'] as Timestamp).toDate();
            bool isOverdue = dueDate.isBefore(DateTime.now());

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeworkStudentDetailsScreen(
                        homeworkId: doc.id,
                        homeworkData: data,
                        studentData: widget.studentData,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['title'] ?? 'Untitled Assignment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              data['subject'] ?? 'General',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        data['description'] ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: isOverdue
                                ? Colors.red
                                : AppTheme.textSecondaryColor,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Due: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isOverdue
                                  ? Colors.red
                                  : AppTheme.textSecondaryColor,
                              fontWeight: isOverdue
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Spacer(),
                          FutureBuilder<bool>(
                            future: widget.studentData['uid'] != null
                                ? _homeworkService.hasSubmitted(
                                    homeworkId: doc.id,
                                    studentId: widget.studentData['uid'],
                                  )
                                : Future.value(false),
                            builder: (context, submissionSnapshot) {
                              if (submissionSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                              if (submissionSnapshot.data == true) {
                                return Chip(
                                  backgroundColor: Colors.green.withOpacity(0.1),
                                  label: Text(
                                    'Submitted',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                  avatar: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                );
                              }
                              return Chip(
                                backgroundColor: isOverdue 
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                label: Text(
                                  isOverdue ? 'Overdue' : 'Pending',
                                  style: TextStyle(
                                    color: isOverdue ? Colors.red : Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                                avatar: Icon(
                                  isOverdue ? Icons.warning : Icons.pending,
                                  color: isOverdue ? Colors.red : Colors.orange,
                                  size: 16,
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubmissionsList() {
    return widget.studentData['uid'] != null
        ? StreamBuilder<QuerySnapshot>(
            stream: _homeworkService.getStudentSubmissions(widget.studentData['uid']),
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
                        Icons.assignment_turned_in_outlined,
                        size: 64,
                        color: AppTheme.textSecondaryColor.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No submitted homework yet',
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
                padding: EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot submissionDoc = snapshot.data!.docs[index];
                  Map<String, dynamic> submissionData = submissionDoc.data() as Map<String, dynamic>;
                  
                  return FutureBuilder<DocumentSnapshot>(
                    future: _homeworkService.getHomeworkById(submissionData['homeworkId']),
                    builder: (context, homeworkSnapshot) {
                      if (!homeworkSnapshot.hasData) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            title: Text('Loading...'),
                            subtitle: Text('Submission date: ${DateFormat('MMM d, yyyy').format((submissionData['submittedAt'] as Timestamp).toDate())}'),
                          ),
                        );
                      }

                      Map<String, dynamic>? homeworkData = 
                          homeworkSnapshot.data?.data() as Map<String, dynamic>?;
                      
                      if (homeworkData == null) {
                        return SizedBox.shrink(); // Homework was deleted
                      }

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeworkStudentDetailsScreen(
                                  homeworkId: submissionData['homeworkId'],
                                  homeworkData: homeworkData,
                                  studentData: widget.studentData,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        homeworkData['title'] ?? 'Untitled Assignment',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'Submitted',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                if (submissionData['comment'] != null && submissionData['comment'].isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your comment:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          submissionData['comment'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textPrimaryColor,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Due: ${DateFormat('MMM d, yyyy').format((homeworkData['dueDate'] as Timestamp).toDate())}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Submitted: ${DateFormat('MMM d').format((submissionData['submittedAt'] as Timestamp).toDate())}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          )
        : Center(
            child: Text('User ID not available'),
          );
  }
}