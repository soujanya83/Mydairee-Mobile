import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/rooms/addroom.dart';
import 'package:mykronicle_mobile/rooms/editroom.dart';
import 'package:mykronicle_mobile/rooms/roomdetails.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/hexconversion.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:http/http.dart' as http;

class RoomsList extends StatefulWidget {
  @override
  _RoomsListState createState() => _RoomsListState();
}

class _RoomsListState extends State<RoomsList> {
  String _chosenValue = 'Select';
  String searchString = '';
  List<RoomsModel> _rooms = [];
  List<UserModel> _users = [];
  bool roomsFetched = false;
  bool usersFetched = false;
  int currentIndex = 0;
  List<bool> checkValues = [];
  List statList = [];
  List<CentersModel> centers = [];
  bool centersFetched = false;
  var d;
  bool permissionAdd = false;
  bool permission = false;
  bool permissionDel = false;
  bool permissionupdate = false;

  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchData() async {
    RoomAPIHandler handler = RoomAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var data = await handler.getList();
    if ((data != null) && !data.containsKey('error')) {
      checkValues.clear();
      print(data['permissions']);
      if (data['permissions'] != null ||
          MyApp.USER_TYPE_VALUE == 'Superadmin') {
        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            data['permissions']['addRoom'] == '1') {
          permissionAdd = true;
        } else {
          permissionAdd = false;
        }

        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            data['permissions']['deleteRoom'] == '1') {
          permissionDel = true;
        } else {
          permissionDel = false;
        }

        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            data['permissions']['updateRoom'] == '1') {
          permissionupdate = true;
        } else {
          permissionupdate = false;
        }

        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            data['permissions']['viewRoom'] == '1') {
          print('HEE' + data['permission'].toString());
          var res = data['rooms'];
          _rooms = [];
          try {
            assert(res is List);
            for (int i = 0; i < res.length; i++) {
              List<ChildModel> childs = [];
              for (int j = 0; j < res[i]['childs'].length; j++) {
                ChildModel p = ChildModel.fromJson(res[i]['childs'][j]);
                childs.add(p);
              }
              RoomsDescModel roomDescModel = RoomsDescModel.fromJson(res[i]);
              _rooms.add(RoomsModel(child: childs, room: roomDescModel));
              checkValues.add(false);
            }
            permission = true;
            roomsFetched = true;
            if (this.mounted) setState(() {});
          } catch (e, s) {
            print(e);
            print(s);
          }
          var r = data['users'];
          _users = [];
          try {
            assert(r is List);
            for (int i = 0; i < r.length; i++) {
              _users.add(UserModel.fromJson(r[i]));
            }
            usersFetched = true;
            if (this.mounted) setState(() {});
          } catch (e, s) {
            print(e);
            print(s);
          }
        } else {
          MyApp.Show401Dialog(context);
        }
      } else {
        permission = false;
        permissionAdd = false;
        permissionDel = false;
        permissionupdate = false;
      }
    } else {
      permission = false;
      permissionAdd = false;
      permissionDel = false;
      permissionupdate = false;
    }
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    print('_fetchCenters api response');
    print(dt);
    if (!dt.containsKey('error')) {
      print(dt);
      var res = dt['Centers'];

      ///
      centers = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          centers.add(CentersModel.fromJson(res[i]));
        }
        centersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e, s) {
        print(e);
        print(s);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: floating(context),
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
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
                          if (permissionDel)
                            GestureDetector(
                                onTap: () async {
                                  if (statList.length > 0) {
                                    print(statList);
                                    var _toSend =
                                        Constants.BASE_URL + 'room/deleteRoom';
                                    var objToSend = {
                                      "userid": MyApp.LOGIN_ID_VALUE,
                                      "rooms": statList,
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
                                      setState(() {
                                        statList.clear();
                                        _rooms = [];
                                        _fetchData();
                                      });
                                      MyApp.ShowToast("deleted", context);
                                    } else if (response.statusCode == 401) {
                                      MyApp.Show401Dialog(context);
                                    }
                                  } else {
                                    MyApp.ShowToast("select rooms", context);
                                  }
                                },
                                child: Icon(
                                  AntDesign.delete,
                                  color: Constants.kMain,
                                )),
                          SizedBox(
                            width: 8,
                          ),
                          if (permissionAdd)
                            GestureDetector(
                              onTap: () {
                                if (_users != null && _users.length > 0) {
                                  print(_users);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddRoom(
                                              centerid:
                                                  centers[currentIndex].id)));
                                }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Constants.kButton,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    child: Text(
                                      ' +  Add',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
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
                        height: 5,
                      ),
                      if (centersFetched)
                        DropdownButtonHideUnderline(
                          child: Container(
                            height: 30,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: centers[currentIndex].id,
                                  items: centers.map((CentersModel value) {
                                    return new DropdownMenuItem<String>(
                                      value: value.id,
                                      child: new Text(value.centerName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    for (int i = 0; i < centers.length; i++) {
                                      if (centers[i].id == value) {
                                        setState(() {
                                          currentIndex = i;
                                          _rooms = [];
                                          _fetchData();
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
                      if (permission)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 3),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Constants.greyColor,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                                color: Colors.white,
                              ),
                              height: 30.0,
                              width: MediaQuery.of(context).size.width * 0.97,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                                child: TextFormField(
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.search),
                                    hintText:
                                        'Search by room name or child name',
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (text) {
                                    searchString = text;
                                    print(searchString);
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (permission)
                        DropdownButtonHideUnderline(
                          child: Container(
                            height: 30,
                            width: 120,
                            decoration: BoxDecoration(
                                border: Border.all(color: Constants.greyColor),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                  child: DropdownButton<String>(
                                isExpanded: true,
                                value: _chosenValue,
                                items: <String>['Select', 'Active', 'Inactive']
                                    .map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? value) async {
                                  setState(() {
                                    _chosenValue = value!;
                                  });
                                  if (_chosenValue == 'Select') {
                                    MyApp.ShowToast("choose status", context);
                                  } else if (statList.length > 0) {
                                    print(statList);
                                    var _toSend = Constants.BASE_URL +
                                        'room/changeStatus';
                                    var objToSend = {
                                      "userid": MyApp.LOGIN_ID_VALUE,
                                      "rooms": statList,
                                      "filter_status": _chosenValue,
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
                                      setState(() {
                                        statList.clear();
                                        _rooms = [];
                                        _fetchData();
                                      });
                                      MyApp.ShowToast("updated", context);
                                    } else if (response.statusCode == 401) {
                                      MyApp.Show401Dialog(context);
                                    }
                                  } else {
                                    MyApp.ShowToast("select rooms", context);
                                  }
                                },
                              )),
                            ),
                          ),
                        ),
                      if (!roomsFetched && permission)
                        Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Center(child: Text('Loading...'))],
                            )),
                      if (!permission)
                        Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                      "You don't have permission for this center"),
                                )
                              ],
                            )),
                      if (_rooms != null && _rooms.length != 0)
                        Container(
                          height:
                              _rooms.length != 0 ? _rooms.length * 150.0 : 0,
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _rooms.length,
                              itemBuilder: (BuildContext context, int index) {
                                return searchString == ''
                                    ? roomCard(_rooms[index], index)
                                    : _rooms[index]
                                            .room
                                            .name
                                            .toLowerCase()
                                            .contains(
                                                searchString.toLowerCase())
                                        ? roomCard(_rooms[index], index)
                                        : Container();
                              }),
                        ),
                      if (_rooms != null && _rooms.length == 0)
                        Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [Center(child: Text('No Rooms..'))],
                          ),
                        )
                    ])))));
  }

  Widget roomCard(RoomsModel r, int index) {
    Color _safeHexColor(String? color) {
      try {
        return HexColor(color ?? "#FFFFFF");
      } catch (e) {
        return HexColor("#FFFFFF"); // Default to white on error
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          child: Container(
            margin: const EdgeInsets.only(left: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RoomDetails(r.room.id)));
                        },
                        child: Text(
                          r.room.name,
                          style: Constants.cardHeadingStyle,
                        )),
                    Expanded(child: Container()),
                    if (permissionupdate)
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            if (_users != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditRoom(
                                            centerid: centers[currentIndex].id,
                                            roomid: r.room.id,
                                          )));
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ChildBasicDetails(
                              //               centerid: centers[currentIndex].id,
                              //               roomid: r.room.id,
                              //             )));
                            }
                          }),
                    Checkbox(
                      value: checkValues[index],
                      onChanged: (val) {
                        if (val == null) return;
                        checkValues[index] = val;
                        if (val == true) {
                          statList.add(r.room.id);
                        } else {
                          statList.remove(r.room.id);
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(Constants.KID_ICON),
                    SizedBox(
                      width: 10,
                    ),
                    Text(r.room.capacity != null ? r.room.capacity : '')
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Image.asset(Constants.LEAD_ICON),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      r.room.userName != null ? r.room.userName : '',
                      style: TextStyle(color: Constants.kMain),
                    ),
                    Text('(Lead)'),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          decoration: new BoxDecoration(
              gradient: new LinearGradient(stops: [
                0.02,
                0.02
              ], colors: [
                 _safeHexColor(r.room.color),
                Colors.white
              ]),
              borderRadius: new BorderRadius.all(const Radius.circular(6.0)))),
    );
  }
}
