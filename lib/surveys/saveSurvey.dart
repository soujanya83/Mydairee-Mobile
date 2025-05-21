import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/surveyapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';
import 'package:http/http.dart' as http;

class SaveSurvey extends StatefulWidget {
  final String id;

  SaveSurvey({required this.id});

  @override
  _SaveSurveyState createState() => _SaveSurveyState();
}

class _SaveSurveyState extends State<SaveSurvey> {
  var viewData;
  List answers = [];
  var submitted;

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future<void> _load() async {
    SurveyAPIHandler handler = SurveyAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "surveyid": widget.id});

    var data = await handler.getSurveyResponse();
    print('========after data===========');
    print(data.toString());
    if (!data.containsKey('error')) {
      viewData = data['Surveys'];
      submitted = data['Responsed'];
      for (var i = 0; i < viewData['surveyQuestion'].length; i++) {
        if (viewData['surveyQuestion'][i]['questionType'] == 'RADIO') {
          answers.add(viewData['surveyQuestionOption'][i][0]['id']);
        } else if (viewData['surveyQuestion'][i]['questionType'] ==
            'CHECKBOX') {
          List boolValues = List.generate(
              viewData['surveyQuestionOption'][i].length, (index) {
            return false;
          });
          answers.add(boolValues);
        } else if (viewData['surveyQuestion'][i]['questionType'] == 'TEXT') {
          answers.add("");
        } else if (viewData['surveyQuestion'][i]['questionType'] == 'SCALE') {
          answers.add(viewData['surveyQuestionOption'][i][0]['optionText']);
        } else {
          answers.add(viewData['surveyQuestionOption'][i][0]['optionText']);
        }
      }
      setState(() {});
    } else {
      MyApp.ShowToast('unable to fetch Data', context);
    }
  }

  Widget media(String type, String url) {
    if (type.toLowerCase() == 'image') {
      return Image.network(
        Constants.ImageBaseUrl + url,
        height: 150,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.fill,
      );
    } else if (type.toLowerCase() == 'video') {
      return VideoItem(
        url: Constants.ImageBaseUrl + url,
      );
    } else {
      return Container();
    }
  }

  Widget answerOptions(String type, List options, int val) {
    if (type == 'RADIO') {
      return ListView.builder(
          itemCount: options.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int i) {
            return Transform(
              transform: Matrix4.translationValues(-15, 0.0, 0.0),
              child: ListTile(
                leading: Radio(
                  value: options[i]['id'],
                  groupValue: answers[val],
                  onChanged: (value) {
                    answers[val] = value!;
                    setState(() {});
                  },
                ),
                title: Text(options[i]['optionText']),
              ),
            );
          });
    } else if (type == 'CHECKBOX') {
      return ListView.builder(
          itemCount: options.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int i) {
            return CheckboxListTile(
              onChanged: (value) {
                answers[val][i] = value!;
                setState(() {});
              },
              value: answers[val][i],
              title: Text(options[i]['optionText']),
            );
          });
    } else if (type == 'TEXT') {
      return TextField(
        onChanged: (value) {
          answers[val] = value!;
          setState(() {});
        },
      );
    } else if (type == 'SCALE') {
      return Row(
        children: [
          Text(answers[val]),
          Slider(
            min: double.parse(options[0]['optionText']),
            max: double.parse(options[1]['optionText']),
            value: double.parse(answers[val]),
            onChanged: (value) {
              answers[val] = value.roundToDouble().toString().split(".")[0];
              setState(() {});
            },
          )
        ],
      );
    } else {
      List<String> dropAns = List.generate(options.length, (index) {
        return options[index]['optionText'];
      });
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonHideUnderline(
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Center(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: answers[val],
                  items: dropAns.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                   onChanged: (String? value)  {
                    setState(() {
                      answers[val] = value!;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
        child: viewData != null
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Survey',
                        style: Constants.header1,
                      ),
                      SizedBox(height: 5),
                      submitted == '1'
                          ? Text(
                              'You have successfully submitted your response',
                              style: TextStyle(color: Colors.green),
                            )
                          : Container(),
                      SizedBox(height: 5),
                      Text(
                        viewData['survey'][0]['title'],
                        style: Constants.header2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(viewData['survey'][0]['description']),
                      SizedBox(
                        height: 5,
                      ),
                      ListView.builder(
                          itemCount: viewData['surveyQuestion'].length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(viewData['surveyQuestion'][index]
                                          ['questionText']),
                                      viewData['surveyQuestionMedia'][index]
                                                  .length >
                                              0
                                          ? ListView.builder(
                                              itemCount: viewData[
                                                          'surveyQuestionMedia']
                                                      [index]
                                                  .length,
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int i) {
                                                return media(
                                                    viewData[
                                                            'surveyQuestionMedia']
                                                        [index][i]['mediaType'],
                                                    viewData[
                                                            'surveyQuestionMedia']
                                                        [index][i]['mediaUrl']);
                                              })
                                          : Container(),
                                      answerOptions(
                                          viewData['surveyQuestion'][index]
                                              ['questionType'],
                                          viewData['surveyQuestionOption']
                                              [index],
                                          index),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      SizedBox(
                        height: 10,
                      ),
                      submitted == '0'
                          ? Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      List responseList = [];
                                      for (var i = 0;
                                          i < viewData['surveyQuestion'].length;
                                          i++) {
                                        if (viewData['surveyQuestion'][i]
                                                ['questionType'] ==
                                            'RADIO') {
                                          responseList.add({
                                            "questionId":
                                                viewData['surveyQuestion'][i]
                                                    ['id'],
                                            "responses": [answers[i]]
                                          });
                                        } else if (viewData['surveyQuestion'][i]
                                                ['questionType'] ==
                                            'CHECKBOX') {
                                          List cList = [];
                                          for (var j = 0;
                                              j < answers[i].length;
                                              j++) {
                                            if (answers[i][j] == true) {
                                              cList.add(viewData[
                                                      'surveyQuestionOption'][i]
                                                  [j]['id']);
                                            }
                                          }
                                          responseList.add({
                                            "questionId":
                                                viewData['surveyQuestion'][i]
                                                    ['id'],
                                            "responses": cList
                                          });
                                        } else if (viewData['surveyQuestion'][i]
                                                ['questionType'] ==
                                            'TEXT') {
                                          responseList.add({
                                            "questionId":
                                                viewData['surveyQuestion'][i]
                                                    ['id'],
                                            "responses": [answers[i]]
                                          });
                                        } else if (viewData['surveyQuestion'][i]
                                                ['questionType'] ==
                                            'SCALE') {
                                          responseList.add({
                                            "questionId":
                                                viewData['surveyQuestion'][i]
                                                    ['id'],
                                            "responses": [answers[i]]
                                          });
                                        } else {
                                          var dAns = '';
                                          for (var j = 0;
                                              j <
                                                  viewData['surveyQuestionOption']
                                                          [i]
                                                      .length;
                                              j++) {
                                            if (viewData['surveyQuestionOption']
                                                    [i][j]['optionText'] ==
                                                answers[i]) {
                                              dAns = viewData[
                                                      'surveyQuestionOption'][i]
                                                  [j]['id'];
                                            }
                                          }
                                          responseList.add({
                                            "questionId":
                                                viewData['surveyQuestion'][i]
                                                    ['id'],
                                            "responses": dAns
                                          });
                                        }
                                      }

                                      var objToSend = {
                                        "userid": MyApp.LOGIN_ID_VALUE,
                                        "surveyid": widget.id,
                                        "responses": responseList,
                                      };
                                      print('assss' + objToSend.toString());

                                      var _toSend = Constants.BASE_URL +
                                          'surveys/surveyResponse';

                                      print(_toSend);
                                      final response = await http.post(Uri.parse(_toSend),
                                          body: jsonEncode(objToSend),
                                          headers: {
                                            'X-DEVICE-ID':
                                                await MyApp.getDeviceIdentity(),
                                            'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                          });
                                      print(response.body);
                                      if (response.statusCode == 200) {
                                        MyApp.ShowToast("updated", context);
                                        Navigator.pop(context, 'kill');
                                      } else if (response.statusCode == 401) {
                                        MyApp.Show401Dialog(context);
                                      }
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Constants.kButton,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 8, 12, 8),
                                          child: Text(
                                            'SUBMIT',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              )
            : Container(),
      ),
    );
  }
}
