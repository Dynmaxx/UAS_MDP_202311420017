class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  // Melakukan parsing data pengguna dari format JSON Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  // Mengubah data pengguna menjadi JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'created_at': createdAt,
    };
  }
}
