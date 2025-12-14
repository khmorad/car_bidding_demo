class UserModel {
  final String id;
  final String email;
  final String password;

  UserModel({required this.id, required this.email, required this.password});

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      password: data['password'] ?? '',
    );
  }
}
