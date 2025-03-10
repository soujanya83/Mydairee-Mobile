import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
//import 'package:html_editor/html_editor.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/api/surveyapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/questionhelpermodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:http/http.dart' as http;
import 'package:mykronicle_mobile/utils/question_helper.dart';
import 'package:path/path.dart';

class AddSurvey extends StatefulWidget {
  final String type;
  final String id;

  AddSurvey({required this.type, required this.id});

  @override
  _AddSurveyState createState() => _AddSurveyState();
}

class _AddSurveyState extends State<AddSurvey> {
  TextEditingController? title, desc;

  bool childrensFetched = false;
  List<ChildModel> _allChildrens=[];
  List<ChildModel> _selectedChildrens = [];
  List<QuestionHelper> _questions = [];
  Map<String, bool> childValues = {};
  var res;

  Map type = {
    'Multiple Choice': '1',
    'CheckBox': '2',
    'DropDown': '3',
    'Linear Scale': '4',
    'TextField': "5"
  };
  Map qutype = {
    'RADIO': 'Multiple Choice',
    'CHECKBOX': 'CheckBox',
    'DROPDOWN': 'DropDown',
    'SCALE': 'Linear Scale',
    'TEXT': "TextField"
  };

  @override
  void initState() {
    title = new TextEditingController();
    desc = new TextEditingController();
    _fetchData();
    super.initState();
  }

  _addQuestion(int index) {
    int v = index;
    _questions.add(QuestionHelper(
      choose: 'add',
      helper: QuestionHelperModel(
        choosenValue: 'Multiple Choice',
        mandatory: false,
        // image: ,
        // video: null,
        question: '',
        options1: [],
        options2: [],
        options3: [],
        options4: [], imgUrl: '', vidUrl: '', image: null,
      ),
      options1ListCallBack: (list) {
        if(_questions[v].helper==null)return;
        _questions[v].helper!.options1 = list as List<String>?;
        _questions[v].helper!.options2 = [];
        _questions[v].helper!.options3 = [];
        _questions[v].helper!.options4 = [];
        setState(() {});
      },
      options2ListCallBack: (list) {
        if(_questions[v].helper==null)return;
        _questions[v].helper!.options1 = [];
        _questions[v].helper!.options2 = list as List<String>?;
        _questions[v].helper!.options3 = [];
        _questions[v].helper!.options4 = [];
        setState(() {});
      },
      options3ListCallBack: (list) {
        _questions[v].helper!.options1 = [];
        _questions[v].helper!.options2 = [];
        _questions[v].helper!.options3 = list as List<String>?;
        _questions[v].helper!.options4 = [];
        setState(() {});
      },
      options4ListCallBack: (list) {
        _questions[v].helper!.options1 = [];
        _questions[v].helper!.options2 = [];
        _questions[v].helper!.options3 = [];
        _questions[v].helper!.options4 = list as List<String>?;
        setState(() {});
      },
      videoCallBack: (file) {
        _questions[v].helper!.video = file;
        setState(() {});
      },
      imageCallBack: (file) {
        _questions[v].helper!.image = file;
        setState(() {});
      },
      mandatoryCallback: (value) {
        _questions[v].helper!.mandatory = value!;
        setState(() {});
      },
      questionCallback: (value) {
        _questions[v].helper!.question = value!;
        setState(() {});
      },
      choiceCallback: (value) {
        _questions[v].helper!.choosenValue = value!;
        setState(() {});
      },
      funcCallback: (value) {
        if (value == 'image') {
          _questions[v].helper!.image = null;
        } else if (value == 'video') {
          _questions[v].helper!.video = null;
        } else if (value == 'add') {
          _addQuestion(_questions.length);
        } else if (value == 'copy') {
          _copyQuestion(_questions.length, v);
        } else if (value == 'delete') {
          if (v != 0) {
            _questions.removeAt(v);
          }
        }
        setState(() {});
      },
    ));
  }

