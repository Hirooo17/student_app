// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_app/screens/teacher/Homework%20Teacher/create_homework.dart';
import 'package:student_app/screens/teacher/Homework%20Teacher/homework_details.dart';
import 'package:student_app/services/Homework/home_work_service.dart';

import 'package:student_app/utils/app_theme.dart';


class HomeworkListScreen extends StatefulWidget {
  final Map<String, dynamic>? adminData;
  
  HomeworkListScreen({this.adminData});
  
  @override
  _HomeworkListScreenState createState() => _HomeworkListScreenState();
}

class _HomeworkListScreenState extends State<HomeworkListScreen> {
  final HomeworkService _homeworkService = HomeworkService();
  String _filterBy = 'All';
  
  List<String> _courses = ['All', 'BSIT', 'BSCS', 'BSCE', 'BEED', 'BSA'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text('Homework Management'),
      ),
      body: Column(
        children: [
          // Filter buttons
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _courses.map((course) => _buildFilterChip(course)).toList(),
            ),
          ),
          
          // Homework list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filterBy == 'All'
                  ? _homeworkService.getAllHomework()
                  : _homeworkService.getHomeworkByCourse(_filterBy),
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
                          _filterBy == 'All'
                              ? 'No homework assignments found'
                              : 'No homework assignments for $_filterBy',
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
                              builder: (context) => HomeworkDetailsScreen(
                                homeworkId: doc.id,
                                homeworkData: data,
                                adminData: widget.adminData,
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
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      data['course'] ?? 'Unknown',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                data['subject'] ?? 'No Subject',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                data['description'] ?? 'No description provided',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
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
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _confirmDeleteHomework(doc.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
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
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateHomeworkScreen(adminData: widget.adminData),
            ),
          );
        },
        tooltip: 'Create New Homework',
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
          setState(() {
            _filterBy = label;
          });
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
  
  void _confirmDeleteHomework(String homeworkId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Homework'),
        content: Text(
          'Are you sure you want to delete this homework assignment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _homeworkService.deleteHomework(homeworkId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Homework deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete homework: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}