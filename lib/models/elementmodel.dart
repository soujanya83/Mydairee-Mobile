
class ElementModel{
  String id;
  String standardId;
  String name;
  String elementName;
  String about;

  ElementModel({
    this.id,
    this.standardId,
    this.name,
    this.about,
    this.elementName
    });

  static ElementModel fromJson(Map<String,dynamic> json){
    return ElementModel(
      id: json['id'],
      standardId: json['standardId'],
      name: json['name'],
      about: json['about'],
      elementName: json['elementName']
    );
  }
}


