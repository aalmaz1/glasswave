import 'package:hive/hive.dart';

part 'auth_user.g.dart';

@HiveType(typeId: 1)
class AuthUser extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String pwHash;

  AuthUser({
    required this.email,
    required this.name,
    required this.pwHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'pwHash': pwHash,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      email: json['email'],
      name: json['name'],
      pwHash: json['pwHash'],
    );
  }
}
