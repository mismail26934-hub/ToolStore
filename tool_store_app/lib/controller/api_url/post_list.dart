class PostList {
  late String name;
  late String username;
  late String password;
  late String address;
  late String level;
  late String email;
  late String noTelp;
  late String token;
  PostList({
    required this.name,
    required this.username,
    required this.password,
    required this.address,
    required this.level,
    required this.email,
    required this.noTelp,
    required this.token,
  });

  // factory PostList.fromJasons(Map<String, dynamic> json) {
  //   return PostList(
  //     name: json['name'] ?? "",
  //     username: json['username'] ?? "",
  //     password: json['password'] ?? "",
  //     address: json['address'] ?? "",
  //   );
  // }
}
