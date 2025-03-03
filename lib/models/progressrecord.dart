class Records {
  String id;
  String childid;
  String centerid;
  String pDevelopment;
  String emotionDevelopment;
  String socialDevelopment;
  String childInterests;
  String otherGoal;
  String createdAt;
  String createdBy;
  String name;
  String image;

  Records(
      {this.id,
      this.childid,
      this.centerid,
      this.pDevelopment,
      this.emotionDevelopment,
      this.socialDevelopment,
      this.childInterests,
      this.otherGoal,
      this.createdAt,
      this.createdBy,
      this.name,
      this.image});

  static Records fromJson(Map<String, dynamic> json) {
    return Records(
      id: json['id'],
      childid: json['childid'],
      centerid: json['centerid'],
      pDevelopment: json['p_development'],
      emotionDevelopment: json['emotion_development'],
      socialDevelopment: json['social_development'],
      childInterests: json['child_interests'],
      otherGoal: json['other_goal'],
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      name: json['name'],
      image: json['image']
    );
  }
}
