import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/programplanapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/observationmodel.dart';
import 'package:mykronicle_mobile/models/qiplistmodel.dart';
import 'package:mykronicle_mobile/models/reflectionmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/hexconversion.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';
import 'package:http/http.dart' as http;

class AddPlan extends StatefulWidget {
  final String type;
  final String centerid;
  final String planId;

  AddPlan(this.type, this.centerid, this.planId);

  @override
  _AddPlanState createState() => _AddPlanState();
}

class _AddPlanState extends State<AddPlan> {
  String _date1='';
  String date1='';

  String _date2='';
  String date2='';

  int roomIndex = 0;

  List<RoomData> roomData = [];

  List<UserData> userData = [];

  List<UserData> selectedUsers = [];
  List<TextEditingController> headController = [];

  List<Color> pickerColor = [];
  List<Color> currentColor = [];
  GlobalKey<State<StatefulWidget>> keyEditor = GlobalKey();
  HtmlEditorController editorController = HtmlEditorController();
  List headComment = [];

  // var unescape = HtmlUnescape();

  bool observationsFetched = false;
  List<ObservationModel> _allObservations=[];

  bool qipsFetched = false;
  List<QipListModel> _allQips=[];

  bool refsFetched = false;
  List<ReflectionModel> _allReflections=[];

  @override
  void initState() {
    _load();
    super.initState();
  }

