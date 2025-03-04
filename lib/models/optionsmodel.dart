
class OptionsModel{
  String id;
  String idsubactivity;
  String title;

  OptionsModel({
    required this.id,
    required this.idsubactivity,
    required this.title
    });

  static OptionsModel fromJson(Map<String,dynamic> json){
    return OptionsModel(
      id: json['id'],
      idsubactivity: json['idsubactivity'],
      title: json['title'],
    );
  }
}


