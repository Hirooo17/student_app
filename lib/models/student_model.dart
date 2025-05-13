// models/student_model.dart
class Student {
  final String uid;
  final String name;
  final int age;
  final String course;
  final int year;
  final String address;
  final List<String> subjects;
  final String email;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    required this.uid,
    required this.name,
    required this.age,
    required this.course,
    required this.year,
    required this.address,
    required this.subjects,
    required this.email,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory Student.fromMap(Map<String, dynamic> data, String uid) {
    return Student(
      uid: uid,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      course: data['course'] ?? '',
      year: data['year'] ?? 1,
      address: data['address'] ?? '',
      subjects: List<String>.from(data['subjects'] ?? []),
      email: data['email'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'course': course,
      'year': year,
      'address': address,
      'subjects': subjects,
      'email': email,
      'isVerified': isVerified,
      'updatedAt': DateTime.now(),
    };
  }
}