/// Модель пользователя для локальной авторизации
class AuthUser {
  final String email;
  final String name;
  final String pwHash;

  AuthUser({
    required this.email,
    required this.name,
    required this.pwHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'pwHash': pwHash,
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      email: map['email'] as String,
      name: map['name'] as String,
      pwHash: map['pwHash'] as String,
    );
  }
}
