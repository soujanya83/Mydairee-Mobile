import 'dart:io';

class QuestionHelperModel {
  String choosenValue;
  bool mandatory;
  File image;
  File video;
  String question;
  String imgUrl;
  String vidUrl;
  List<String> options1;
  List<String> options2;
  List<String> options3;
  List<String> options4;
  List<String> options5;

  QuestionHelperModel({
    this.choosenValue,
    this.mandatory,
    this.imgUrl,
    this.vidUrl,
    this.image,
    this.video,
    this.question,
    this.options1,
    this.options2,
    this.options3,
    this.options4,
    this.options5,
  });
}
