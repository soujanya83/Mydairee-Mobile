class RecipeModel{
  String id;
  String itemName;
  String type;
  String recipe;
  String createdAt;
  String createdBy;
  List ingredients;
  List media;

  RecipeModel({
    required this.id,
    required this.itemName,
    required this.type,
    required this.recipe,
    required this.createdAt,
    required this.createdBy,
    required this.ingredients,
    required this.media
    });

  static RecipeModel fromJson(Map<String,dynamic> json){
    return RecipeModel(
      id: json['id'],
      itemName: json['itemName'],
      type: json['type'],
      recipe: json['recipe'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      ingredients: json['ingredients'],
      media: json['media']
    );
  }
}