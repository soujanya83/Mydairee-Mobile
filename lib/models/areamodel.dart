class AreaModel {
  String id;
  String title;
  String color;
  String about;
  double resultPer;

  AreaModel({
    required this.id,
    required this.title,
    required this.color,
    required this.about,
    required this.resultPer,
  });

  static AreaModel fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      color: json['color'] ?? '',
      about: json['about'] ?? '',
      resultPer: (json['resultPer'] is num) 
          ? (json['resultPer'] as num) / 100 
          : 0.0,
    );
  }
}
