import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/rooms/editroom.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class AddRoom extends StatefulWidget {
  final String centerid;

  AddRoom({required this.centerid});

  @override
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  late TextEditingController name, capacity, ageFrom, ageTo;
  String _chosenValue = 'Active';
  String roomError = '';
  String capacityError = '';
  String ageFromError = '';
  String ageToError = '';

  List<UserModel> users = [];
  List<UserModel> selectedEdu = [];
  Map<String, bool> eduValues = {};
  bool usersFetched = false;
  // int currentIndex=0;
//  int currentIndexEdu=0;

// create some values
  Color pickerColor = Color(0xff9320cc);
  Color currentColor = Color(0xff9320cc);

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void initState() {
    name = TextEditingController();
    capacity = TextEditingController();
    ageFrom = TextEditingController();
    ageTo = TextEditingController();
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    RoomAPIHandler handler =
        RoomAPIHandler({"userid": MyApp.LOGIN_ID_VALUE, "id": ''});
    var data = await handler.getRoomDetails();
    if (!data.containsKey('error')) {
      var r = data['users'];
      users = [];
      try {
        assert(r is List);
        //  UserModel u = UserModel(userid: '0', name: 'select');
        //  users.insert(0, u);
        for (int i = 0; i < r.length; i++) {
          users.add(UserModel.fromJson(r[i]));
          eduValues[users[i].userid] = false;
        }
        usersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  Widget getEndDrawer(BuildContext context) {
    return Drawer(
        child: Container(
            child: ListView(children: <Widget>[
      SizedBox(
        height: 5,
      ),
      ListTile(
        title: Text(
          'Select Educator',
          style: Constants.header2,
        ),
        trailing: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      ListView.builder(
          shrinkWrap: true,
          itemCount: users != null ? users.length : 0,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(users[index].name),
              trailing: Checkbox(
                  value: eduValues[users[index].userid],
                  onChanged: (value) {
                    if (value == true) {
                      if (!selectedEdu.contains(users[index])) {
                        selectedEdu.add(users[index]);
                      }
                    } else {
                      if (selectedEdu.contains(users[index])) {
                        selectedEdu.remove(users[index]);
                      }
                    }

                    eduValues[users[index].userid] = value ?? false;
                    setState(() {});
                  }),
            );
          }),
      SizedBox(
        height: 30,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Constants.kButton,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )),
          ),
          SizedBox(width: 30)
        ],
      ),
      SizedBox(
        height: 40,
      ),
    ])));
  }

  GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        endDrawer: getEndDrawer(context),
        appBar: Header.appBar(),
        body:
            //  _observation==null?SizedBox(
            //   height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       CircularProgressIndicator(
            //         color: Constants.kBlack,
            //       ),
            //     ],
            //   ),
            // ):
            SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: usersFetched
                        ? Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                Text(
                                  'Add Room',
                                  style: Constants.header1,
                                ),
                                SizedBox(height: 10),
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
                                Text(
                                  'Room Name',
                                  style: Constants.header2,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 16.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.grey)),
                                  child: TextField(
                                    controller: name,
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                        helperStyle:
                                            TextStyle(color: Colors.grey),
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        hintText: 'ex. Adventures',
                                        contentPadding: EdgeInsets.all(0),
                                        border: InputBorder.none),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                roomError != ''
                                    ? Text(
                                        roomError,
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Room Capacity',
                                  style: Constants.header2,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 16.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.grey)),
                                  child: TextField(
                                    controller: capacity,
                                    autofocus: false,
                                    keyboardType: TextInputType.number,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                        hintText: 'ex. 2',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        contentPadding: EdgeInsets.all(0),
                                        border: InputBorder.none),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                capacityError != ''
                                    ? Text(
                                        capacityError,
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Age From',
                                  style: Constants.header2,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 16.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.grey)),
                                  child: TextField(
                                    controller: ageFrom,
                                    autofocus: false,
                                    keyboardType: TextInputType.number,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                        hintText: 'ex. 2',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        contentPadding: EdgeInsets.all(0),
                                        border: InputBorder.none),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ageFromError != ''
                                    ? Text(
                                        ageFromError,
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Age To',
                                  style: Constants.header2,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 16.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Colors.grey)),
                                  child: TextField(
                                    controller: ageTo,
                                    autofocus: false,
                                    keyboardType: TextInputType.number,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                        hintText: 'ex. 2',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        contentPadding: EdgeInsets.all(0),
                                        border: InputBorder.none),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                ageToError != ''
                                    ? Text(
                                        ageToError,
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 5,
                                ),
                                // Text(
                                //   'Room Leader',
                                //   style: Constants.header2,
                                // ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                //      DropdownButtonHideUnderline(
                                //   child: Container(
                                //   height: 50,
                                //   width: MediaQuery.of(context).size.width,
                                //   decoration: BoxDecoration(
                                //              border: Border.all(color:Colors.grey),
                                //             color: Colors.white,
                                //             borderRadius: BorderRadius.all(Radius.circular(8))
                                //           ),
                                //  child: Padding(
                                //   padding: const EdgeInsets.only(left: 8,right: 8),
                                //   child: Center(
                                //    child:DropdownButton<String>(
                                //   isExpanded: true,
                                //   value: users[currentIndex].userid,
                                //   items: users.map((UserModel value) {
                                //        return new DropdownMenuItem<String>(
                                //               value: value.userid,
                                //               child: new Text(value.name),
                                //             );
                                //      }).toList(),
                                //    onChanged: (value) {
                                //         for(int i=0;i<users.length;i++){
                                //           if(users[i].userid == value){

                                //             setState(() {
                                //               currentIndex = i;
                                //             });
                                //             break;
                                //           }
                                //         }
                                //       },
                                // ),
                                //      ),
                                //     ),
                                //    ),
                                //   ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                // leaderError != ''
                                //     ? Text(
                                //         leaderError,
                                //         style: TextStyle(color: Colors.red),
                                //       )
                                //     : Container(),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                Text(
                                  'Room Status',
                                  style: Constants.header2,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                DropdownButtonHideUnderline(
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Center(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _chosenValue,
                                          items: <String>[
                                            'Active',
                                            'Inactive',
                                          ].map((String value) {
                                            return new DropdownMenuItem<String>(
                                              value: value,
                                              child: new Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _chosenValue = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Room Color',
                                  style: Constants.header2,
                                ),
                                SizedBox(
                                  height: 5,
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
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: currentColor,
                                              onColorChanged: changeColor,
                                              colorPickerWidth: 300.0,
                                              pickerAreaHeightPercent: 0.7,
                                              enableAlpha: true,
                                              displayThumbColor: true,
                                              showLabel: true,
                                              paletteType: PaletteType.hsv,
                                              pickerAreaBorderRadius:
                                                  const BorderRadius.only(
                                                topLeft:
                                                    const Radius.circular(2.0),
                                                topRight:
                                                    const Radius.circular(2.0),
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Choose'),
                                              onPressed: () {
                                                setState(() =>
                                                    currentColor = pickerColor);
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
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(left: 16.0),
                                    decoration: BoxDecoration(
                                        color: currentColor,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: Colors.grey)),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Educator',
                                  style: Constants.header2,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    key.currentState?.openEndDrawer();
                                  },
                                  child: Container(
                                      width: 160,
                                      height: 38,
                                      decoration: BoxDecoration(
                                          color: Constants.kButton,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Row(
                                        children: <Widget>[
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.add_circle,
                                              color: Colors.blue[100],
                                            ),
                                          ),
                                          Text(
                                            'Select Educator',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      )),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                selectedEdu.length > 0
                                    ? Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        children: List<Widget>.generate(
                                            selectedEdu.length, (int index) {
                                          return selectedEdu[index].userid !=
                                                  null
                                              ? Chip(
                                                  label: Text(
                                                      selectedEdu[index].name),
                                                  onDeleted: () {
                                                    setState(() {
                                                      eduValues[
                                                          selectedEdu[index]
                                                              .userid] = false;
                                                      selectedEdu
                                                          .removeAt(index);
                                                    });
                                                  })
                                              : Container();
                                        }))
                                    : Container(),
                                //      DropdownButtonHideUnderline(
                                //   child: Container(
                                //   height: 50,
                                //   width: MediaQuery.of(context).size.width,
                                //   decoration: BoxDecoration(
                                //              border: Border.all(color:Colors.grey),
                                //             color: Colors.white,
                                //             borderRadius: BorderRadius.all(Radius.circular(8))
                                //           ),
                                //  child: Padding(
                                //   padding: const EdgeInsets.only(left: 8,right: 8),
                                //   child: Center(
                                //    child:DropdownButton<String>(
                                //   isExpanded: true,
                                //   value: users[currentIndexEdu].userid,
                                //   items: users.map((UserModel value) {
                                //        return new DropdownMenuItem<String>(
                                //               value: value.userid,
                                //               child: new Text(value.name),
                                //             );
                                //      }).toList(),
                                //    onChanged: (value) {
                                //         for(int i=0;i<users.length;i++){
                                //           if(users[i].userid == value){

                                //             setState(() {
                                //               currentIndexEdu = i;
                                //             });
                                //             break;
                                //           }
                                //         }
                                //       },
                                // ),
                                //      ),
                                //     ),
                                //    ),
                                //   ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          print(currentColor
                                              .toString()
                                              .substring(
                                                  10,
                                                  currentColor
                                                          .toString()
                                                          .length -
                                                      1));
                                          // Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: 80,
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
                                          if (name.text.toString() == '') {
                                            roomError = 'Enter Room Name';
                                            setState(() {});
                                          } else if (capacity.text.toString() ==
                                              '') {
                                            roomError = '';
                                            capacityError = 'Enter Capacity';
                                            setState(() {});
                                          } else if (ageFrom.text.toString() ==
                                              '') {
                                            roomError = '';
                                            capacityError = '';
                                            ageFromError = 'Enter age';
                                            setState(() {});
                                          } else if (ageFrom.text.toString() ==
                                              '') {
                                            roomError = '';
                                            capacityError = '';
                                            ageFromError = '';
                                            ageToError = 'Enter age';
                                            setState(() {});
                                          }
                                          //  else if(currentIndex==0){
                                          //    roomError='';
                                          //    capacityError='';
                                          //     colorError='';
                                          //     leaderError='Choose Leader';
                                          //     setState((){});
                                          //  }
                                          else {
                                            roomError = '';
                                            capacityError = '';
                                            ageFromError = '';
                                            ageToError = '';
                                            setState(() {});
                                            String _toSend =
                                                Constants.BASE_URL +
                                                    'Room/createRoom';

                                            List edu = [];
                                            for (int i = 0;
                                                i < selectedEdu.length;
                                                i++) {
                                              edu.add(selectedEdu[i]
                                                  .userid
                                                  .toString());
                                            }
                                            var objToSend = {
                                              "centerid": widget.centerid,
                                              "userid": MyApp.LOGIN_ID_VALUE,
                                              "room_name": name.text.toString(),
                                              "room_capacity":
                                                  capacity.text.toString(),
                                              "ageFrom":
                                                  ageFrom.text.toString(),
                                              "ageTo": ageTo.text.toString(),
                                              // "room_leader": users[currentIndex].userid,
                                              "room_status": _chosenValue,
                                              "room_color": '#' +
                                                  parseColorToHex('#' +
                                                      currentColor
                                                          .toString()
                                                          .substring(
                                                              10,
                                                              currentColor
                                                                      .toString()
                                                                      .length -
                                                                  1)),
                                              "educators": edu,
                                            };
                                            print(jsonEncode(objToSend));
                                            final response = await http.post(
                                                Uri.parse(_toSend),
                                                body: jsonEncode(objToSend),
                                                headers: {
                                                  'X-DEVICE-ID': await MyApp
                                                      .getDeviceIdentity(),
                                                  'X-TOKEN':
                                                      MyApp.AUTH_TOKEN_VALUE,
                                                });
                                            print(response.body);
                                            if (response.statusCode == 200) {
                                              MyApp.ShowToast(
                                                  "Created", context);
                                              print('created');
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                            } else if (response.statusCode ==
                                                401) {
                                               MyApp.Show401Dialog(context);
                                            }
                                            setState(() {});
                                          }
                                        },
                                        child: Container(
                                            width: 60,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: Constants.kButton,
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
                                                    'SAVE',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                    ])
                              ]))
                        : Container())));
  }
}
