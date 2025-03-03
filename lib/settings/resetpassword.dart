import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController current, newpassword, confirmpassword;
  String currentErr = '';
  String newErr = '';
  String confirmErr = '';

  @override
  void initState() {
    current = new TextEditingController();
    newpassword = new TextEditingController();
    confirmpassword = new TextEditingController();
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
                        Constants.RESET_PASSWORD_TAG,
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
                                    Text('Current Password'),
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
                                    SizedBox(
                                      height: 2,
                                    ),
                                    if (currentErr != '')
                                      Text(
                                        currentErr,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text('New Password'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 40,
                                      child: TextField(
                                          controller: newpassword,
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
                                    SizedBox(
                                      height: 2,
                                    ),
                                    if (newErr != '')
                                      Text(
                                        newErr,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text('Confirm New Password'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 40,
                                      child: TextField(
                                          controller: confirmpassword,
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
                                    SizedBox(
                                      height: 2,
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
                                            if (current.text.isEmpty ||
                                                newpassword.text.isEmpty ||
                                                confirmpassword.text.isEmpty) {
                                              if (current.text.isEmpty) {
                                                currentErr =
                                                    'enter current password';
                                              } else {
                                                currentErr = '';
                                              }
                                              if (newpassword.text.isEmpty) {
                                                newErr = 'enter password';
                                              } else {
                                                newErr = '';
                                              }
                                              if (confirmpassword
                                                  .text.isEmpty) {
                                                confirmErr = 'enter password';
                                              } else {
                                                confirmErr = '';
                                              }
                                              setState(() {});
                                            } else if (newpassword.text
                                                    .toString() !=
                                                confirmpassword.text
                                                    .toString()) {
                                              currentErr = '';
                                              newErr = '';
                                              confirmErr = '';
                                              setState(() {});
                                              MyApp.ShowToast(
                                                  'new password and confirm password should be same',
                                                  context);
                                            } else {
                                              currentErr = '';
                                              newErr = '';
                                              confirmErr = '';
                                              setState(() {});

                                              var body = {
                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                "currentPassword":
                                                    current.text.toString(),
                                                "password": confirmpassword.text
                                                    .toString()
                                              };

                                              SettingsApiHandler res =
                                                  SettingsApiHandler(body);
                                              var result =
                                                  await res.updatePassword();

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
