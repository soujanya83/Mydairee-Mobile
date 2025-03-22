class LawModel {
  String id;
  String areaId;
  String section;
  String about;
  String element;

  LawModel({
    required this.id,
    required this.areaId,
    required this.section,
    required this.about,
    required this.element,
  });

  static LawModel fromJson(Map<String, dynamic> json) {
    return LawModel(
      id: json['id'] ?? '',
      areaId: json['areaId'] ?? '',
      section: json['section'] ?? '',
      about: json['about'] ?? '',
      element: json['element'] ?? '',
    );
  }
}
