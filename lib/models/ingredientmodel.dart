
class IngredientModel{
  String id;
  String name;

  IngredientModel({
    required this.id,
    required this.name,
    });

  static IngredientModel fromJson(Map<String,dynamic> json){
    return IngredientModel(
      id: json['id'],
      name: json['name'],
    );
  }
}


