import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class ChangeMail extends StatefulWidget {
  @override
  _ChangeMailState createState() => _ChangeMailState();
}

class _ChangeMailState extends State<ChangeMail> {
  TextEditingController current, newmail, confirmmail;
  String currentErr = '';
  String newErr = '';
  String confirmErr = '';

  @override
  void initState() {
    current = new TextEditingController();
    newmail = new TextEditingController();
    confirmmail = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        Constants.CHANGE_MAILID_TAG,
                        style: Constants.header1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        child: Container(
                          height: MediaQuery.of(context).size.height - 130,
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: Stack(
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Current Mail Id'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 40,
                                      child: TextField(
                                          controller: current,
                                          decoration: new InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black26,
                                                  width: 0.0),
                                            ),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                const Radius.circular(4),
                                              ),
                                            ),
                                          )),
                                    ),
                                    if (currentErr != '')
                                      Text(
                                        currentErr,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text('New Mail Id'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 40,
                                      child: TextField(
                                          controller: newmail,
                                          decoration: new InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black26,
                                                  width: 0.0),
                                            ),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                const Radius.circular(4),
                                              ),
                                            ),
                                          )),
                                    ),
                                    if (newErr != '')
                                      Text(
                                        newErr,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text('Confirm New Mail Id'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 40,
                                      child: TextField(
                                          controller: confirmmail,
                                          decoration: new InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black26,
                                                  width: 0.0),
                                            ),
                                            border: new OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                const Radius.circular(4),
                                              ),
                                            ),
                                          )),
                                    ),
                                    if (confirmErr != '')
                                      Text(
                                        confirmErr,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  bottom: 5,
                                  right: 0,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                              width: 82,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                //    color: Constants.kButton,
                                                border: Border.all(
                                                  color: Colors.grey,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'CANCEL',
                                                      style: TextStyle(
                                                          color: Colors.black),
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
                                               Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    
 
                                            if (current.text.isEmpty ||
                                                newmail.text.isEmpty ||
                                                confirmmail.text.isEmpty) {
                                              if (current.text.isEmpty) {
                                                currentErr =
                                                    'enter current mail id';
                                              } else {
                                                currentErr = '';
                                              }
                                              if (newmail.text.isEmpty) {
                                                newErr = 'enter mail id';
                                              } else {
                                                newErr = '';
                                              }
                                              if (confirmmail.text.isEmpty) {
                                                confirmErr = 'enter mail id';
                                              } else {
                                                confirmErr = '';
                                              }
                                              setState(() {});
                                            } else if (newmail.text
                                                    .toString() !=
                                                confirmmail.text.toString()) {
                                              currentErr = '';
                                              newErr = '';
                                              confirmErr = '';
                                              setState(() {});
                                              MyApp.ShowToast(
                                                  'new mail id and confirm mail id should be same',
                                                  context);
                                            } 
                                             else if (!regex.hasMatch(current.text.trim())){
                                                  currentErr =
                                                    'enter proper mail id';
                                                    setState(() {
                                                      
                                                    });
                                             }else if (!regex.hasMatch(newmail.text.trim())){
                                                  newErr =
                                                    'enter proper mail id';
                                                    setState(() {
                                                      
                                                    });
                                             }
                                            else {
                                              currentErr = '';
                                              newErr = '';
                                              confirmErr = '';
                                              setState(() {});

                                              var body = {
                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                "currentEmail":
                                                    current.text.toString(),
                                                "email":
                                                    confirmmail.text.toString()
                                              };

                                              SettingsApiHandler res =
                                                  SettingsApiHandler(body);
                                              var result =
                                                  await res.updateEmail();

                                              if (!result
                                                  .containsKey('error')) {
                                                Navigator.pop(context);
                                              } else {
                                                MyApp.ShowToast(
                                                    result['error'], context);
                                              }
                                            }
                                          },
                                          child: Container(
                                              width: 82,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                  color: Constants.kButton,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      'SAVE',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      )
                    ])))));
  }
}
