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
    if (this.mounted)
      setState(() {
        roomsFetched = false;
      });
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

    roomsFetched = true;
    if (this.mounted)
    setState(() {});
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

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Items?"),
          content: const Text("This action cannot be undone."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete"),
              onPressed: () async {
                try {
                  final response = await http.post(
                    Uri.parse("${Constants.BASE_URL}room/deleteRoom"),
                    body: jsonEncode({
                      "userid": MyApp.LOGIN_ID_VALUE,
                      "rooms": statList,
                      "centerid": centers[currentIndex].id
                    }),
                    headers: {
                      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                    },
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      statList.clear();
                      _rooms = [];
                      _fetchData();
                    });
                    MyApp.ShowToast("Deleted successfully", context);
                  } else if (response.statusCode == 401) {
                    MyApp.ShowToast(
                      jsonDecode(response.body)['Message'].toString(),
                      context,
                    );
                  }
                } catch (e) {
                  debugPrint('Delete error: $e');
                  MyApp.ShowToast("Deletion failed", context);
                }
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: floating(context),
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: !centersFetched
            ? SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Constants.kBlack,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
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
                                        showDeleteConfirmationDialog(context);
                                      } else {
                                        MyApp.ShowToast(
                                            "select rooms", context);
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
                                  onTap: () async{
                                    if (_users != null && _users.length > 0) {
                                      print(_users);
                                    await  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AddRoom(
                                                  centerid:
                                                      centers[currentIndex]
                                                          .id)));
                                      _fetchData();
                                    }
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
                                          ' +  Add',
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
                            height: 5,
                          ),
                          if (centersFetched)
                            DropdownButtonHideUnderline(
                              child: Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Constants.greyColor),
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
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
                                        for (int i = 0;
                                            i < centers.length;
                                            i++) {
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
                          // if (permission)
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
                                height: 40.0,
                                width: MediaQuery.of(context).size.width * 0.97,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0),
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 10),
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
                          SizedBox(
                            height: 5,
                          ),
                          // if (permission)
                          DropdownButtonHideUnderline(
                            child: Container(
                              height: 30,
                              width: 120,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Constants.greyColor),
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Center(
                                    child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _chosenValue,
                                  items: <String>[
                                    'Select',
                                    'Active',
                                    'Inactive'
                                  ].map((String value) {
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
                                height: MediaQuery.of(context).size.height * .7,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator())),
                                  ],
                                )),
                          if (!permission && roomsFetched)
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
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
                              height: _rooms.length != 0
                                  ? _rooms.length * 160.0
                                  : 0,
                              child: ListView.builder( 
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _rooms.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
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
                          if (_rooms.length == 0 && roomsFetched && permission)
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
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3), // Bottom shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _safeHexColor(r.room.color),
                  Colors.white,
                ],
                stops: [0.02, 0.02],
              ),
            ),
            child: Column(
              children: [
                // Room Name and Icons
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
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
                          style: Constants.cardHeadingStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Spacer(),
                      if (permissionupdate)
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: ()async {
                            if (_users != null) {
                             await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditRoom(
                                            centerid: centers[currentIndex].id,
                                            roomid: r.room.id,
                                          )));

                                  _fetchData();
                            }
                          },
                        ),
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
                ),
                // Child Count Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Image.asset(Constants.KID_ICON),
                      SizedBox(width: 8),
                      Text(
                        r.child.isNotEmpty ? r.child.length.toString() : '0',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Lead Name Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Image.asset(Constants.LEAD_ICON),
                      SizedBox(width: 8),
                      Text(
                        r.room.userName ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Constants.kMain,
                        ),
                      ),
                      Text(' (Lead)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
