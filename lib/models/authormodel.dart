class AuthorModel {
  String id;
  String name;

  AuthorModel({
   required  this.id,
   required  this.name,
  });

  static AuthorModel fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id']??'',
      name: json['name']??'',
    );
  }
}
