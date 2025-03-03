import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class ResetPin extends StatefulWidget {
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<ResetPin> {
  TextEditingController current, newpin, confirmpin;
  String currentErr = '';
  String newErr = '';
  String confirmErr = '';

  @override
  void initState() {
    current = new TextEditingController();
    newpin = new TextEditingController();
    confirmpin = new TextEditingController();
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
                        Constants.RESET_PIN_TAG,
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
                                    Text('Current Pin'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 40,
                                      child: TextField(
                                          controller: current,
                                          keyboardType: TextInputType.number,
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
                                    Text('New Pin'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 40,
                                      child: TextField(
                                          controller: newpin,
                                          keyboardType: TextInputType.number,
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
                                    Text('Confirm New Pin'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 40,
                                      child: TextField(
                                          controller: confirmpin,
                                          keyboardType: TextInputType.number,
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
                                                newpin.text.isEmpty ||
                                                confirmpin.text.isEmpty) {
                                              if (current.text.isEmpty) {
                                                currentErr =
                                                    'enter current pin';
                                              } else {
                                                currentErr = '';
                                              }
                                              if (newpin.text.isEmpty) {
                                                newErr = 'enter pin';
                                              } else {
                                                newErr = '';
                                              }
                                              if (confirmpin.text.isEmpty) {
                                                confirmErr = 'enter pin';
                                              } else {
                                                confirmErr = '';
                                              }
                                              setState(() {});
                                            } else if (newpin.text.toString() !=
                                                confirmpin.text.toString()) {
                                              currentErr = '';
                                              newErr = '';
                                              confirmErr = '';
                                              setState(() {});
                                              MyApp.ShowToast(
                                                  'new pin and confirm pin should be same',
                                                  context);
                                            } else {
                                              currentErr = '';
                                              newErr = '';
                                              confirmErr = '';
                                              setState(() {});

                                              var body = {
                                                "userid": MyApp.LOGIN_ID_VALUE,
                                                "currentPin":
                                                    current.text.toString(),
                                                "pin":
                                                    confirmpin.text.toString()
                                              };

                                              SettingsApiHandler res =
                                                  SettingsApiHandler(body);
                                              var result =
                                                  await res.updatePin();

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
