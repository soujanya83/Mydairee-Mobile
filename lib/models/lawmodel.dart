
class LawModel{
  String id;
  String areaid;
  String section;
  String about;
  String element;

  LawModel({
    this.id,
    this.areaid,
    this.section,
    this.about,
    this.element
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


