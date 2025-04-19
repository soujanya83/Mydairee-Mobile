import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/hexconversion.dart';

class EditRoom extends StatefulWidget {
  final String centerid;
  final String roomid;

  EditRoom({required this.centerid, required this.roomid});

  @override
  _EditRoomState createState() => _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  TextEditingController? name, capacity, ageFrom, ageTo;
  String _chosenValue = 'Active';
  String roomError = '';
  String capacityError = '';

  String ageFromError = '';
  String ageToError = '';

  bool roomDetailsFetched = false;
  RoomsDescModel? roomDesc;
  bool usersFetched = false;

  List<UserModel> users = [];

  // int currentIndex = 0;
  // int currentIndexEdu = 0;
  List<UserModel> selectedEdu = [];
  Map<String, bool> eduValues = {};

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
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: users != null ? users.length : 0,
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

                    eduValues[users[index].userid] = value!;
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

  Future<void> _fetchData() async {
    RoomAPIHandler handler =
        RoomAPIHandler({"userid": MyApp.LOGIN_ID_VALUE, "id": widget.roomid});
    var data = await handler.getRoomDetails();
    if (!data.containsKey('error')) {
      var r = data['users'];
      users = [];
      try {
        assert(r is List);
        for (int i = 0; i < r.length; i++) {
          users.add(UserModel.fromJson(r[i]));
          eduValues[users[i].userid] = false;
        }
        usersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e, s) {
        print('first time error');
        print(e);
        print(s);
      }

      print(data);
      var res = data['room'];
      print('roomsdd' + data['roomStaff'].toString());
      try {
        roomDesc = RoomsDescModel.fromJson(res);
        name?.text = roomDesc?.name ?? '';
        capacity?.text = roomDesc?.capacity ?? '';
        _chosenValue = roomDesc?.status ?? '';
        ageFrom?.text = roomDesc?.ageFrom ?? '';
        ageTo?.text = roomDesc?.ageTo ?? '';
        // currentIndex = users.indexWhere((element) {
        //   print(element.userid);
        //   print(roomDesc.userId);
        //   return element.userid == roomDesc.userId;
        // });
        // print('niii' + currentIndex.toString());
        // if (currentIndex == -1) {
        //   currentIndex = 0;
        // }
        for (int i = 0; i < data['roomStaff'].length; i++) {
          // selectedEdu.add(UserModel(
          //   userid: data['roomStaff'][i]['userId'],
          //   name: data['roomStaff'][i]['userName'],
          // ));
          var sel = users.where(
              (element) => element.userid == data['roomStaff'][i]['userId']);
          if (sel.isNotEmpty) {
            selectedEdu.add(sel.first);
          }
          try {
            eduValues[selectedEdu[i].userid] = true;
          } catch (e, s) {
            print(e);
            print(s);
          }
        }
        try {
          pickerColor = HexColor(roomDesc?.color ?? '');
          currentColor = HexColor(roomDesc?.color ?? '');
        } catch (e) {
          print(e);
        }
        roomDetailsFetched = true;
        if (this.mounted) setState(() {});
      } catch (e, s) {
        print('second time error');
        print(e);
        print(s);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  GlobalKey<ScaffoldState> key = GlobalKey();

  Widget roomeditui() {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: roomDetailsFetched
              ? Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      Text(
                        'Edit Room',
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
                              helperStyle: TextStyle(color: Colors.grey),
                              hintStyle: TextStyle(color: Colors.grey[500]),
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
                              hintStyle: TextStyle(color: Colors.grey[500]),
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
                              hintStyle: TextStyle(color: Colors.grey[500]),
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
                              hintStyle: TextStyle(color: Colors.grey[500]),
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
                      // if (usersFetched)
                      //   DropdownButtonHideUnderline(
                      //     child: Container(
                      //       height: 50,
                      //       width: MediaQuery.of(context).size.width,
                      //       decoration: BoxDecoration(
                      //           border: Border.all(color: Colors.grey),
                      //           color: Colors.white,
                      //           borderRadius:
                      //               BorderRadius.all(Radius.circular(8))),
                      //       child: Padding(
                      //         padding: const EdgeInsets.only(
                      //             left: 8, right: 8),
                      //         child: Center(
                      //           child: DropdownButton<String>(
                      //             isExpanded: true,
                      //             value: users[currentIndex].userid,
                      //             items: users.map((UserModel value) {
                      //               return new DropdownMenuItem<String>(
                      //                 value: value.userid,
                      //                 child: new Text(value.name),
                      //               );
                      //             }).toList(),
                      //             onChanged: (value) {
                      //               for (int i = 0;
                      //                   i < users.length;
                      //                   i++) {
                      //                 if (users[i].userid == value) {
                      //                   setState(() {
                      //                     currentIndex = i;
                      //                   });
                      //                   break;
                      //                 }
                      //               }
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),

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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
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
                                titlePadding: const EdgeInsets.all(0.0),
                                contentPadding: const EdgeInsets.all(0.0),
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
                                      topLeft: const Radius.circular(2.0),
                                      topRight: const Radius.circular(2.0),
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Choose'),
                                    onPressed: () {
                                      setState(
                                          () => currentColor = pickerColor);
                                      print(currentColor);
                                      print('#' +
                                          currentColor.toString().substring(
                                              10,
                                              currentColor.toString().length -
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
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
                                  style: TextStyle(color: Colors.white),
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
                                return selectedEdu[index].userid != null
                                    ? Chip(
                                        label: Text(selectedEdu[index].name),
                                        onDeleted: () {
                                          setState(() {
                                            eduValues[selectedEdu[index]
                                                .userid] = false;
                                            selectedEdu.removeAt(index);
                                          });
                                        })
                                    : Container();
                              }))
                          : Container(),
                      // DropdownButtonHideUnderline(
                      //   child: Container(
                      //     height: 50,
                      //     width: MediaQuery.of(context).size.width,
                      //     decoration: BoxDecoration(
                      //         border: Border.all(color: Colors.grey),
                      //         color: Colors.white,
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(8))),
                      //     child: Padding(
                      //       padding:
                      //           const EdgeInsets.only(left: 8, right: 8),
                      //       child: Center(
                      //         child: DropdownButton<String>(
                      //           isExpanded: true,
                      //           value: users[currentIndexEdu].userid,
                      //           items: users.map((UserModel value) {
                      //             return new DropdownMenuItem<String>(
                      //               value: value.userid,
                      //               child: new Text(value.name),
                      //             );
                      //           }).toList(),
                      //           onChanged: (value) {
                      //             for (int i = 0; i < users.length; i++) {
                      //               if (users[i].userid == value) {
                      //                 setState(() {
                      //                   currentIndexEdu = i;
                      //                 });
                      //                 break;
                      //               }
                      //             }
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 25,
                      ),
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
                                if (name?.text.toString() == '') {
                                  roomError = 'Enter Room Name';
                                  setState(() {});
                                } else if (capacity?.text.toString() == '') {
                                  roomError = '';
                                  capacityError = 'Enter Capacity';
                                  setState(() {});
                                } else if (ageFrom?.text.toString() == '') {
                                  roomError = '';
                                  capacityError = '';
                                  ageFromError = 'Enter age';
                                  setState(() {});
                                } else if (ageFrom?.text.toString() == '') {
                                  roomError = '';
                                  capacityError = '';
                                  ageFromError = '';
                                  ageToError = 'Enter age';
                                  setState(() {});
                                }
                                //  else if (currentIndex == 0) {
                                //   roomError = '';
                                //   capacityError = '';
                                //   colorError = '';
                                //   leaderError = 'Choose Leader';
                                //   setState(() {});
                                // }
                                else {
                                  roomError = '';
                                  capacityError = '';
                                  ageFromError = '';
                                  ageToError = '';
                                  setState(() {});
                                  String _toSend =
                                      Constants.BASE_URL + 'room/editRoom';
                                  print(_toSend);
                                  List edu = [];
                                  for (int i = 0; i < selectedEdu.length; i++) {
                                    edu.add(int.parse(selectedEdu[i].userid));
                                  }
                                  var objToSend = {
                                    "centerid": widget.centerid,
                                    "id": widget.roomid,
                                    "userid": MyApp.LOGIN_ID_VALUE,
                                    "room_name": name?.text.toString(),
                                    "room_capacity": capacity?.text.toString(),
                                    "ageFrom": ageFrom?.text.toString(),
                                    "ageTo": ageTo?.text.toString(),
                                    "room_status": _chosenValue,
                                    "room_color": '#' +
                                        parseColorToHex('#' +
                                            currentColor.toString().substring(
                                                10,
                                                currentColor.toString().length -
                                                    1)),
                                    "educators": edu,
                                  };
                                  print('000000000000000000');
                                  print(jsonEncode(objToSend));
                                  print(parseColorToHex('#' +
                                      currentColor.toString().substring(10,
                                          currentColor.toString().length - 1)));
                                  // return;
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
                                    MyApp.ShowToast("edited", context);
                                    print('created');
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                  } else if (response.statusCode == 401) {
                                    //  MyApp.Show401Dialog(context);
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'SAVE',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ])
                    ]))
              : SizedBox(
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
                )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        endDrawer: getEndDrawer(context),
        appBar: Header.appBar(),
        body: SafeArea(child: roomeditui()));
  }
}

String parseColorToHex(String colorString) {
  try {
    // Extract RGBA values using RegExp
    RegExp redExp = RegExp(r"red:\s*([\d.]+)");
    RegExp greenExp = RegExp(r"green:\s*([\d.]+)");
    RegExp blueExp = RegExp(r"blue:\s*([\d.]+)");

    double red =
        double.tryParse(redExp.firstMatch(colorString)?.group(1) ?? "0") ?? 0;
    double green =
        double.tryParse(greenExp.firstMatch(colorString)?.group(1) ?? "0") ?? 0;
    double blue =
        double.tryParse(blueExp.firstMatch(colorString)?.group(1) ?? "0") ?? 0;

    // Convert to 0-255 range
    int redInt = (red * 255).toInt();
    int greenInt = (green * 255).toInt();
    int blueInt = (blue * 255).toInt();

    // Convert to hex format
    return "#${redInt.toRadixString(16).padLeft(2, '0')}"
            "${greenInt.toRadixString(16).padLeft(2, '0')}"
            "${blueInt.toRadixString(16).padLeft(2, '0')}"
        .toUpperCase();
  } catch (e) {
    print("Error parsing color: $e");
    return "#FFFFFF"; // Default white color if parsing fails
  }
}
