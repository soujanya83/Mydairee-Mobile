
class RecipeMediaModel{
  String id;
  String recipeid;
  String mediaUrl;
  String mediaType;

  RecipeMediaModel({
    required this.id,
    required this.recipeid,
    required this.mediaUrl,
    required this.mediaType
    });

  static RecipeMediaModel fromJson(Map<String,dynamic> json){
    return RecipeMediaModel(
      id: json['id'],
     recipeid:json['recipeid'],
     mediaUrl: json['mediaUrl'],
     mediaType: json['mediaType']
    );
  }
}


