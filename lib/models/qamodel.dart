class QAModel {
  String id;
  String areaid;
  String concept;
  String elements;
  String about;
  String status;
  String identifiedPractice;

  QAModel(
      {this.id,
      this.areaid,
      this.concept,
      this.elements,
      this.about,
      this.status,
      this.identifiedPractice});

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
