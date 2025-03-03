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
    this.id,
    this.itemName,
    this.type,
    this.recipe,
    this.createdAt,
    this.createdBy,
    this.ingredients,
    this.media
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