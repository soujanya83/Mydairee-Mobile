
class RecipeMediaModel{
  String id;
  String recipeid;
  String mediaUrl;
  String mediaType;

  RecipeMediaModel({
    this.id,
    this.recipeid,
    this.mediaUrl,
    this.mediaType
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