  _copyQuestion(int v, int q) {
    _questions.add(QuestionHelper(
      choose: 'copy',
      helper: QuestionHelperModel(
        choosenValue: _questions[q].helper?.choosenValue,
        mandatory: _questions[q].helper?.mandatory,
        image: _questions[q].helper?.image,
        video: _questions[q].helper?.video,
        question: _questions[q].helper?.question,
        options1: _questions[q].helper?.options1,
        options2: _questions[q].helper?.options2,
        options3: _questions[q].helper?.options3,
        options4: _questions[q].helper?.options4,
      ),
      options1ListCallBack: (list) {
        _questions[v].helper?.options1 = list as List<String>?;
        _questions[v].helper?.options2 = [];
        _questions[v].helper?.options3 = [];
        _questions[v].helper?.options4 = [];
        setState(() {});
      },
      options2ListCallBack: (list) {
        _questions[v].helper?.options1 = [];
        _questions[v].helper?.options2 = list as List<String>?;
        _questions[v].helper?.options3 = [];
        _questions[v].helper?.options4 = [];
        setState(() {});
      },
      options3ListCallBack: (list) {
        _questions[v].helper?.options1 = [];
        _questions[v].helper?.options2 = [];
        _questions[v].helper?.options3 = list as List<String>?;
        _questions[v].helper?.options4 = [];
        setState(() {});
      },
      options4ListCallBack: (list) {
        _questions[v].helper?.options1 = [];
        _questions[v].helper?.options2 = [];
        _questions[v].helper?.options3 = [];
        _questions[v].helper?.options4 = list as List<String>?;
        setState(() {});
      },
      videoCallBack: (file) {
        _questions[v].helper?.video = file;
        setState(() {});
      },
      imageCallBack: (file) {
        _questions[v].helper?.image = file;
        setState(() {});
      },
      mandatoryCallback: (value) {
        _questions[v].helper?.mandatory = value!;
        setState(() {});
      },
      questionCallback: (value) {
        _questions[v].helper?.question = value!;
        setState(() {});
      },
      choiceCallback: (value) {
        _questions[v].helper?.choosenValue = value!;
        setState(() {});
      },
      funcCallback: (value) {
        if (value == 'image') {
          _questions[v].helper?.image = null;
        } else if (value == 'video') {
          _questions[v].helper?.video = null;
        } else if (value == 'add') {
          _addQuestion(_questions.length);
          setState(() {});
        } else if (value == 'copy') {
          _copyQuestion(_questions.length, v);
          setState(() {});
        } else if (value == 'delete') {
          if (v != 0) {
            _questions.removeAt(v);
            setState(() {});
          }
        }
      },
    ));
  }

