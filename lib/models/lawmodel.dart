
class LawModel{
  String id;
  String areaid;
  String section;
  String about;
  String element;

  LawModel({
    required this.id,
    required this.areaid,
    required this.section,
    required this.about,
    required this.element
    });

  static LawModel fromJson(Map<String,dynamic> json){
    return LawModel(
      id: json['id'],
      areaid: json['areaId'],
      section: json['section'],
      about: json['about'],
      element: json['element']
    );
  }
}


