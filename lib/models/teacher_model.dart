// models/teacher_model.dart
class Teacher {
  final String uid;
  final String name;
  final int age;
  final String address;
  final String email;
  final String department;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Teacher({
    required this.uid,
    required this.name,
    required this.age,
    required this.address,
    required this.email,
    required this.department,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory Teacher.fromMap(Map<String, dynamic> data, String uid) {
    return Teacher(
      uid: uid,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'address': address,
      'email': email,
      'department': department,
      'isVerified': isVerified,
      'updatedAt': DateTime.now(),
    };
  }
}