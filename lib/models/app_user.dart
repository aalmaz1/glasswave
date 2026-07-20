class AppUser {
  final String email;
  final String name;

  AppUser({required this.email, required this.name});

  Map<String, dynamic> toJson() => {'email': email, 'name': name};
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(email: json['email'], name: json['name']);
}
