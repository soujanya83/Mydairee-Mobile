class ElementModel {
  String id;
  String standardId;
  String name;
  String elementName;
  String about;

  ElementModel({
    required this.id,
    required this.standardId,
    required this.name,
    required this.about,
    required this.elementName,
  });

  static ElementModel fromJson(Map<String, dynamic> json) {
    return ElementModel(
      id: json['id'] ?? '',
      standardId: json['standardId'] ?? '',
      name: json['name'] ?? '',
      about: json['about'] ?? '',
      elementName: json['elementName'] ?? '',
    );
  }
}
