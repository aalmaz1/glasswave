import 'dart:convert';

/// Модель пользователя для локального хранения
class User {
  final String email;
  final String name;
  final String passwordHash;

  User({
    required this.email,
    required this.name,
    required this.passwordHash,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'passwordHash': passwordHash,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'] as String,
        name: json['name'] as String,
        passwordHash: json['passwordHash'] as String,
      );
}
