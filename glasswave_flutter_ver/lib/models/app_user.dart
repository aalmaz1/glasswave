class AppUser {
  final String email;
  final String name;
  final String uid;

  AppUser({
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
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        uid: json['uid'] ?? '',
      );
}
