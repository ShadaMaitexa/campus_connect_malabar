class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String registerNumber;
  final String photoUrl;
  final bool approved;
  final bool profileCompleted;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.registerNumber = '',
    this.photoUrl = '',
    this.approved = false,
    this.profileCompleted = false,
    this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'student',
      department: data['department'] as String? ?? '',
      registerNumber: data['registerNumber'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      approved: data['approved'] as bool? ?? false,
      profileCompleted: data['profileCompleted'] as bool? ?? false,
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'registerNumber': registerNumber,
      'photoUrl': photoUrl,
      'approved': approved,
      'profileCompleted': profileCompleted,
    };
  }
}
