import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/progressnotes.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;

class AddProgressNotesActivity extends StatefulWidget {
  final String childid;
  final String centerid;

  AddProgressNotesActivity({
    required this.childid,
    required this.centerid,
  });

  @override
  _AddProgressNotesActivityState createState() =>
      _AddProgressNotesActivityState();
}

class _AddProgressNotesActivityState extends State<AddProgressNotesActivity> {
  TextEditingController? phydeveloment,
      emodeveloment,
      scodeveloment,
      childinter,
      othergoal;
  final _formKey = new GlobalKey<FormState>();
  @override
  void initState() {
    phydeveloment = TextEditingController();
    emodeveloment = TextEditingController();
    scodeveloment = TextEditingController();
    childinter = TextEditingController();
    othergoal = TextEditingController();
    super.initState();
  }

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
                    "Add Notes",
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
                                  'ProgressNotes/addProgressNote';
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
                              };
                              print(jsonEncode(objToSend));

                              print(MyApp.LOGIN_ID_VALUE);
                              print(await MyApp.getDeviceIdentity());
                              final response = await http.post(Uri.parse(_toSend),
                                  body: jsonEncode(objToSend),
                                  headers: {
                                    'X-DEVICE-ID':
                                        await MyApp.getDeviceIdentity(),
                                    'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                  });
                              print(response.headers);
                              print(response.body);
                              if (response.statusCode == 200) {
                                MyApp.ShowToast("Created", context);
                                print('created');
                                // Navigator.of(context).popUntil(
                                //     (route) => route.isFirst);
                                Navigator.pop(context);
                              } else if (response.statusCode == 401) {
                                //  MyApp.Show401Dialog(context);
                              }
                              setState(() {});
                            } else {
                              print("from invalid");
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
                                    'ADD',
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
