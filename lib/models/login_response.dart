import 'user_model.dart';

class LoginResponse {
  final String status;
  final String message;
  final String? token;
  final UserModel? user;

  LoginResponse({
    required this.status,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status']?.toString() ?? 'error',
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString(),
      user: json['data'] != null
          ? UserModel.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
    );
  }
}