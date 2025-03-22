import 'dart:io';

class QuestionHelperModel {
  String choosenValue;
  bool mandatory;
  File? image;
  File? video;
  String question;
  String imgUrl;
  String vidUrl;
  List<String> options1;
  List<String> options2;
  List<String> options3;
  List<String> options4;
  List<String> options5;

  QuestionHelperModel({
    this.choosenValue = '',
    this.mandatory = false,
    this.imgUrl = '',
    this.vidUrl = '',
    this.image,
    this.video,
    this.question = '',
    List<String>? options1,
    List<String>? options2,
    List<String>? options3,
    List<String>? options4,
    List<String>? options5,
  })  : options1 = options1 ?? [],
        options2 = options2 ?? [],
        options3 = options3 ?? [],
        options4 = options4 ?? [],
        options5 = options5 ?? [];
}
