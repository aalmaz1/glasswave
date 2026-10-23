class AppUser {
  final String email;
  final String name;
  final String uid;

  const AppUser({
    required this.email,
    required this.name,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'uid': uid,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        uid: json['uid'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          name == other.name &&
          uid == other.uid;

  @override
  int get hashCode => Object.hash(email, name, uid);
}

