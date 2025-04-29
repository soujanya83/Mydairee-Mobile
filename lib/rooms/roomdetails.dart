import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/rooms/addchildren.dart';
import 'package:mykronicle_mobile/rooms/childbasicdetails.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mykronicle_mobile/utils/removeTags.dart';

class RoomDetails extends StatefulWidget {
  final String id;
  RoomDetails(this.id);

  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  bool showGroup = false;
  bool showStatus = false;
  bool showGender = false;

  bool maleGender = false;
  bool femaleGender = false;
  bool otherGender = false;

  bool active = false;
  bool inactive = false;
  bool enrolled = false;

  Map<String, bool> groupValues = {};

  List<bool> checkValues = [];

  // var unescape = new HtmlUnescape();

  Widget getEndDrawer(BuildContext context) {
    return Drawer(
        child: Container(
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          ListTile(
            title: Text(
              'Apply Filters',
              style: Constants.header2,
            ),
            trailing: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              'Groups',
              style: Constants.header2,
            ),
            trailing: IconButton(
              icon: Icon(showGroup
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () {
                showGroup = !showGroup;
                setState(() {});
              },
            ),
          ),
          Visibility(
            visible: groupsData != null && showGroup,
            child: Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: groupsData != null ? groupsData.length : 0,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    String key = groupValues.keys.elementAt(index);
                    return CheckboxListTile(
                        title: Text(key),
                        value: groupValues[key],
                        onChanged: (value) {
                          for (int i = 0; i < groupsData.length; i++) {
                            if (groupsData[i]['name'] == key) {
                              if (value == true && groupValues[key] == false) {
                                groupValues[key] = true;

                                if (!groups.contains(groupsData[i]['id'])) {
                                  groups.add(groupsData[i]['id']);
                                }
                              } else if (value == false) {
                                groupValues[key] = false;

                                if (groups.contains(groupsData[i]['id'])) {
                                  groups.remove(groupsData[i]['id']);
                                }
                              }
                              break;
                            }
                          }

                          roomDetailFetched = false;
                          setState(() {});
                          _fetchFilterData();
                        });
                  }),
            ),
          ),
          ListTile(
            title: Text(
              'Status',
              style: Constants.header2,
            ),
            trailing: IconButton(
              icon: Icon(showStatus
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () {
                showStatus = !showStatus;
                setState(() {});
              },
            ),
          ),
          Visibility(
              visible: showStatus,
              child: Container(
                  child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                    ListTile(
                      trailing: Checkbox(
                          value: active,
                          onChanged: (value) {
                            if (value == true && active == false) {
                              active = true;

                              if (!status.contains('Active')) {
                                status.add('Active');
                              }
                            } else if (value == false) {
                              active = false;
                              if (status.contains('Active')) {
                                status.remove('Active');
                              }
                            }
                            roomDetailFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Active'),
                    ),
                    ListTile(
                      trailing: Checkbox(
                          value: inactive,
                          onChanged: (value) {
                            if (value == true && inactive == false) {
                              inactive = true;

                              if (!status.contains('In Active')) {
                                status.add('In Active');
                              }
                            } else if (value == false) {
                              inactive = false;
                              if (status.contains('In Active')) {
                                status.remove('In Active');
                              }
                            }
                            roomDetailFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('In Active'),
                    ),
                    ListTile(
                      trailing: Checkbox(
                          value: enrolled,
                          onChanged: (value) {
                            if (value == true && enrolled == false) {
                              enrolled = true;

                              if (!status.contains('Enrolled')) {
                                status.add('Enrolled');
                              }
                            } else if (value == false) {
                              enrolled = false;
                              if (status.contains('Enrolled')) {
                                status.remove('Enrolled');
                              }
                            }
                            roomDetailFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Enrolled'),
                    ),
                  ]))),
          ListTile(
            title: Text(
              'Gender',
              style: Constants.header2,
            ),
            trailing: IconButton(
              icon: Icon(showGender
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () {
                showGender = !showGender;
                setState(() {});
              },
            ),
          ),
          Visibility(
              visible: showGender,
              child: Container(
                  child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                    ListTile(
                      trailing: Checkbox(
                          value: maleGender,
                          onChanged: (value) {
                            if (value == true && maleGender == false) {
                              maleGender = true;

                              if (!gender.contains('Male')) {
                                gender.add('Male');
                              }
                            } else if (value == false) {
                              maleGender = false;
                              if (gender.contains('Male')) {
                                gender.remove('Male');
                              }
                            }
                            roomDetailFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Male'),
                    ),
                    ListTile(
                      trailing: Checkbox(
                          value: femaleGender,
                          onChanged: (value) {
                            if (value == true && femaleGender == false) {
                              femaleGender = true;

                              if (!gender.contains('Female')) {
                                gender.add('Female');
                              }
                            } else if (value == false) {
                              femaleGender = false;
                              if (gender.contains('Female')) {
                                gender.remove('Female');
                              }
                            }
                            roomDetailFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Female'),
                    ),
                    ListTile(
                      trailing: Checkbox(
                          value: otherGender,
                          onChanged: (value) {
                            if (value == true && otherGender == false) {
                              otherGender = true;

                              if (!gender.contains('Other')) {
                                gender.add('Other');
                              }
                            } else if (value == false) {
                              otherGender = false;
                              if (gender.contains('Other')) {
                                gender.remove('Other');
                              }
                            }
                            roomDetailFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Other'),
                    ),
                  ])))
        ],
      ),
    ));
  }

  GlobalKey<ScaffoldState> key = GlobalKey();
  RoomsDescModel? roomDesc;
  List<ChildModel> _allChildrens = [];
  bool roomDetailFetched = false;
  var d;
  List ids = [];
  List groups = [];
  List gender = [];
  List status = [];

  List groupsData = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    RoomAPIHandler handler =
        RoomAPIHandler({"userid": MyApp.LOGIN_ID_VALUE, "id": widget.id});
    var data = await handler.getRoomDetails();
    if (!data.containsKey('error')) {
      print(data);
      var res = data['room'];
      ids = [];
      checkValues = [];
      var child = data['roomChilds'];
      groupsData = data['groups'];
      _allChildrens = [];
      try {
        assert(child is List);
        for (int i = 0; i < child.length; i++) {
          _allChildrens.add(ChildModel.fromJson(child[i]));
          checkValues.add(false);
        }
        for (int i = 0; i < groupsData.length; i++) {
          groupValues[groupsData[i]['name']] = false;
        }
        roomDesc = RoomsDescModel.fromJson(res);
        roomDetailFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    RoomAPIHandler handler1 =
        RoomAPIHandler({"userid": MyApp.LOGIN_ID_VALUE, "roomid": widget.id});
    d = await handler1.getOtherList();
    print(d);
  }

  

  Future<void> _fetchFilterData() async {
    var _toSend = Constants.BASE_URL +
        'room/getRoomDetails/' +
        MyApp.LOGIN_ID_VALUE +
        '/' +
        widget.id;

    var objToSend = {
      "filter_groups": groups,
      "filter_status": status,
      "filter_gender": gender,
    };
    print(jsonEncode(objToSend));
    final response = await http
        .post(Uri.parse(_toSend), body: jsonEncode(objToSend), headers: {
      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
    });
    print(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      var res = data['room'];
      ids = [];
      checkValues = [];
      var child = data['roomChilds'];
      _allChildrens = [];
      try {
        assert(child is List);
        for (int i = 0; i < child.length; i++) {
          _allChildrens.add(ChildModel.fromJson(child[i]));
          checkValues.add(false);
        }
        roomDesc = RoomsDescModel.fromJson(res);
        roomDetailFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        endDrawer: getEndDrawer(context),
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: roomDetailFetched
                    ? Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            Row(
                              children: [
                                Text(
                                  'Rooms',
                                  style: Constants.header1,
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      key.currentState?.openEndDrawer();
                                    },
                                    child: Icon(
                                      Entypo.select_arrows,
                                      color: Constants.kButton,
                                    )),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddChildren(
                                                  id: roomDesc?.id ?? '',
                                                  type: 'add',
                                                  childid: '',
                                                )));
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
                                          ' +  Add Children',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      )),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Programming>'),
                                Text(
                                  'Rooms',
                                  style: TextStyle(color: Constants.kMain),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                Text(roomDesc?.name ?? ''),
                                Expanded(
                                  child: Container(),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Ionicons.ios_move,
                                      color: Constants.kMain,
                                    ),
                                    onPressed: () {
                                      if (ids.length == 0) {
                                        MyApp.ShowToast(
                                            "select children to move", context);
                                      } else if (d.containsKey('Rooms')) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Choose Room'),
                                                content: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  child: ListView.builder(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      itemCount:
                                                          d['Rooms'].length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Transform(
                                                          transform: Matrix4
                                                              .translationValues(
                                                                  0, 0.0, 0.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              List child = [];
                                                              for (var i = 0;
                                                                  i < ids.length;
                                                                  i++) {
                                                                child.add({
                                                                  "childid":
                                                                      ids[i],
                                                                  "roomid":
                                                                      d['Rooms']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'id'],
                                                                });
                                                              }

                                                              var _toSend = Constants
                                                                      .BASE_URL +
                                                                  'Children/moveChildren/';

                                                              var objToSend = {
                                                                "childid": ids,
                                                                "rooms": d[
                                                                        'Rooms']
                                                                    [
                                                                    index]['id'],
                                                                "children":
                                                                    child,
                                                                "userid": MyApp
                                                                    .LOGIN_ID_VALUE
                                                              };
                                                              print(jsonEncode(
                                                                  objToSend));
                                                              final response =
                                                                  await http.post(
                                                                      Uri.parse(
                                                                          _toSend),
                                                                      body: jsonEncode(
                                                                          objToSend),
                                                                      headers: {
                                                                    'X-DEVICE-ID':
                                                                        await MyApp
                                                                            .getDeviceIdentity(),
                                                                    'X-TOKEN': MyApp
                                                                        .AUTH_TOKEN_VALUE,
                                                                  });
                                                              print(response
                                                                  .body);
                                                              if (response
                                                                      .statusCode ==
                                                                  200) {
                                                                Navigator.pop(
                                                                    context);
                                                                roomDetailFetched =
                                                                    false;
                                                                setState(() {});
                                                                _fetchData();
                                                              } else if (response
                                                                      .statusCode ==
                                                                  401) {
                                                                MyApp.Show401Dialog(
                                                                    context);
                                                              }
                                                            },
                                                            child: ListTile(
                                                              title: Text(
                                                                  d['Rooms']
                                                                          [
                                                                          index]
                                                                      ['name']),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('ok'),
                                                  ),
                                                ],
                                              );
                                            });
                                      }
                                    }),
                                GestureDetector(
                                    onTap: () async {
                                      var _toSend = Constants.BASE_URL +
                                          'room/deleteRoom';
                                      var objToSend = {
                                        "userid": MyApp.LOGIN_ID_VALUE,
                                        "rooms": [widget.id],
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
                                        MyApp.ShowToast("deleted", context);
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      } else if (response.statusCode == 401) {
                                        MyApp.Show401Dialog(context);
                                      }
                                    },
                                    child: Icon(
                                      AntDesign.delete,
                                      color: Constants.kMain,
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  color: Constants.kContainer,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Room Capacity',
                                          style:
                                              Constants.containerHeadingStyle),
                                      Text(roomDesc?.capacity ?? '',
                                          style: Constants
                                              .containerNumberHeadingStyle)
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  color: Constants.kContainer,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Room Occupancy',
                                          style:
                                              Constants.containerHeadingStyle),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text('M'),
                                              Text(roomDesc?.occupancy['Mon']
                                                      .toString() ??
                                                  '')
                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            children: [
                                              Text('T'),
                                              Text(roomDesc?.occupancy['Tue']
                                                      .toString() ??
                                                  '')
                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            children: [
                                              Text('W'),
                                              Text(roomDesc?.occupancy['Wed']
                                                      .toString() ??
                                                  '')
                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            children: [
                                              Text('T'),
                                              Text(roomDesc?.occupancy['Thu']
                                                      .toString() ??
                                                  '')
                                            ],
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            children: [
                                              Text('F'),
                                              Text(roomDesc?.occupancy['Fri']
                                                      .toString() ??
                                                  '')
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  color: Constants.kContainer,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Room Vacancy',
                                          style:
                                              Constants.containerHeadingStyle),
                                      Text(
                                          (int.parse(roomDesc?.capacity ??
                                                      '0') -
                                                  _allChildrens.length)
                                              .toString(),
                                          style: Constants
                                              .containerNumberHeadingStyle)
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  color: Constants.kContainer,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Active Children',
                                          style:
                                              Constants.containerHeadingStyle),
                                      Text(_allChildrens.length.toString(),
                                          style: Constants
                                              .containerNumberHeadingStyle)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _allChildrens.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return childCards(index);
                                  }),
                            )
                          ]))
                    : Container())));
  }

  Widget childCards(int i) {
    var inputFormat = DateFormat("yyyy-MM-dd");

    DateTime date1 = inputFormat.parse(_allChildrens[i].dob ?? '');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      backgroundImage: _allChildrens[i].imageUrl != '' &&
                              _allChildrens[i].imageUrl != null
                          ? NetworkImage(Constants.ImageBaseUrl +
                              _allChildrens[i].imageUrl)
                          : null),
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 150,
                        child: Row(
                          children: [
                            Text(_allChildrens[i].name,
                                style: Constants.cardHeadingStyle),
                            Spacer(),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChildBasicDetails(
                                                roomid: roomDesc?.id ?? '',
                                                childid: _allChildrens[i].id,
                                                centerid: '',
                                              ))).then((value) {
                                    if (value != null) {
                                      roomDetailFetched = false;
                                      setState(() {});
                                      _fetchFilterData();
                                    }
                                  });
                                },
                                child: Icon(Icons.edit)),
                            checkValues != null
                                ? Checkbox(
                                    value: checkValues[i],
                                    onChanged: (val) {
                                      if (val == null) return;
                                      checkValues[i] = val;
                                      if (val == true) {
                                        ids.add(_allChildrens[i].id);
                                      } else {
                                        if (ids.contains(_allChildrens[i].id)) {
                                          ids.remove(_allChildrens[i].id);
                                        }
                                      }
                                      setState(() {});
                                    },
                                  )
                                : Container()
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(
                            width: 10,
                          ),
                          Text(calculateAge(date1).toString() + ' years')
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: _allChildrens[i].recentobs != null
                                ? tagRemove(
                                    _allChildrens[i].recentobs?['title'],
                                    'heading',
                                    '',
                                    context)
                                : Text('No Recent Obs'),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                color: Constants.greyColor,
                height: 1,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('Published'),
                      SizedBox(
                        height: 3,
                      ),
                      Text(_allChildrens[i].pub.toString())
                    ],
                  ),
                  Container(
                    height: 35,
                    width: 1,
                    color: Constants.greyColor,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Un Published'),
                      SizedBox(
                        height: 3,
                      ),
                      Text(_allChildrens[i].draft.toString())
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}
