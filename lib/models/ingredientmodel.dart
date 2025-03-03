
class IngredientModel{
  String id;
  String name;

  IngredientModel({
    this.id,
    this.name,
    });

  static IngredientModel fromJson(Map<String,dynamic> json){
    return IngredientModel(
      id: json['id'],
      name: json['name'],
    );
  }
}


