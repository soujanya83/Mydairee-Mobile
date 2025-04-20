import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/announcementsapi.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/observation/addobservation.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:html_editor_enhanced/html_editor.dart';

class NewAnnouncements extends StatefulWidget {
  final String type;
  final String id;
  final String centerid;
  NewAnnouncements(
      {required this.type, required this.id, required this.centerid});
  @override
  _NewAnnouncementsState createState() => _NewAnnouncementsState();
}

class _NewAnnouncementsState extends State<NewAnnouncements> {
  TextEditingController title = TextEditingController();
  // GlobalKey<State<StatefulWidget>> keyEditor = GlobalKey();
  // HtmlEditorController editorController = HtmlEditorController();
  static TextEditingController desController = TextEditingController();
  String _date = '';
  String date = '';
  bool childrensFetched = false;
  late List<ChildModel> _allChildrens;

  var dataDetail;
  List<ChildModel> _selectedChildrens = [];
  Map<String, bool> childValues = {};
  String textData = '';

  @override
  void initState() {
    // keyEditor = GlobalKey();
    title = new TextEditingController();
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    ObservationsAPIHandler h =
        ObservationsAPIHandler({"userid": MyApp.LOGIN_ID_VALUE});

    var data = await h.getChildList();
    if (!data.containsKey('error')) {
      var child = data['records'];
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
    } else {
      MyApp.Show401Dialog(context);
    }

    if (widget.type == 'update') {
      print(widget.id);
      print(widget.type);

      AnnouncementsAPIHandler h = AnnouncementsAPIHandler({"id": widget.id});

      var data = await h.getAnnouncementsDetails();
      if (!data.containsKey('error')) {
        print(data);
        dataDetail = data['Info'];
        title.text = dataDetail['title'];
        _date = dataDetail['eventDate'];

        var inputFormat = DateFormat("yyyy-MM-dd");
        final DateFormat formati = DateFormat('dd-MM-yyyy');
        var date1 = inputFormat.parse(_date);
        date = formati.format(date1);

        if (dataDetail['text'].isNotEmpty) {
          Future.delayed(Duration(seconds: 1), () {
            print('++++data seted ++++');
            print(textData);
            setState(() {
              textData = dataDetail['text'];
              desController.text = textData;
            });
          });
        }
        {
          print('++++data is the empty+++++');
        }

        // Set the fetched data as the initial content of the editor

        var child = dataDetail['children'];
        _selectedChildrens = [];
        try {
          assert(child is List);
          for (int i = 0; i < child.length; i++) {
            _selectedChildrens.add(ChildModel.fromJson(child[i]));
            childValues[_allChildrens[i].id] = true;
          }
          if (this.mounted) setState(() {});
        } catch (e) {
          print(e);
        }
        setState(() {});
      } else {
        MyApp.Show401Dialog(context);
      }
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
                    selectAll = value ?? false;
                    for (var i = 0; i < childValues.length; i++) {
                      String key = childValues.keys.elementAt(i);
                      childValues[key] = value ?? false;
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
                childrensFetched
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: ListView.builder(
                            itemCount: _allChildrens != null
                                ? _allChildrens.length
                                : 0,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      _allChildrens[index].imageUrl != null
                                          ? Constants.ImageBaseUrl +
                                              _allChildrens[index].imageUrl
                                          : ''),
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
                                      childValues[_allChildrens[index].id] =
                                          value!;

                                      setState(() {});
                                    }),
                              );
                            }),
                      )
                    : Container(),
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
                      'Create Announcements',
                      style: Constants.header1,
                    ),
                    SizedBox(height: 10),
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
                    customTextField(context: context, controller: title),
                    SizedBox(
                      height: 5,
                    ),
                    // Container(
                    //   height: MediaQuery.of(context).size.height * 0.4,
                    //   child: textData != ''
                    //       ? HtmlEditor(
                    //           key: keyEditor,
                    //           controller: editorController,
                    //         )
                    //       : HtmlEditor(
                    //           key: keyEditor,
                    //           controller: editorController,
                    //         ),
                    // ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Description',
                      style: Constants.header2,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    customMultilineTextField(
                      context: context,
                      controller: desController,
                      maxLines: 5,
                      minLines: 3,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Date',
                      style: Constants.header2,
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(left: 16.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.grey)),
                        child: ListTile(
                            title: Text(_date.isNotEmpty ? _date : date),
                            trailing: Icon(Icons.calendar_today)),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if (MyApp.USER_TYPE_VALUE != 'Parent')
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
                              final txt = await desController.text;
                              String s = txt;

                              List<String> ids = [];
                              for (var i = 0;
                                  i < _selectedChildrens.length;
                                  i++) {
                                ids.add(_selectedChildrens[i].id);
                              }
                              print(ids);

                              if (widget.type == 'update') {
                                String _toSend = Constants.BASE_URL +
                                    'announcements/updateAnnouncement';
                                var objToSend = {
                                  "userid": MyApp.LOGIN_ID_VALUE,
                                  "announcementId": widget.id,
                                  "title": title.text.toString(),
                                  "description": s,
                                  "date": _date,
                                  "children": ids,
                                };
                                print(jsonEncode(objToSend));
                                final response = await http.post(
                                    Uri.parse(_toSend),
                                    body: jsonEncode(objToSend),
                                    headers: {
                                      'X-DEVICE-ID':
                                          await MyApp.getDeviceIdentity(),
                                      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                    });
                                print(response.body);
                                if (response.statusCode == 200) {
                                  MyApp.ShowToast("updated", context);
                                  print('created');
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                } else if (response.statusCode == 401) {
                                  MyApp.Show401Dialog(context);
                                }
                              } else {
                                String _toSend = Constants.BASE_URL +
                                    'announcements/createAnnouncement/';
                                var objToSend = {
                                  "childId": ids,
                                  "title": title.text.toString(),
                                  "text": s,
                                  "eventDate": _date,
                                  "user": MyApp.NAME_VALUE,
                                  "createdOn": DateTime.now().toString(),
                                  "createdBy": MyApp.LOGIN_ID_VALUE,
                                  "userid": MyApp.LOGIN_ID_VALUE,
                                  'centerid': widget.centerid
                                };
                                print('+========++');
                                print(objToSend);
                                await MyApp.getDeviceIdentity()
                                    .then((value) => print(value));
                                print(jsonEncode(objToSend));
                                print(MyApp.AUTH_TOKEN_VALUE);

                                final response = await http.post(
                                    Uri.parse(_toSend),
                                    body: jsonEncode(objToSend),
                                    headers: {
                                      'X-DEVICE-ID':
                                          await MyApp.getDeviceIdentity(),
                                      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                                    });
                                print(response.body);
                                if (response.statusCode == 200) {
                                  MyApp.ShowToast("Saved", context);
                                  print('created');
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                } else if (response.statusCode == 401) {
                                  MyApp.Show401Dialog(context);
                                }
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

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1930),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget? child) {
        // ✅ child should be nullable (Widget?)
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme:
                ColorScheme.light(primary: Theme.of(context).primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child ?? SizedBox(), // ✅ Use null check (child!)
        );
      },
    );

    if (picked != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(picked);

      final DateFormat inputFormat = DateFormat("yyyy-MM-dd");
      final DateFormat outputFormat = DateFormat('dd-MM-yyyy');
      final DateTime date1 = inputFormat.parse(formatted);
      _date = outputFormat.format(date1);
      setState(() {});
      print("Formatted Date: $formatted");
    }
  }
}