  void _load() async {
    var _objToSend = {
      'usertype': MyApp.USER_TYPE_VALUE,
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': widget.centerid,
    };

    ProgramPlanApiHandler apiHandler = ProgramPlanApiHandler(_objToSend);
    var data = await apiHandler.planSupport();

    roomData = [];
    var rData = data['room'];
    var ids = rData.keys.toList();
    var titles = rData.values.toList();
    for (int i = 0; i < rData.length; i++) {
      roomData.add(RoomData(id: ids[i], title: titles[i]));
    }

    var uData = data['users'];
    var uids = uData.keys.toList();
    var unames = uData.values.toList();
    userData = [];
    for (int i = 0; i < uData.length; i++) {
      userData.add(UserData(userid: uids[i], name: unames[i]));
    }
    ProgramPlanApiHandler apiHandler2 = ProgramPlanApiHandler({});
    var obsLink = await apiHandler2.getObsLinks(roomData[roomIndex].id);
    var resObs = obsLink['observations'];
    _allObservations = [];
    print('here');
    print(resObs);
    try {
      assert(resObs is List);
      for (int i = 0; i < resObs.length; i++) {
        _allObservations.add(ObservationModel.fromJson(resObs[i]));
      }
      observationsFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
    var refLink = await apiHandler2.getRefLinks(roomData[roomIndex].id);
    var resRef = refLink['reflections'];
    _allReflections = [];
    try {
      assert(resRef is List);
      for (int i = 0; i < resRef.length; i++) {
        _allReflections.add(ReflectionModel.fromJson(resRef[i]));
      }
      refsFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
    var qipLink = await apiHandler2.getQipLinks(roomData[roomIndex].id);
    var resQip = qipLink['qip'];
    _allQips = [];
    try {
      assert(resQip is List);
      for (int i = 0; i < resQip.length; i++) {
        _allQips.add(QipListModel.fromJson(resQip[i]));
      }
      qipsFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
    if (widget.type == 'edit') {
      var _objToSend = {
        "created": MyApp.LOGIN_ID_VALUE,
        "usertype": MyApp.USER_TYPE_VALUE,
        "userid": MyApp.LOGIN_ID_VALUE,
        "centerid": widget.centerid,
        "programid": widget.planId
      };

      ProgramPlanApiHandler apiHandler = ProgramPlanApiHandler(_objToSend);
      var data = await apiHandler.getDetails();
      _date1 = data['get_details']['programlist']['startdate'];
      date1 = DateFormat('dd/MM/yyyy').format(
          DateTime.parse(data['get_details']['programlist']['startdate']));
      _date2 = data['get_details']['programlist']['enddate'];
      date2 = DateFormat('dd/MM/yyyy').format(
          DateTime.parse(data['get_details']['programlist']['enddate']));
      // room id getting
      int x = roomData.indexWhere((element) =>
          element.id == data['get_details']['programlist']['room_id']);
      roomIndex = x;
      //
      var userList = data['get_details']['programusers'];

      selectedUsers = [];
      for (int i = 0; i < userList.length; i++) {
        //  selectedUsers
        selectedUsers.add(
            UserData(userid: userList[i]['userid'], name: userList[i]['name']));
      }

      var headersList = data['get_details']['programheader'];
      headController.clear();
      currentColor.clear();
      pickerColor.clear();
      editorController.clear();
      headComment.clear();
      for (int i = 0; i < headersList.length; i++) {
        headController
            .add(TextEditingController(text: headersList[i]['headingname']));
        currentColor.add(HexColor(headersList[i]['headingcolor']));
        pickerColor.add(HexColor(headersList[i]['headingcolor']));
        // editorController.editorController.add(GlobalKey());
        headComment.add(headersList[i]['perhaps']);
      }

      print('heyeyeh' + x.toString());
    }
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Add Program Plan',
                            style: Constants.header1,
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Start Date',
                        style: Constants.header2,
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          _selectStartDate(context);
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.grey)),
                          child: ListTile(
                              title: Text(_date1 != null ? date1 : ''),
                              trailing: Icon(Icons.calendar_today)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'End Date',
                        style: Constants.header2,
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          _selectEndDate(context);
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.grey)),
                          child: ListTile(
                              title: Text(_date2 != null ? date2 : ''),
                              trailing: Icon(Icons.calendar_today)),
                        ),
                      ),
                      if (roomData != null && roomData.length > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Room',
                              style: Constants.header2,
                            ),
                            SizedBox(
                              height: 4,
                            ),
   // hereedvb
                            DropdownButtonHideUnderline(
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black54),
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Center(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: roomData[roomIndex].id,
                                      items: roomData.map((RoomData value) {
                                        return new DropdownMenuItem<String>(
                                          value: value.id,
                                          child: new Text(value.title??''),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        for (int i = 0;
                                            i < roomData.length;
                                            i++) {
                                          if (roomData[i].id == value) {
                                            setState(() {
                                              roomIndex = i;
                                            });
                                            break;
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: ElevatedButton(
                                  child: Text('Select Educators'),
                                  onPressed: () {
                                    getDialog(context).then((val) {
                                      setState(() {});
                                    });
                                  }),
                            ),
                            selectedUsers.length > 0
                                ? Wrap(
                                    spacing: 8.0, // gap between adjacent chips
                                    runSpacing: 4.0, // gap between lines
                                    children: List<Widget>.generate(
                                        selectedUsers.length, (int index) {
                                      return selectedUsers[index] != null
                                          ? Chip(
                                              label: Text(
                                                  selectedUsers[index].name??''),
                                              onDeleted: () {
                                                setState(() {
                                                  selectedUsers.removeAt(index);
                                                });
                                              })
                                          : Container();
                                    }))
                                : Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      if (observationsFetched &&
                                          _allObservations.length > 0) {
                                        showGeneralDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          pageBuilder:
                                              (BuildContext buildContext,
                                                  Animation<double> animation,
                                                  Animation<double>
                                                      secondaryAnimation) {
                                            return StatefulBuilder(
                                                builder: (context, setState) {
                                              Size size =
                                                  MediaQuery.of(context).size;
                                              return Scaffold(
                                                appBar: AppBar(
                                                  centerTitle: true,
                                                  title:
                                                      Text("Link Observation"),
                                                ),
                                                body: SingleChildScrollView(
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                _allObservations
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        3.0),
                                                                child: Card(
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              size.width,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Container(
                                                                                  width: size.width * 0.8,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                                                                                    child: Text(
                                                                                      _allObservations[index].title,
                                                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  )),
                                                                              Checkbox(
                                                                                  value: _allObservations[index].boolCheck,
                                                                                  onChanged: (val) {
                                                                                    _allObservations[index].boolCheck = val!;
                                                                                    setState(() {});
                                                                                  })
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        _allObservations[index].observationsMedia == 'null' ||
                                                                                _allObservations[index].observationsMedia == ''
                                                                            ? Text('')
                                                                            : _allObservations[index].observationsMediaType == 'Image'
                                                                                ? Image.network(
                                                                                    Constants.ImageBaseUrl + _allObservations[index].observationsMedia,
                                                                                    height: 150,
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    fit: BoxFit.fill,
                                                                                  )
                                                                                : VideoItem(url: Constants.ImageBaseUrl + _allObservations[index].observationsMedia),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Text(
                                                                                    'Author: ',
                                                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                  Text(_allObservations[index].userName)
                                                                                ],
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    'Date: ',
                                                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                  Text(_allObservations[index].dateAdded)
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                      'Save'))
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                        );
                                      }
                                    },
                                    child: Text('Link Observation')),
                                ElevatedButton(
                                    onPressed: () {
                                      if (refsFetched &&
                                          _allReflections.length > 0) {
                                        showGeneralDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          pageBuilder:
                                              (BuildContext buildContext,
                                                  Animation<double> animation,
                                                  Animation<double>
                                                      secondaryAnimation) {
                                            return StatefulBuilder(
                                                builder: (context, setState) {
                                              Size size =
                                                  MediaQuery.of(context).size;
                                              return Scaffold(
                                                appBar: AppBar(
                                                  centerTitle: true,
                                                  title:
                                                      Text("Link Reflection"),
                                                ),
                                                body: SingleChildScrollView(
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                _allReflections
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        3.0),
                                                                child: Card(
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              size.width,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Container(
                                                                                  width: size.width * 0.8,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                    child: Text(
                                                                                      _allReflections[index].title,
                                                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  )),
                                                                              Checkbox(
                                                                                  value: _allReflections[index].boolCheck,
                                                                                  onChanged: (val) {
                                                                                    _allReflections[index].boolCheck = val!;
                                                                                    setState(() {});
                                                                                  })
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              8,
                                                                              0,
                                                                              8,
                                                                              8),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Text(
                                                                                    'Created By: ',
                                                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                  Text(_allReflections[index].createdBy)
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 12,
                                                                              ),
                                                                              Text(
                                                                                _allReflections[index].about,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              8,
                                                                              0,
                                                                              8,
                                                                              12),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                'Status: ',
                                                                                style: TextStyle(fontWeight: FontWeight.w600),
                                                                              ),
                                                                              Text(_allReflections[index].status)
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                      'Save'))
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                        );
                                      }
                                    },
                                    child: Text('Link Reflection')),
                                ElevatedButton(
                                    onPressed: () {
                                      if (qipsFetched && _allQips.length > 0) {
                                        showGeneralDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          pageBuilder:
                                              (BuildContext buildContext,
                                                  Animation<double> animation,
                                                  Animation<double>
                                                      secondaryAnimation) {
                                            return StatefulBuilder(
                                                builder: (context, setState) {
                                              Size size =
                                                  MediaQuery.of(context).size;
                                              return Scaffold(
                                                appBar: AppBar(
                                                  centerTitle: true,
                                                  title: Text("Link Qips"),
                                                ),
                                                body: SingleChildScrollView(
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                _allQips.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        3.0),
                                                                child: Card(
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              size.width,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Container(
                                                                                  width: size.width * 0.8,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                                                                                    child: Text(
                                                                                      _allQips[index].qipName,
                                                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  )),
                                                                              Checkbox(
                                                                                  value: _allQips[index].boolCheck,
                                                                                  onChanged: (val) {
                                                                                    _allQips[index].boolCheck = val!;
                                                                                    setState(() {});
                                                                                  })
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              8,
                                                                              0,
                                                                              8,
                                                                              8),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Text(
                                                                                    'Created By: ',
                                                                                    style: TextStyle(fontWeight: FontWeight.w600),
                                                                                  ),
                                                                                  Text(_allQips[index].createdBy)
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 12,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.fromLTRB(
                                                                              8,
                                                                              0,
                                                                              8,
                                                                              12),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Text(
                                                                                'Date: ',
                                                                                style: TextStyle(fontWeight: FontWeight.w600),
                                                                              ),
                                                                              Text(_allQips[index].createdAt)
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                      'Save'))
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                        );
                                      }
                                    },
                                    child: Text('Link Qip')),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.type == 'edit')
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Constants.greyColor)),
                                        onPressed: () {
                                          List headText = [];

                                          for (int i = 0;
                                              i < headController.length;
                                              i++) {
                                            headText
                                                .add(headController[i].text);
                                          }
                                          showGeneralDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            pageBuilder:
                                                (BuildContext buildContext,
                                                    Animation<double> animation,
                                                    Animation<double>
                                                        secondaryAnimation) {
                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                return Scaffold(
                                                  appBar: AppBar(
                                                    centerTitle: true,
                                                    title: Text("Priority"),
                                                  ),
                                                  body: SingleChildScrollView(
                                                    child: Container(
                                                      child: Column(
                                                        children: [
                                                          ReorderableListView(
                                                              shrinkWrap: true,
                                                              children: [
                                                                for (final item
                                                                    in headText)
                                                                  Card(
                                                                    key: ValueKey(
                                                                        item),
                                                                    child:
                                                                        ListTile(
                                                                      title: Text(
                                                                          item),
                                                                      trailing:
                                                                          Icon(Icons
                                                                              .filter),
                                                                    ),
                                                                  )
                                                              ],
                                                              onReorder:
                                                                  (oldindex,
                                                                      newindex) {
                                                                setState(() {
                                                                  if (newindex >
                                                                      oldindex) {
                                                                    newindex -=
                                                                        1;
                                                                  }
                                                                  final items =
                                                                      headText.removeAt(
                                                                          oldindex);
                                                                  headText.insert(
                                                                      newindex,
                                                                      items);
                                                                });
                                                              }),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      saveData(
                                                                          headText,
                                                                          true);
                                                                    },
                                                                    child: Text(
                                                                        'Save'))
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                            },
                                          );
                                        },
                                        child: Text(
                                          'Priority',
                                          style: TextStyle(color: Colors.black),
                                        )),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Constants.greyColor)),
                                      onPressed: () {
                                        headController
                                            .add(TextEditingController());
                                        currentColor.add(Color(0xff9320cc));
                                        pickerColor.add(Color(0xff9320cc));
                                        // editorController.editorController.add(GlobalKey());
                                        headComment.add('');

                                        setState(() {});
                                      },
                                      child: Text(
                                        '+ Add Heading',
                                        style: TextStyle(color: Colors.black),
                                      ))
                                ],
                              ),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: headController.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Heading',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder()),
                                          controller: headController[index],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          'Heading Color',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  titlePadding:
                                                      const EdgeInsets.all(0.0),
                                                  contentPadding:
                                                      const EdgeInsets.all(0.0),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: ColorPicker(
                                                      pickerColor:
                                                          currentColor[index],
                                                      onColorChanged:
                                                          (Color color) {
                                                        setState(() =>
                                                            pickerColor[index] =
                                                                color);
                                                      },
                                                      colorPickerWidth: 300.0,
                                                      pickerAreaHeightPercent:
                                                          0.7,
                                                      enableAlpha: true,
                                                      displayThumbColor: true,
                                                      showLabel: true,
                                                      paletteType:
                                                          PaletteType.hsv,
                                                      pickerAreaBorderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft: const Radius
                                                            .circular(2.0),
                                                        topRight: const Radius
                                                            .circular(2.0),
                                                      ),
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      child:
                                                          const Text('Choose'),
                                                      onPressed: () {
                                                        setState(() =>
                                                            currentColor =
                                                                pickerColor);
                                                        print(currentColor);
                                                        print('#' +
                                                            currentColor
                                                                .toString()
                                                                .substring(
                                                                    10,
                                                                    currentColor
                                                                            .toString()
                                                                            .length -
                                                                        1));
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 50,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            decoration: BoxDecoration(
                                                color: currentColor[index],
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                border: Border.all(
                                                    color: Colors.grey)),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Html(
                                            data: parseFragment(headComment[index]).text),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        HtmlEditor(
                                          controller: editorController, 
                                          key: keyEditor,
                                          // height: MediaQuery.of(context)
                                          //         .size
                                          //         .height *
                                          //     0.35,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  final txt1 =
                                                      await editorController.getText();
                                                  String s = txt1;

                                                  if (headComment[index] ==
                                                      '') {
                                                    headComment[index] = s;
                                                  } else {
                                                    headComment[index] =
                                                        headComment[index] +
                                                            '<br><br> $s';
                                                  }
                                                  editorController
                                                      .setText('');
                                                  setState(() {});
                                                },
                                                child: Text('Add'))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ));
                                }),
                            if (headController.length > 0)
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if (_date1 == null) {
                                        MyApp.ShowToast(
                                            'Enter start date', context);
                                      } else if (_date2 == null) {
                                        MyApp.ShowToast(
                                            'Enter end date', context);
                                      } else {
                                        List headText = [];

                                        for (int i = 0;
                                            i < headController.length;
                                            i++) {
                                          headText.add(headController[i].text);
                                        }
                                        saveData(headText, false);
                                      }
                                    },
                                    child: Text('Submit')),
                              )
                          ],
                        )
                    ])))));
  }

  void saveData(List priorityText, bool priorityClick) async {
    var priority = {};

    for (int i = 0; i < priorityText.length; i++) {
      priority[priorityText[i]] = i + 1;
    }

    print(priority);

    var obslinkIds = [];
    for (int i = 0; i < _allObservations.length; i++) {
      if (_allObservations[i].boolCheck) {
        obslinkIds.add(_allObservations[i].id);
      }
    }
    var reflinkIds = [];
    for (int i = 0; i < _allReflections.length; i++) {
      if (_allReflections[i].boolCheck) {
        reflinkIds.add(_allReflections[i].id);
      }
    }

    var qiplinkIds = [];
    for (int i = 0; i < _allQips.length; i++) {
      if (_allQips[i].boolCheck) {
        qiplinkIds.add(_allQips[i].id);
      }
    }

    var eduIds = [];
    for (int i = 0; i < selectedUsers.length; i++) {
      eduIds.add(selectedUsers[i].userid);
    }

    var headList = [];
    for (int i = 0; i < headController.length; i++) {
      headList.add({
        "heading_name": headController[i].text,
        "heading_color": '#' +
            currentColor[i]
                .toString()
                .substring(10, currentColor[i].toString().length - 1),
        "content": headComment[i]
      });
    }

    var _objToSend = {
      "room_id": roomData[roomIndex].id,
      "startdate": _date1,
      "enddate": _date2,
      "observation": obslinkIds,
      "reflection": reflinkIds,
      "qip": qiplinkIds,
      "head_details": headList,
      "educators": eduIds,
      "userid": MyApp.LOGIN_ID_VALUE,
      "centerid": widget.centerid
    };

    if (widget.type == 'edit') {
      _objToSend['edit_id'] = widget.planId;
      _objToSend['priority'] = priority;
    }

    var _toSend = Constants.BASE_URL + 'Programplanlist/saveprogramplandetails';

    print(jsonEncode(_objToSend));
    final response =
        await http.post(Uri.parse(_toSend), body: jsonEncode(_objToSend), headers: {
      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
    });
    print('hee');
    print(response.body);
    print('kkkk');
    if (response.statusCode == 200) {
      if (priorityClick) {
        _load();
        MyApp.ShowToast("modified", context);
        Navigator.pop(context, 'kill');
      } else {
        MyApp.ShowToast("added", context);
        Navigator.pop(context, 'kill');
      }
    } else if (response.statusCode == 401) {
      MyApp.Show401Dialog(context);
    }
  }

  _selectStartDate(BuildContext context) async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1930),
    lastDate: DateTime(2050),
    builder: (BuildContext context, Widget? child) { // ✅ child should be nullable (Widget?)
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Theme.of(context).primaryColor,
          colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
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
    final String date = outputFormat.format(date1);

    print("Formatted Date: $formatted");
  }
}

  _selectEndDate(BuildContext context) async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1930),
    lastDate: DateTime(2050),
    builder: (BuildContext context, Widget? child) { // ✅ child should be nullable (Widget?)
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Theme.of(context).primaryColor,
          colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
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
    final String date = outputFormat.format(date1);

    print("Formatted Date: $formatted");
  }
}

  getDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: 520,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 4, 4, 4),
                        child: Text(
                          'Select Educators',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 400,
                        child: ListView.builder(
                            shrinkWrap: true,
                            // physics: NeverScrollableScrollPhysics(),
                            itemCount: userData.length,
                            itemBuilder: (context, index) {
                              return CheckboxListTile(
                                value: selectedUsers.contains(userData[index]),
                                onChanged: (val) {
                                  if (val == true) {
                                    selectedUsers.add(userData[index]);
                                  } else {
                                    selectedUsers.remove(userData[index]);
                                  }
                                  setState(() {});
                                },
                                title: Text(userData[index].name??''),
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}

class RoomData {
  String? id;
  String? title;

  RoomData({this.id, this.title});
}

class UserData {
  String? userid;
  String? name;

  UserData({this.userid, this.name});
}
