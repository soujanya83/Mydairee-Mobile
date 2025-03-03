import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/progressnotes.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/progressrecord.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;

class EditProgressNotesActivity extends StatefulWidget {
  final String childid;
  final String centerid;
  final String pnid;
  final String phydevelopment;
  final String emodeveloment;
  final String scodeveloment;
  final String childinter;
  final String othergoal;

  EditProgressNotesActivity(
      {this.childid,
      this.centerid,
      this.pnid,
      this.phydevelopment,
      this.emodeveloment,
      this.scodeveloment,
      this.childinter,
      this.othergoal});

  @override
  _EditProgressNotesActivityState createState() =>
      _EditProgressNotesActivityState();
}

class _EditProgressNotesActivityState extends State<EditProgressNotesActivity> {
  TextEditingController phydeveloment = new TextEditingController();
  TextEditingController emodeveloment = new TextEditingController();
  TextEditingController scodeveloment = new TextEditingController();
  TextEditingController childinter = new TextEditingController();
  TextEditingController othergoal = new TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  Records records;
  @override
  void initState() {
    phydeveloment == null
        ? phydeveloment.text = ''
        : phydeveloment.text = widget.phydevelopment;

    emodeveloment == null
        ? emodeveloment.text = ''
        : emodeveloment.text = widget.emodeveloment;
    scodeveloment == null
        ? scodeveloment.text = ''
        : scodeveloment.text = widget.scodeveloment;

    childinter == null
        ? childinter.text = ''
        : childinter.text = widget.childinter;

    othergoal == null ? othergoal.text = '' : othergoal.text = widget.othergoal;

    super.initState();
  }

  // Future<void> _fetchData() async {
  //   Map<String, String> data = {
  //     'userid': MyApp.LOGIN_ID_VALUE,
  //     'centerid': widget.centerid,
  //   };
  //   ProgramNotesApiHandler hlr = ProgramNotesApiHandler(data);

  //   var pdata = await hlr.getDetails();
  //   if (!pdata.containsKey('error')) {
  //     print(data);
  //     var res = pdata['records'];
  //     print('roomsdd' + pdata['records'].toString());
  //     try {
  //       records = Records.fromJson(res);
  //       phydeveloment.text = pdata['records']['p_development'];
  //       emodeveloment.text = pdata['records']['emotion_development'];

  //       scodeveloment.text = pdata['records']['social_development'];
  //       childinter.text = pdata['records']['child_interests'];
  //       othergoal.text = pdata['records']['other_goal'];
  //       // phydeveloment.text = pdata['records'].pDevelopment;
  //       // emodeveloment.text = records.emotionDevelopment;

  //       // scodeveloment.text = records.socialDevelopment;
  //       // childinter.text = records.childInterests;
  //       // othergoal.text = records.otherGoal;
  //       // currentIndex = users.indexWhere((element) {
  //       //   print(element.userid);
  //       //   print(roomDesc.userId);
  //       //   return element.userid == roomDesc.userId;
  //       // });
  //       // print('niii' + currentIndex.toString());
  //       // if (currentIndex == -1) {
  //       //   currentIndex = 0;
  //       // }
  //       // for (int i = 0; i < data['roomStaff'].length; i++) {
  //       //   // selectedEdu.add(UserModel(
  //       //   //   userid: data['roomStaff'][i]['userId'],
  //       //   //   name: data['roomStaff'][i]['userName'],
  //       //   // ));
  //       //   var sel = users.where(
  //       //       (element) => element.userid == data['roomStaff'][i]['userId']);
  //       //   if (sel.isNotEmpty) {
  //       //     selectedEdu.add(sel.first);
  //       //   }
  //       //   eduValues[selectedEdu[i].userid] = true;
  //       // }

  //       if (this.mounted) setState(() {});
  //     } catch (e) {
  //       print(e);
  //     }
  //   } else {
  //     MyApp.Show401Dialog(context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Notes",
                    style: Constants.header1,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Physical Development',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    maxLines: 1,
                    controller: phydeveloment,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black26, width: 0.0),
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(4),
                        ),
                      ),
                    ),
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return 'Please Physical Development ';
                      // }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Emotional Development',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    maxLines: 1,
                    controller: emodeveloment,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black26, width: 0.0),
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(4),
                        ),
                      ),
                    ),
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return 'Please Emotional Development ';
                      // }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Social Development',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    maxLines: 1,
                    controller: scodeveloment,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black26, width: 0.0),
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(4),
                        ),
                      ),
                    ),
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return 'Please Social Development ';
                      // }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Child's Interests",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    maxLines: 1,
                    controller: childinter,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black26, width: 0.0),
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(4),
                        ),
                      ),
                    ),
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return "Please Child's Interests ";
                      // }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Other Goal's",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    maxLines: 1,
                    controller: othergoal,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black26, width: 0.0),
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(4),
                        ),
                      ),
                    ),
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return "Please Other Goal's ";
                      // }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 15,
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
                            if (_formKey.currentState.validate()) {
                              String _toSend = Constants.BASE_URL +
                                  'ProgressNotes/updateProgressNote';
                              var objToSend = {
                                "userid": MyApp.LOGIN_ID_VALUE,
                                "childid": widget.childid,
                                "centerid": widget.centerid,
                                "p_development": phydeveloment.text.toString(),
                                "emotion_development":
                                    emodeveloment.text.toString(),
                                "social_development":
                                    scodeveloment.text.toString(),
                                "child_interests": childinter.text.toString(),
                                "other_goal": othergoal.text.toString(),
                                "pnid": widget.pnid,
                              };
                              print(jsonEncode(objToSend));

                              print(MyApp.LOGIN_ID_VALUE);
                              print(await MyApp.getDeviceIdentity());
                              final response = await http.post(_toSend,
                                  body: jsonEncode(objToSend),
                                  headers: {
                                    'X-DEVICE-ID':
                                        await MyApp.getDeviceIdentity(),
                                    'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                  });
                              print(response.headers);
                              print(response.body);
                              if (response.statusCode == 200) {
                                MyApp.ShowToast(
                                    "Record saved successfully", context);
                                print('created');
                                // Navigator.of(context).popUntil(
                                //     (route) => route.isFirst);
                                Navigator.pop(context);
                              } else if (response.statusCode == 401) {
                                //  MyApp.Show401Dialog(context);
                              }
                              setState(() {});
                            }
                          },
                          child: Container(
                              width: 80,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: Constants.kButton,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
