class AuthorModel {
  String id;
  String name;

  AuthorModel({
    this.id,
    this.name,
  });

  static AuthorModel fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
