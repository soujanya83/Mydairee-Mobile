class QAModel {
  String id;
  String areaid;
  String concept;
  String elements;
  String about;
  String status;
  String identifiedPractice;

  QAModel(
      {required this.id,
      required this.areaid,
      required this.concept,
      required this.elements,
      required this.about,
      required this.status,
      required this.identifiedPractice});

  static QAModel fromJson(Map<String, dynamic> json) {
    return QAModel(
        id: json['id'],
        areaid: json['areaid'],
        concept: json['concept'],
        elements: json['elements'],
        about: json['about'],
        status: json['status'],
        identifiedPractice: json['identified_practice']);
  }
}