  Future<void> _fetchData() async {
    ObservationsAPIHandler h =
        ObservationsAPIHandler({"userid": MyApp.LOGIN_ID_VALUE});

    var data = await h.getChildList();

    var child = data['records'];
    // ignore: deprecated_member_use
    _allChildrens = [];
    try {
      assert(child is List);
      for (int i = 0; i < child.length; i++) {
        _allChildrens.add(ChildModel.fromJson(child[i]));
        childValues[_allChildrens[i].id] = false;
      }
      childrensFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    if (widget.type == 'edit') {
      SurveyAPIHandler handler = SurveyAPIHandler({
        "userid": MyApp.LOGIN_ID_VALUE,
        "surveyid": widget.id,
      });

      var d = await handler.getData();
      if (!d.containsKey('error')) {
        print(widget.id);
        res = d['Surveys'];
        print(res);
        title?.text = res['survey'][0]['title'];
        desc?.text = res['survey'][0]['description'];
        for (var i = 0; i < res['surveyChild'].length; i++) {
          _selectedChildrens.add(ChildModel.fromJson(res['surveyChild'][i]));
          childValues[_selectedChildrens[i].id] = true;
        }

// questions with options

        for (var v = 0; v < res['surveyQuestion'].length; v++) {
          var mdata = res['surveyQuestion'];
          List<String> op = [];
          for (var k = 0; k < res['surveyQuestionOption'][v].length; k++) {
            op.add(res['surveyQuestionOption'][v][k]['optionText']);
          }
          List<String> op1 = [];
          List<String> op2 = [];
          List<String> op3 = [];
          List<String> op4 = [];

          if (mdata[v]['questionType'] == 'RADIO') {
            op1 = op;
          } else if (mdata[v]['questionType'] == 'CHECKBOX') {
            op2 = op;
          } else if (mdata[v]['questionType'] == 'DROPDOWN') {
            op3 = op;
          } else if (mdata[v]['questionType'] == 'SCALE') {
            op4 = op;
          }

          var img;
          var video;
          if (res['surveyQuestionMedia'][v].length > 0) {
            if (res['surveyQuestionMedia'][v][0]['mediaType'] == 'Image') {
              img = res['surveyQuestionMedia'][v][0]['mediaUrl'];
            } else {
              video = res['surveyQuestionMedia'][v][0]['mediaUrl'];
            }
          }

          if (res['surveyQuestionMedia'][v].length > 1) {
            if (res['surveyQuestionMedia'][v][1]['mediaType'] == 'Image') {
              img = res['surveyQuestionMedia'][v][1]['mediaUrl'];
            } else {
              video = res['surveyQuestionMedia'][v][1]['mediaUrl'];
            }
          }

          _questions.add(QuestionHelper(
            id: mdata[v]['id'],
            choose: 'copy',
            helper: QuestionHelperModel(
              choosenValue: qutype[mdata[v]['questionType']],
              mandatory: mdata[v]['isMandatory'] == '0' ? false : true,
              image: null,
              video: null,
              question: mdata[v]['questionText'],
              options1: op1,
              options2: op2,
              options3: op3,
              options4: op4,
              imgUrl: img,
              vidUrl: video,
            ),
            deleteMediaCallback: (value) {
              String url;

              for (int i = 0; i < res['surveyQuestionMedia'][v].length; i++) {
                if (_questions[v].helper?.vidUrl.toString() ==
                        res['surveyQuestionMedia'][v][i]['mediaUrl']
                            .toString() ||
                    _questions[v].helper?.imgUrl.toString() ==
                        res['surveyQuestionMedia'][v][i]['mediaUrl']
                            .toString()) {
                  url = 'MEDIA/' + res['surveyQuestionMedia'][v][i]['id'];
                  print('ddd' + url);

                  if (value == 'image') {
                    SurveyAPIHandler handler = SurveyAPIHandler({"url": url});
                    handler.deleteQueItem().then((value) {
                      print(value);
                      _questions[v].helper?.imgUrl = null;
                      setState(() {});
                    });
                  } else {
                    SurveyAPIHandler handler = SurveyAPIHandler({"url": url});
                    handler.deleteQueItem().then((value) {
                      print(value);
                      _questions[v].helper?.vidUrl = null;
                      setState(() {});
                    });
                  }

                  break;
                }
              }
            },
            options1ListCallBack: (list) {
              _questions[v].helper?.options1 = list as List<String>?;
              _questions[v].helper?.options2 = [];
              _questions[v].helper?.options3 = [];
              _questions[v].helper?.options4 = [];
              setState(() {});
            },
            options2ListCallBack: (list) {
              _questions[v].helper?.options1 = [];
              _questions[v].helper?.options2 = list as List<String>?;
              _questions[v].helper?.options3 = [];
              _questions[v].helper?.options4 = [];
              setState(() {});
            },
            options3ListCallBack: (list) {
              _questions[v].helper?.options1 = [];
              _questions[v].helper?.options2 = [];
              _questions[v].helper?.options3 = list as List<String>?;
              _questions[v].helper?.options4 = [];
              setState(() {});
            },
            options4ListCallBack: (list) {
              _questions[v].helper?.options1 = [];
              _questions[v].helper?.options2 = [];
              _questions[v].helper?.options3 = [];
              _questions[v].helper?.options4 = list as List<String>?;
              setState(() {});
            },
            videoCallBack: (file) {
              _questions[v].helper?.video = file;
              setState(() {});
            },
            imageCallBack: (file) {
              _questions[v].helper?.image = file;
              setState(() {});
            },
            mandatoryCallback: (value) {
              _questions[v].helper?.mandatory = value!;
              setState(() {});
            },
            questionCallback: (value) {
              _questions[v].helper?.question = value!;
              setState(() {});
            },
            choiceCallback: (value) {
              _questions[v].helper?.choosenValue = value!;
              setState(() {});
            },
            funcCallback: (value) async {
              if (value == 'image') {
                _questions[v].helper?.image = null;
              } else if (value == 'video') {
                _questions[v].helper?.video = null;
              } else if (value == 'add') {
                _addQuestion(_questions.length);
                setState(() {});
              } else if (value == 'copy') {
                _copyQuestion(_questions.length, v);
                setState(() {});
              } else if (value == 'delete') {
                if (v != 0) {
                  SurveyAPIHandler handler =
                      SurveyAPIHandler({"url": 'QUESTION/' + (_questions[v].id??'')});

                  var d = await handler.deleteQueItem();
                  if (!d.containsKey('error')) {
                    _questions.removeAt(v);
                  } else {
                    //    MyApp.ShowToast('unable to delete', context);
                  }
                  setState(() {});
                }
              }
            },
          ));
        }

        setState(() {});
      } else {
        //   MyApp.Show401Dialog(context);
      }
    } else {
      _addQuestion(0);
    }
  }

  GlobalKey<ScaffoldState> key = GlobalKey();
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        drawer: GetDrawer(),
        endDrawer: Drawer(
          child: Container(
            child: ListView(
              children: [
                CheckboxListTile(
                  title: Text('Select All'),
                  value: selectAll,
                  onChanged: (value) {
                    selectAll = value!;
                    for (var i = 0; i < childValues.length; i++) {
                      String key = childValues.keys.elementAt(i);
                      childValues[key] = value!;
                      if (value == true) {
                        if (!_selectedChildrens.contains(_allChildrens[i])) {
                          _selectedChildrens.add(_allChildrens[i]);
                        }
                      } else {
                        if (_selectedChildrens.contains(_allChildrens[i])) {
                          _selectedChildrens.remove(_allChildrens[i]);
                        }
                      }
                    }
                    setState(() {});
                  },
                ),
                if (childrensFetched)
                  Container(
                    height: MediaQuery.of(context).size.height - 150,
                    child: ListView.builder(
                        itemCount:
                            _allChildrens != null ? _allChildrens.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(_allChildrens[index]
                                              .imageUrl !=
                                          null &&
                                      _allChildrens[index].imageUrl != ''
                                  ? Constants.ImageBaseUrl +
                                      _allChildrens[index].imageUrl
                                  : 'https://t4.ftcdn.net/jpg/03/46/93/61/360_F_346936114_RaxE6OQogebgAWTalE1myseY1Hbb5qPM.jpg'),
                            ),
                            title: Text(_allChildrens[index].name),
                            trailing: Checkbox(
                                value: childValues[_allChildrens[index].id],
                                onChanged: (value) {
                                  if (value == true) {
                                    if (!_selectedChildrens
                                        .contains(_allChildrens[index])) {
                                      _selectedChildrens
                                          .add(_allChildrens[index]);
                                    }
                                  } else {
                                    if (_selectedChildrens
                                        .contains(_allChildrens[index])) {
                                      _selectedChildrens
                                          .remove(_allChildrens[index]);
                                    }
                                  }
                                  childValues[_allChildrens[index].id] = value!;

                                  setState(() {});
                                }),
                          );
                        }),
                  ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Constants.kButton,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: Text(
                                'SAVE',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Survey',
                      style: Constants.header1,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Add New',
                      style: Constants.header2,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'To',
                      style: Constants.header2,
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        key.currentState?.openEndDrawer();
                      },
                      child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 16.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.grey)),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey),
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    _selectedChildrens.length > 0
                        ? Wrap(
                            spacing: 8.0, // gap between adjacent chips
                            runSpacing: 4.0, // gap between lines
                            children: List<Widget>.generate(
                                _selectedChildrens.length, (int index) {
                              return Chip(
                                  label: Text(_selectedChildrens[index].name),
                                  onDeleted: () {
                                    setState(() {
                                      childValues[
                                          _selectedChildrens[index].id] = false;
                                      _selectedChildrens.removeAt(index);
                                    });
                                  });
                            }))
                        : Container(),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Title',
                      style: Constants.header2,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 16.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.grey)),
                      child: TextField(
                        controller: title,
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    TextField(
                        maxLines: 4,
                        controller: desc,
                        decoration: new InputDecoration(
                          hintText: 'Description',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.grey, width: 1),
                          ),
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4),
                            ),
                          ),
                        )),
                    //add here
                    SizedBox(
                      height: 15,
                    ),
                    _questions.length > 0
                        ? Container(
                            // height: MediaQuery.of(context).size.height *
                            //     0.6 *
                            //     _questions.length,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _questions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: _questions[index],
                                  );
                                }),
                          )
                        : Container(),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              width: 80,
                              height: 38,
                              decoration: BoxDecoration(
                                //    color: Constants.kButton,
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'CANCEL',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_selectedChildrens.length > 0) {
                              List<String> ids = [];
                              for (var i = 0;
                                  i < _selectedChildrens.length;
                                  i++) {
                                ids.add(_selectedChildrens[i].id);
                              }
                              print(ids);

                              Map<String, dynamic> mp;

                              mp = {
                                "childs": jsonEncode(ids),
                                "title": title?.text.toString(),
                                "description": desc?.text.toString(),
                                "userid": MyApp.LOGIN_ID_VALUE,
                                "createdAt": DateTime.now(),
                                "createdBY": MyApp.LOGIN_ID_VALUE,
                              };

                              for (int i = 0; i < _questions.length; i++) {
                                File? img = _questions[i].helper?.image;
                                File? vid = _questions[i].helper?.video;

                                if (img != null) {
                                  await MultipartFile.fromFile(img.path,
                                          filename: basename(img.path))
                                      .then((value) {
                                    print(value);
                                    mp['fileImg' + (i + 1).toString()] = value!;
                                  });
                                }
                                if (vid != null) {
                                  mp['fileVid' + (i + 1).toString()] =
                                      await MultipartFile.fromFile(vid.path,
                                          filename: basename(vid.path));
                                }
                                mp['mandatory' + (i + 1).toString()] =
                                    (_questions[i].helper?.mandatory??false) ? 1 : 0;
                                mp['qstn' + (i + 1).toString()] =
                                    _questions[i].helper?.question;
                                mp['qtype' + (i + 1).toString()] =
                                    type[_questions[i].helper?.choosenValue];
                                mp['ropt' + (i + 1).toString()] =
                                    jsonEncode(_questions[i].helper?.options1);
                                mp['copt' + (i + 1).toString()] =
                                    jsonEncode(_questions[i].helper?.options2);
                                mp['dopt' + (i + 1).toString()] =
                                    jsonEncode(_questions[i].helper?.options3);
                                mp['lilower' + (i + 1).toString()] =
                                   ( _questions[i].helper?.options4?.length??0) > 1
                                        ? (_questions[i].helper?.options4?[0]??"")
                                        : '';
                                mp['lihigher' + (i + 1).toString()] =
                                    (_questions[i].helper?.options4?.length??0) > 1
                                        ? (_questions[i].helper?.options4?[1]??'')
                                        : '';
                                if (_questions[i].id != null) {
                                  mp['qstnId_' +
                                      (i + 1).toString() +
                                      '_' +
                                     ( _questions[i].id??'')] = '';
                                }
                              }

                              var url;
                              if (widget.type == 'edit') {
                                mp['surveyid'] = widget.id;
                                print('hereeeeX' + mp.toString());
                                // url =
                                //     Constants.BASE_URL + 'Surveys/updateSurvey';
                                url = Constants.BASE_URL +
                                    'Surveys/updateSurveyRecord';
                              } else {
                                url =
                                    Constants.BASE_URL + "surveys/createSurvey";
                              }
                              FormData formData = FormData.fromMap(mp);

                              print(formData.fields.toString());
                              Dio dio = new Dio();
                              print(url);
                              Response? response = await dio
                                  .post(url,
                                      data: formData,
                                      options: Options(headers: {
                                        'X-DEVICE-ID':
                                            await MyApp.getDeviceIdentity(),
                                        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                      }))
                                  .then((value) {
                                var v = jsonDecode(value.toString());

                                if (v['Status'] == 'SUCCESS') {
                                  Navigator.pop(context, 'kill');
                                  // Navigator.of(context)
                                  //     .popUntil((route) => route.isFirst);
                                } else {
                                  MyApp.ShowToast("error", context);
                                }
                              }).catchError((error) => print(error));
                            } else {
                              MyApp.ShowToast("select children", context);
                            }
                          },
                          child: Container(
                              width: 60,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: Constants.kButton,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'SEND',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                )))));
  }
}
