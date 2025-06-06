import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/dailydairyapi.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/daily_dairy/dailydairy_add.dart';
import 'package:mykronicle_mobile/daily_dairy/dailydairy_multiple.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/models/recipemodel.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/hexconversion.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DailyDairyMain extends StatefulWidget {
  @override
  _DailyDairyMainState createState() => _DailyDairyMainState();
}

class _DailyDairyMainState extends State<DailyDairyMain> {
  DateTime? date;
  List<CentersModel> centers = [];
  bool centersFetched = false;

  String roomName = 'Discoverers';

  List<RecipeModel> recipes = [];
  bool recipesFetched = false;

  List<RoomsDescModel> rooms = [];
  bool roomsFetched = false;

  int currentIndex = 0;
  int currentRoomIndex = 0;

  bool timeScreen = false;
  String hour = '1h';
  String min = '0m';
  String hour2 = '1h';
  String min2 = '0m';
  var showType;

  bool showPop = false;
  String type = '';
  List<String> hours = [];
  List<String> minutes = [];
  var details;

  TextEditingController? quant, cal, comments, nappy, potty, toilet, signature;

  int selectedIndex = 0;

  bool childrensFetched = false;
  List<ChildModel> _allChildrens = [];
  List<ChildModel> _selectedChildrens = [];
  int currentItemIndex = 0;

  Map<String, bool> childValues = {};

  @override
  void initState() {
    date = DateTime.now();
    quant = new TextEditingController();
    cal = new TextEditingController();
    comments = new TextEditingController();

    nappy = new TextEditingController();
    potty = new TextEditingController();
    toilet = new TextEditingController();
    signature = new TextEditingController();

    hours = List<String>.generate(24, (counter) => "${counter + 1}h");
    minutes = List<String>.generate(60, (counter) => "${counter}m");

    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    if (!dt.containsKey('error')) {
      print(dt);
      var res = dt['Centers'];
      centers = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          centers.add(CentersModel.fromJson(res[i]));
        }
        centersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
    await _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    RoomAPIHandler handler = RoomAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var data = await handler.getList();
    print('++++++rooms data++++++');
    print(rooms);
    print('HEE' + data['permission'].toString());
    var res = data['rooms'];
    rooms = [];
    try {
      assert(res is List);
      for (int i = 0; i < res.length; i++) {
        RoomsDescModel roomDescModel = RoomsDescModel.fromJson(res[i]);
        rooms.add(roomDescModel);
      }
      roomsFetched = true;
      if (this.mounted) setState(() {});

      _fetchData();
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  bool dataFetched = false;

  Future<void> _fetchData() async {
    print('enter in _fetchData');
    roomsFetched = true;
    Map<String, String> data = {
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': centers[currentIndex].id
    };
    print('++++++data++++++++');
    try {
      // print(rooms[currentRoomIndex].id);
      print(DateFormat("yyyy-MM-dd").format(date!));
    } catch (e, s) {
      print(e);
      print(s);
    }
    print('roomsFetched');

    print(data);
    if (roomsFetched && rooms.isNotEmpty) {
      data['roomid'] = rooms[currentRoomIndex].id;
      data['date'] = DateFormat("yyyy-MM-dd").format(date ?? DateTime.now());
    }
    if (MyApp.USER_TYPE_VALUE == 'Superadmin') {
      data['superadmin'] = '1';
    } else if (MyApp.USER_TYPE_VALUE == 'Parent') {
      data['superadmin'] = '2';
    } else if (MyApp.USER_TYPE_VALUE == 'Staff') {
      data['superadmin'] = '3';
    }
    print('+++++++++++');
    print(data);
    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data);
    var dt = await hlr.getData();
    if (!dt.containsKey('error')) {
      print(dt);
      details = dt;
      var res = dt['rooms'];
      rooms = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          rooms.add(RoomsDescModel.fromJson(res[i]));
        }
        roomsFetched = true;
      } catch (e, s) {
        print('getting error in center');
        print(e);
        print(s);
      }
      var child = dt['childs'];
      _allChildrens = [];
      try {
        assert(child is List);
        for (int i = 0; i < child.length; i++) {
          _allChildrens.add(ChildModel.fromJson(child[i]));
          childValues[_allChildrens[i].id] = false;
        }
        childrensFetched = true;
      } catch (e, s) {
        print('getting error in children');
        print(e);
        print(s);
      }

      showType = dt['columns'];
      if (this.mounted)
        setState(() {
          dataFetched = true;
        });
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  Future<void> _getItems(String type) async {
    DailyDairyAPIHandler hlr =
        DailyDairyAPIHandler({'userid': MyApp.LOGIN_ID_VALUE, "type": type});
    var dt = await hlr.getItems();
    if (!dt.containsKey('error')) {
      print(dt);
      var res = dt['items'];
      recipes = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          recipes.add(RecipeModel.fromJson(res[i]));
        }
        recipesFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  void dispose() {
    quant?.dispose();
    cal?.dispose();
    comments?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        // floatingActionButton: floating(context),
        body: roomsFetched
            ? Stack(
                children: [
                  SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Daily Dairy',
                                        style: Constants.header1,
                                      ),
                                      Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Constants.greyColor)),
                                        height: 35,
                                        width: 120,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                date != null
                                                    ? DateFormat("dd-MM-yyyy")
                                                        .format(date!)
                                                    : '',
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                              Spacer(),
                                              GestureDetector(
                                                  onTap: () async {
                                                    date = await _selectDate(
                                                        context,
                                                        date ?? DateTime.now());
                                                    details = null;
                                                    childrensFetched = false;
                                                    setState(() {});
                                                    _fetchData();
                                                  },
                                                  child: Icon(
                                                    AntDesign.calendar,
                                                    color: Colors.grey[400],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    centersFetched
                                        ? DropdownButtonHideUnderline(
                                            child: Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Constants.greyColor),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, right: 8),
                                                child: Center(
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    value: centers[currentIndex]
                                                        .id,
                                                    items: centers.map(
                                                        (CentersModel value) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: value.id,
                                                        child: new Text(
                                                            value.centerName),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      for (int i = 0;
                                                          i < centers.length;
                                                          i++) {
                                                        if (centers[i].id ==
                                                            value) {
                                                          setState(() {
                                                            currentIndex = i;
                                                            details = null;
                                                            _selectedChildrens =
                                                                [];
                                                            childrensFetched =
                                                                false;
                                                            // _fetchData();
                                                            _fetchRooms();
                                                          });
                                                          break;
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    // Expanded(
                                    //   child: Container(),
                                    // ),
                                    SizedBox(height: 10),
                                    roomsFetched
                                        ? DropdownButtonHideUnderline(
                                            child: Container(
                                              height: 40,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Constants.greyColor),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, right: 8),
                                                child: rooms.isEmpty
                                                    ? Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                            'NO ROOMS AVAILABLE'))
                                                    : Center(
                                                        child: DropdownButton<
                                                            String>(
                                                          isExpanded: true,
                                                          value: rooms[
                                                                  currentRoomIndex]
                                                              .id,
                                                          items: rooms.map(
                                                              (RoomsDescModel
                                                                  value) {
                                                            return new DropdownMenuItem<
                                                                String>(
                                                              value: value.id,
                                                              child: new Text(
                                                                  value.name),
                                                            );
                                                          }).toList(),
                                                          onChanged: (value) {
                                                            for (int i = 0;
                                                                i <
                                                                    rooms
                                                                        .length;
                                                                i++) {
                                                              if (rooms[i].id ==
                                                                  value) {
                                                                setState(() {
                                                                  currentRoomIndex =
                                                                      i;
                                                                  details =
                                                                      null;
                                                                  childrensFetched =
                                                                      false;
                                                                  _selectedChildrens =
                                                                      [];
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
                                          )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                details != null
                                    ? Builder(builder: (context) {
                                        Color? color;
                                        try {
                                          color =
                                              HexColor(details['roomcolor']);
                                        } catch (e) {
                                          print(e);
                                        }
                                        return Container(
                                          color: color,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(3.0),
                                                child: Text(
                                                  rooms.isEmpty
                                                      ? 'No Rooms Available'
                                                      : rooms[currentRoomIndex]
                                                          .name,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      })
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .7,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                height: 40,
                                                width: 40,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator())),
                                          ],
                                        )),
                                timeScreen
                                    ? Container(
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 8, 5, 5),
                                              child: Row(
                                                children: [
                                                  timeScreen
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            timeScreen = false;
                                                            setState(() {});
                                                          },
                                                          child: Icon(
                                                            Icons
                                                                .arrow_back_ios,
                                                            size: 14,
                                                          ))
                                                      : Container(),
                                                  timeScreen
                                                      ? SizedBox(
                                                          width: 10,
                                                        )
                                                      : Container(),
                                                  Text(
                                                    _allChildrens[
                                                            selectedIndex ?? 0]
                                                        .name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16),
                                                  )
                                                ],
                                              ),
                                            ),
                                            ListView(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              children: [
                                                if (showType['breakfast'] ==
                                                    '1')
                                                  ListTile(
                                                    subtitle: (_allChildrens[
                                                                        selectedIndex ??
                                                                            0]
                                                                    .breakfast !=
                                                                null) &&
                                                            _allChildrens[
                                                                    selectedIndex ??
                                                                        0]
                                                                .breakfast!
                                                                .isNotEmpty
                                                        ? Text(_allChildrens[
                                                                        selectedIndex ??
                                                                            0]
                                                                    .breakfast?[
                                                                'startTime'] ??
                                                            '')
                                                        : Container(),
                                                    title: Text('Breakfast'),
                                                    trailing: MyApp
                                                                .USER_TYPE_VALUE ==
                                                            'Parent'
                                                        ? SizedBox()
                                                        : (_allChildrens[selectedIndex ??
                                                                            0]
                                                                        .breakfast !=
                                                                    null) &&
                                                                _allChildrens[
                                                                        selectedIndex ??
                                                                            0]
                                                                    .breakfast!
                                                                    .isNotEmpty
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  var time = _allChildrens[
                                                                          selectedIndex ??
                                                                              0]
                                                                      .breakfast?[
                                                                          'startTime']
                                                                      .toString()
                                                                      .split(
                                                                          ":");
                                                                  print(time);

                                                                  type =
                                                                      'Breakfast';
                                                                  _getItems(
                                                                          'BREAKFAST')
                                                                      .then(
                                                                          (value) {
                                                                    for (var i =
                                                                            0;
                                                                        i < recipes.length;
                                                                        i++) {
                                                                      if (recipes[i]
                                                                              .itemName
                                                                              .toLowerCase() ==
                                                                          _allChildrens[selectedIndex ?? 0]
                                                                              .breakfast?['item']
                                                                              .toString()
                                                                              .toLowerCase()) {
                                                                        currentItemIndex =
                                                                            i;
                                                                        break;
                                                                      }
                                                                    }
                                                                  });
                                                                  try {
                                                                    hour =
                                                                        time![
                                                                            0];
                                                                    min =
                                                                        time[1];
                                                                  } catch (e) {
                                                                    print(e
                                                                        .toString());
                                                                  }
                                                                  quant?.text =
                                                                      _allChildrens[selectedIndex]
                                                                              .breakfast?[
                                                                          'qty'];
                                                                  cal?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .breakfast?[
                                                                      'calories'];
                                                                  comments
                                                                      ?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .breakfast?[
                                                                      'comments'];

                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Edit',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  type =
                                                                      'Breakfast';
                                                                  _getItems(
                                                                      'BREAKFAST');
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Add',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                  ),
                                                if (showType['morningtea'] ==
                                                    '1')
                                                  ListTile(
                                                    subtitle: ((_allChildrens[
                                                                        selectedIndex]
                                                                    .morningtea !=
                                                                null) &&
                                                            (_allChildrens[
                                                                    selectedIndex]
                                                                .morningtea
                                                                .isNotEmpty))
                                                        ? Text(_allChildrens[
                                                                selectedIndex]
                                                            .morningtea[
                                                                'startTime']
                                                            .toString())
                                                        : Container(),
                                                    title: Text('Morning Tea'),
                                                    trailing: MyApp
                                                                .USER_TYPE_VALUE ==
                                                            'Parent'
                                                        ? SizedBox()
                                                        : ((_allChildrens[selectedIndex]
                                                                        .morningtea !=
                                                                    null) &&
                                                                (_allChildrens[
                                                                        selectedIndex]
                                                                    .morningtea
                                                                    .isNotEmpty))
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  var time = _allChildrens[selectedIndex]
                                                                      .morningtea[
                                                                          'startTime']
                                                                      .toString()
                                                                      .split(
                                                                          ":");
                                                                  print(time);
                                                                  type =
                                                                      'MorningTea';
                                                                  _getItems(
                                                                          'MORNINGTEA')
                                                                      .then(
                                                                          (value) {
                                                                    for (var i =
                                                                            0;
                                                                        i < recipes.length;
                                                                        i++) {
                                                                      if (recipes[i]
                                                                              .itemName
                                                                              .toLowerCase() ==
                                                                          _allChildrens[selectedIndex]
                                                                              .morningtea['item']
                                                                              .toString()
                                                                              .toLowerCase()) {
                                                                        currentItemIndex =
                                                                            i;
                                                                        break;
                                                                      }
                                                                    }
                                                                  });
                                                                  hour =
                                                                      time[0];
                                                                  min = time[1];
                                                                  quant?.text =
                                                                      _allChildrens[selectedIndex]
                                                                              .morningtea[
                                                                          'qty'];
                                                                  cal?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .morningtea[
                                                                      'calories'];
                                                                  comments
                                                                      ?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .morningtea[
                                                                      'comments'];
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Edit',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  type =
                                                                      'MorningTea';
                                                                  _getItems(
                                                                      'MORNINGTEA');
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Add',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                  ),
                                                if (showType['lunch'] == '1')
                                                  ListTile(
                                                    subtitle: _allChildrens[
                                                                selectedIndex]
                                                            .lunch
                                                            .isNotEmpty
                                                        ? Text(_allChildrens[
                                                                selectedIndex]
                                                            .lunch['startTime']
                                                            .toString())
                                                        : Container(),
                                                    title: Text('Lunch'),
                                                    trailing: MyApp
                                                                .USER_TYPE_VALUE ==
                                                            'Parent'
                                                        ? SizedBox()
                                                        : _allChildrens[
                                                                    selectedIndex]
                                                                .lunch
                                                                .isNotEmpty
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  var time = _allChildrens[
                                                                          selectedIndex]
                                                                      .lunch[
                                                                          'startTime']
                                                                      .toString()
                                                                      .split(
                                                                          ":");
                                                                  print(time);

                                                                  type =
                                                                      'Lunch';
                                                                  _getItems(
                                                                          'LUNCH')
                                                                      .then(
                                                                          (value) {
                                                                    for (var i =
                                                                            0;
                                                                        i < recipes.length;
                                                                        i++) {
                                                                      if (recipes[i]
                                                                              .itemName
                                                                              .toLowerCase() ==
                                                                          _allChildrens[selectedIndex]
                                                                              .lunch['item']
                                                                              .toString()
                                                                              .toLowerCase()) {
                                                                        currentItemIndex =
                                                                            i;
                                                                        break;
                                                                      }
                                                                    }
                                                                  });
                                                                  try {
                                                                    hour =
                                                                        time[0];
                                                                    min =
                                                                        time[1];
                                                                  } catch (e) {
                                                                    print(e
                                                                        .toString());
                                                                  }
                                                                  quant?.text =
                                                                      _allChildrens[selectedIndex]
                                                                              .lunch[
                                                                          'qty'];
                                                                  cal?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .lunch[
                                                                      'calories'];
                                                                  comments
                                                                      ?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .lunch[
                                                                      'comments'];

                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Edit',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  type =
                                                                      'Lunch';
                                                                  _getItems(
                                                                      'LUNCH');
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Add',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                  ),
                                                if (showType['sleep'] == '1')
                                                  ListTile(
                                                    title: Text('Sleep'),
                                                    subtitle: _allChildrens[
                                                                selectedIndex]
                                                            .sleep
                                                            .isNotEmpty
                                                        ? Text(_allChildrens[
                                                                        selectedIndex]
                                                                    .sleep[0]
                                                                ['startTime'] +
                                                            ' to ' +
                                                            _allChildrens[
                                                                        selectedIndex]
                                                                    .sleep[0]
                                                                ['endTime'])
                                                        : Container(),
                                                    trailing: MyApp
                                                                .USER_TYPE_VALUE ==
                                                            'Parent'
                                                        ? SizedBox()
                                                        : _allChildrens[
                                                                    selectedIndex]
                                                                .sleep
                                                                .isNotEmpty
                                                            ? GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  await Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => DailyDairyMultiple(
                                                                              _allChildrens[
                                                                                  selectedIndex],
                                                                              'Sleep',
                                                                              details))).then(
                                                                      (value) {
                                                                    if (value !=
                                                                        null) {
                                                                      details =
                                                                          null;
                                                                      childrensFetched =
                                                                          false;
                                                                      //       viewAdd = false;
                                                                      _fetchData();
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  });
                                                                  _fetchData();
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            75,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                AntDesign.eye,
                                                                                size: 14,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' View',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  type =
                                                                      'Sleep';
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Add',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                  ),
                                                if (showType['afternoontea'] ==
                                                    '1')
                                                  ListTile(
                                                    subtitle: _allChildrens[
                                                                selectedIndex]
                                                            .afternoontea
                                                            .isNotEmpty
                                                        ? Text(_allChildrens[
                                                                selectedIndex]
                                                            .afternoontea[
                                                                'startTime']
                                                            .toString())
                                                        : Container(),
                                                    title:
                                                        Text('Afternoon Tea'),
                                                    trailing: MyApp
                                                                .USER_TYPE_VALUE ==
                                                            'Parent'
                                                        ? SizedBox()
                                                        : _allChildrens[
                                                                    selectedIndex]
                                                                .afternoontea
                                                                .isNotEmpty
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  var time = _allChildrens[selectedIndex]
                                                                      .afternoontea[
                                                                          'startTime']
                                                                      .toString()
                                                                      .split(
                                                                          ":");
                                                                  print(time);

                                                                  type =
                                                                      'AfternoonTea';
                                                                  _getItems(
                                                                          'AFTERNOONTEA')
                                                                      .then(
                                                                          (value) {
                                                                    for (var i =
                                                                            0;
                                                                        i < recipes.length;
                                                                        i++) {
                                                                      if (recipes[i]
                                                                              .itemName
                                                                              .toLowerCase() ==
                                                                          _allChildrens[selectedIndex]
                                                                              .afternoontea['item']
                                                                              .toString()
                                                                              .toLowerCase()) {
                                                                        currentItemIndex =
                                                                            i;
                                                                        break;
                                                                      }
                                                                    }
                                                                  });
                                                                  hour =
                                                                      time[0];
                                                                  min = time[1];
                                                                  quant?.text =
                                                                      _allChildrens[selectedIndex]
                                                                              .afternoontea[
                                                                          'qty'];
                                                                  cal?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .afternoontea[
                                                                      'calories'];
                                                                  comments
                                                                      ?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .afternoontea[
                                                                      'comments'];
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Edit',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  type =
                                                                      'AfternoonTea';
                                                                  _getItems(
                                                                      'AFTERNOONTEA');
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Add',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                  ),
                                                if (showType['latesnacks'] ==
                                                    '1')
                                                  ListTile(
                                                    subtitle: _allChildrens[
                                                                selectedIndex]
                                                            .snacks
                                                            .isNotEmpty
                                                        ? Text(_allChildrens[
                                                                selectedIndex]
                                                            .snacks['startTime']
                                                            .toString())
                                                        : Container(),
                                                    title: Text('Late Snacks'),
                                                    trailing: MyApp
                                                                .USER_TYPE_VALUE ==
                                                            'Parent'
                                                        ? SizedBox()
                                                        : _allChildrens[
                                                                    selectedIndex]
                                                                .snacks
                                                                .isNotEmpty
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  var time = _allChildrens[
                                                                          selectedIndex]
                                                                      .snacks[
                                                                          'startTime']
                                                                      .toString()
                                                                      .split(
                                                                          ":");
                                                                  print(time);

                                                                  type =
                                                                      'Snacks';
                                                                  _getItems(
                                                                          'SNACKS')
                                                                      .then(
                                                                          (value) {
                                                                    for (var i =
                                                                            0;
                                                                        i < recipes.length;
                                                                        i++) {
                                                                      if (recipes[i]
                                                                              .itemName
                                                                              .toLowerCase() ==
                                                                          _allChildrens[selectedIndex]
                                                                              .snacks['item']
                                                                              .toString()
                                                                              .toLowerCase()) {
                                                                        currentItemIndex =
                                                                            i;
                                                                        break;
                                                                      }
                                                                    }
                                                                  });
                                                                  hour =
                                                                      time[0];
                                                                  min = time[1];
                                                                  quant?.text =
                                                                      _allChildrens[selectedIndex]
                                                                              .snacks[
                                                                          'qty'];
                                                                  cal?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .snacks[
                                                                      'calories'];
                                                                  comments
                                                                      ?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .snacks[
                                                                      'comments'];

                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Edit',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  type =
                                                                      'Snacks';
                                                                  _getItems(
                                                                      'SNACKS');
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Add',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                  ),
                                                if (showType['sunscreen'] ==
                                                    '1')
                                                  ListTile(
                                                    title: Text('SunScreen'),
                                                    subtitle: _allChildrens[
                                                                selectedIndex]
                                                            .sunscreen
                                                            .isNotEmpty
                                                        ? _allChildrens[
                                                                    selectedIndex]
                                                                .sunscreen
                                                                .isEmpty
                                                            ? Text(
                                                                'No Suncreen data')
                                                            : Builder(builder:
                                                                (context) {
                                                                try {
                                                                  return Text(_allChildrens[
                                                                              selectedIndex]
                                                                          .sunscreen[0]
                                                                      [
                                                                      'startTime']);
                                                                } catch (e) {
                                                                  return Text(
                                                                      '');
                                                                }
                                                              })
                                                        : Container(),
                                                    // Column(
                                                    //     crossAxisAlignment:
                                                    //         CrossAxisAlignment
                                                    //             .start,
                                                    //     children: _allChildrens[
                                                    //             selectedIndex]
                                                    //         .sunscreen
                                                    //         .map<Widget>(
                                                    //             (item) {
                                                    //       return Text(
                                                    //         item['startTime']
                                                    //             .toString(),
                                                    //         style: TextStyle(
                                                    //             fontSize:
                                                    //                 16),
                                                    //       );
                                                    //     }).toList(),
                                                    //   )
                                                    // : Container(),
                                                    trailing: MyApp
                                                                .USER_TYPE_VALUE ==
                                                            'Parent'
                                                        ? SizedBox()
                                                        : _allChildrens[
                                                                    selectedIndex]
                                                                .sunscreen
                                                                .isNotEmpty
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => DailyDairyMultiple(
                                                                              _allChildrens[
                                                                                  selectedIndex],
                                                                              'Sunscreen',
                                                                              details))).then(
                                                                      (value) {
                                                                    if (value !=
                                                                        null) {
                                                                      details =
                                                                          null;
                                                                      childrensFetched =
                                                                          false;
                                                                      //  viewAdd = false;
                                                                      _fetchData();
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  });
                                                                  _fetchData();
                                                                  if (this
                                                                      .mounted)
                                                                    setState(
                                                                        () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            75,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                AntDesign.eye,
                                                                                size: 14,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' View',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  type =
                                                                      'SunScreen';
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                'Add',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                  ),
                                                if (showType['toileting'] ==
                                                    '1')
                                                  ListTile(
                                                    title: Text('Toileting'),
                                                    subtitle: _allChildrens[
                                                                        selectedIndex]
                                                                    .toileting !=
                                                                null &&
                                                            _allChildrens[
                                                                    selectedIndex]
                                                                .toileting
                                                                .isNotEmpty
                                                        ? Builder(
                                                            builder: (context) {
                                                            if (_allChildrens[
                                                                        selectedIndex]
                                                                    .toileting
                                                                    .runtimeType ==
                                                                List) {
                                                              return _allChildrens[
                                                                          selectedIndex]
                                                                      .toileting
                                                                      .isEmpty
                                                                  ? Text(
                                                                      'No toileting data')
                                                                  : Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: _allChildrens[
                                                                              selectedIndex]
                                                                          .toileting
                                                                          .map<Widget>(
                                                                              (item) {
                                                                        return Text(
                                                                          item['startTime']
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        );
                                                                      }).toList(),
                                                                    );
                                                            }
                                                            return Text(_allChildrens[
                                                                    selectedIndex]
                                                                .toileting[
                                                                    'startTime']
                                                                .toString());
                                                          })
                                                        : Container(),
                                                    trailing: MyApp
                                                                .USER_TYPE_VALUE ==
                                                            'Parent'
                                                        ? SizedBox()
                                                        : _allChildrens[selectedIndex]
                                                                        .toileting !=
                                                                    null &&
                                                                _allChildrens[
                                                                        selectedIndex]
                                                                    .toileting
                                                                    .isNotEmpty
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  var time = _allChildrens[selectedIndex]
                                                                      .toileting[
                                                                          'startTime']
                                                                      .toString()
                                                                      .split(
                                                                          ":");
                                                                  print(time);
                                                                  print(_allChildrens[
                                                                          selectedIndex]
                                                                      .toileting);

                                                                  type =
                                                                      'Toileting';
                                                                  hour =
                                                                      time[0];
                                                                  min = time[1];
                                                                  nappy?.text =
                                                                      _allChildrens[selectedIndex]
                                                                              .toileting[
                                                                          'nappy'];
                                                                  potty?.text =
                                                                      _allChildrens[selectedIndex]
                                                                              .toileting[
                                                                          'potty'];
                                                                  toilet
                                                                      ?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .toileting[
                                                                      'toilet'];
                                                                  signature
                                                                      ?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .toileting[
                                                                      'signature'];
                                                                  comments
                                                                      ?.text = _allChildrens[
                                                                              selectedIndex]
                                                                          .toileting[
                                                                      'comments'];

                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                'Edit',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  type =
                                                                      'Toileting';
                                                                  showPop =
                                                                      true;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                        width:
                                                                            65,
                                                                        decoration: BoxDecoration(
                                                                            color: Constants
                                                                                .kButton,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                8))),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              12,
                                                                              8,
                                                                              12,
                                                                              8),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.edit,
                                                                                size: 12,
                                                                                color: Colors.white,
                                                                              ),
                                                                              Text(
                                                                                ' Add',
                                                                                style: TextStyle(color: Colors.white),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )),
                                                              ),
                                                  ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(
                                        color: Colors.white,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      15, 8, 5, 5),
                                              child: Text(
                                                'Child',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            childrensFetched
                                                ? _allChildrens.isEmpty
                                                    ? SizedBox(
                                                        height: 200,
                                                        child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                                'No childrens are there in this room')),
                                                      )
                                                    : ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: _allChildrens
                                                            .length,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Container(
                                                            child: Transform(
                                                              transform: Matrix4
                                                                  .translationValues(
                                                                      -6,
                                                                      0.0,
                                                                      0.0),
                                                              child: ListTile(
                                                                leading:
                                                                    Checkbox(
                                                                        value: childValues[_allChildrens[index]
                                                                            .id],
                                                                        onChanged:
                                                                            (value) {
                                                                          if (value ==
                                                                              true) {
                                                                            if (!_selectedChildrens.contains(_allChildrens[index])) {
                                                                              _selectedChildrens.add(_allChildrens[index]);
                                                                            }
                                                                          } else {
                                                                            if (_selectedChildrens.contains(_allChildrens[index])) {
                                                                              _selectedChildrens.remove(_allChildrens[index]);
                                                                            }
                                                                          }
                                                                          childValues[_allChildrens[index].id] =
                                                                              value!;
                                                                          // if (_selectedChildrens
                                                                          //         .length >
                                                                          //     1)
                                                                          //     viewAdd =
                                                                          //true;
                                                                          setState(
                                                                              () {});
                                                                        }),
                                                                title:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    print(_allChildrens[
                                                                            index]
                                                                        .toString());
                                                                    selectedIndex =
                                                                        index;
                                                                    timeScreen =
                                                                        true;
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                        child: CircleAvatar(
                                                                            radius: 15.0,
                                                                            child: Image.network(
                                                                              errorBuilder: (context, error, stackTrace) {
                                                                                return SizedBox();
                                                                              },
                                                                              Constants.ImageBaseUrl + _allChildrens[index].imageUrl,
                                                                              fit: BoxFit.fitWidth,
                                                                            )),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              20),
                                                                      Transform(
                                                                          transform: Matrix4.translationValues(
                                                                              -13,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * .45,
                                                                            child:
                                                                                Text(
                                                                              _allChildrens[index].name,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: Constants.kMain),
                                                                            ),
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                : Container()
                                          ],
                                        ),
                                      ),
                                SizedBox(
                                  height: 10,
                                ),
                                // viewAdd
                                _selectedChildrens.length > 0 &&
                                        (MyApp.USER_TYPE_VALUE != 'Parent')
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () async {
                                              List<String> child = [];
                                              for (int i = 0;
                                                  i < _selectedChildrens.length;
                                                  i++) {
                                                child.add(
                                                    _selectedChildrens[i].id);
                                              }

                                              Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DailyDairyAdd(
                                                                  child,
                                                                  details,
                                                                  showType,
                                                                  date)))
                                                  .then((value) {
                                                if (value != null) {
                                                  details = null;
                                                  childrensFetched = false;
                                                  //  viewAdd = false;
                                                  _fetchData();
                                                  setState(() {});
                                                }
                                              });
                                            },
                                            child: Container(
                                                width: 60,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                    color: Constants.kButton,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        'ADD',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                          ))),
                  ((type == 'Breakfast' ||
                              type == 'MorningTea' ||
                              type == 'Lunch' ||
                              type == 'AfternoonTea' ||
                              type == 'Snacks') &&
                          details != null &&
                          showPop)
                      ? Center(
                          child: SingleChildScrollView(
                            child: Card(
                              elevation: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12)),
                                  height: 420,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: recipesFetched && recipes.length > 0
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              //  width: MediaQuery.of(context).size.width,
                                              color: HexColor(
                                                  details['roomcolor']),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 12,
                                                  ),
                                                  Text(
                                                    'Add ' + type,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Expanded(
                                                    child: Container(),
                                                  ),
                                                  IconButton(
                                                      icon: Icon(
                                                        Icons.clear,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        showDeleteDialog(
                                                            context, () {
                                                          showPop = false;
                                                          quant?.clear();
                                                          cal?.clear();
                                                          comments?.clear();
                                                          hour = '1h';
                                                          min = '0m';
                                                          currentItemIndex = 0;
                                                          setState(() {});
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      })
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 355,
                                                child: ListView(
                                                  children: [
                                                    Text('Time'),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: [
                                                        hours != null
                                                            ? DropdownButtonHideUnderline(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 80,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          border: Border
                                                                              .all(
                                                                            color:
                                                                                Constants.greyColor,
                                                                          ),
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(8))),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                    // child: Builder(
                                                                    //   builder: (context) {
                                                                    //     print(hours.toString());
                                                                    //     return Text(hours.toString());
                                                                    //   }
                                                                    // ),
                                                                    child: Builder(
                                                                        builder:
                                                                            (context) {
                                                                      try {
                                                                        if (!hours
                                                                            .contains(hour)) {
                                                                          hour =
                                                                              hours[0];
                                                                        }
                                                                        return Center(
                                                                          child:
                                                                              DropdownButton<String>(
                                                                            //  isExpanded: true,
                                                                            value:
                                                                                hour,
                                                                            items:
                                                                                hours.map((String value) {
                                                                              return new DropdownMenuItem<String>(
                                                                                value: value,
                                                                                child: new Text(value),
                                                                              );
                                                                            }).toList(),
                                                                            onChanged:
                                                                                (String? value) {
                                                                              if (value == null)
                                                                                return;
                                                                              hour = value!;
                                                                              setState(() {});
                                                                            },
                                                                          ),
                                                                        );
                                                                      } catch (e) {
                                                                        return SizedBox();
                                                                      }
                                                                    }),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(),
                                                        Container(
                                                          width: 20,
                                                        ),
                                                        minutes != null
                                                            ? DropdownButtonHideUnderline(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 80,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Constants
                                                                              .greyColor),
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(8))),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                    child:
                                                                        Center(
                                                                      child: DropdownButton<
                                                                          String>(
                                                                        //  isExpanded: true,
                                                                        value:
                                                                            min,
                                                                        items: minutes.map((String
                                                                            value) {
                                                                          return new DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value,
                                                                            child:
                                                                                new Text(value),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (String?
                                                                                value) {
                                                                          if (value ==
                                                                              null)
                                                                            return;
                                                                          min =
                                                                              value!;
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text('Item'),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    recipesFetched &&
                                                            recipes.length > 0
                                                        ? DropdownButtonHideUnderline(
                                                            child: Container(
                                                              height: 40,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Constants
                                                                          .greyColor),
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                child: Center(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    isExpanded:
                                                                        true,
                                                                    value: recipes[
                                                                            currentItemIndex]
                                                                        .id,
                                                                    items: recipes.map(
                                                                        (RecipeModel
                                                                            value) {
                                                                      return new DropdownMenuItem<
                                                                          String>(
                                                                        value: value
                                                                            .id,
                                                                        child: new Text(
                                                                            value.itemName),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (value) {
                                                                      for (int i =
                                                                              0;
                                                                          i < recipes.length;
                                                                          i++) {
                                                                        if (recipes[i].id ==
                                                                            value) {
                                                                          setState(
                                                                              () {
                                                                            currentItemIndex =
                                                                                i;
                                                                          });
                                                                          break;
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text('Quantity'),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      child: TextField(
                                                          maxLines: 1,
                                                          controller: quant,
                                                          decoration:
                                                              new InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom: 10,
                                                                    left: 10),
                                                            enabledBorder:
                                                                const OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .black26,
                                                                      width:
                                                                          0.0),
                                                            ),
                                                            border:
                                                                new OutlineInputBorder(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                const Radius
                                                                    .circular(
                                                                    4),
                                                              ),
                                                            ),
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text('Calories'),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      child: TextField(
                                                          maxLines: 1,
                                                          controller: cal,
                                                          decoration:
                                                              new InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom: 10,
                                                                    left: 10),
                                                            enabledBorder:
                                                                const OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .black26,
                                                                      width:
                                                                          0.0),
                                                            ),
                                                            border:
                                                                new OutlineInputBorder(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                const Radius
                                                                    .circular(
                                                                    4),
                                                              ),
                                                            ),
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text('Comments'),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Container(
                                                      height: 60,
                                                      child: TextField(
                                                          maxLines: 2,
                                                          controller: comments,
                                                          decoration:
                                                              new InputDecoration(
                                                            enabledBorder:
                                                                const OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .black26,
                                                                      width:
                                                                          0.0),
                                                            ),
                                                            border:
                                                                new OutlineInputBorder(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                const Radius
                                                                    .circular(
                                                                    4),
                                                              ),
                                                            ),
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Container(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              if (recipes
                                                                      .length >
                                                                  0) {
                                                                var _toSend = Constants
                                                                        .BASE_URL +
                                                                    'dailyDiary/addFoodRecord';

                                                                var objToSend =
                                                                    {
                                                                  "userid": MyApp
                                                                      .LOGIN_ID_VALUE,
                                                                  "startTime":
                                                                      hour +
                                                                          ":" +
                                                                          min,
                                                                  "item": recipes[
                                                                          currentItemIndex]
                                                                      .itemName,
                                                                  "qty": quant
                                                                      ?.text
                                                                      .toString(),
                                                                  "comments":
                                                                      comments
                                                                          ?.text
                                                                          .toString(),
                                                                  // "createdAt": DateTime
                                                                  //         .now()
                                                                  //     .toString(),
                                                                  "diarydate": DateFormat(
                                                                          'yyyy-MM-dd')
                                                                      .format(
                                                                          date!),
                                                                  "type": type
                                                                      .toUpperCase(),
                                                                  "calories": cal
                                                                      ?.text
                                                                      .toString(),
                                                                  "childids": [
                                                                    _allChildrens[
                                                                            selectedIndex]
                                                                        .id
                                                                  ]
                                                                };

                                                                print(jsonEncode(
                                                                    objToSend));
                                                                final response = await http.post(
                                                                    Uri.parse(
                                                                        _toSend),
                                                                    body: jsonEncode(
                                                                        objToSend),
                                                                    headers: {
                                                                      'X-DEVICE-ID':
                                                                          await MyApp
                                                                              .getDeviceIdentity(),
                                                                      'X-TOKEN':
                                                                          MyApp
                                                                              .AUTH_TOKEN_VALUE,
                                                                    });
                                                                print(response
                                                                    .body);
                                                                if (response
                                                                        .statusCode ==
                                                                    200) {
                                                                  showPop =
                                                                      false;
                                                                  quant
                                                                      ?.clear();
                                                                  cal?.clear();
                                                                  comments
                                                                      ?.clear();
                                                                  hour = '1h';
                                                                  min = '0m';
                                                                  currentItemIndex =
                                                                      0;
                                                                  MyApp.ShowToast(
                                                                      "updated",
                                                                      context);
                                                                  setState(
                                                                      () {});
                                                                  _fetchData();
                                                                } else if (response
                                                                        .statusCode ==
                                                                    401) {
                                                                  MyApp.Show401Dialog(
                                                                      context);
                                                                }
                                                              } else {
                                                                MyApp.ShowToast(
                                                                    'no items',
                                                                    context);
                                                              }
                                                            },
                                                            child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Constants
                                                                        .kButton,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8))),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          12,
                                                                          8,
                                                                          12,
                                                                          8),
                                                                  child: Text(
                                                                    'SAVE',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                )),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Text('No Recipe Found'),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    showPop = false;
                                                    setState(() {});
                                                  },
                                                  child: Text('ok'))
                                            ],
                                          ),
                                        )),
                            ),
                          ),
                        )
                      : Container(),
                  type == 'SunScreen' && details != null && showPop
                      ? Center(
                          child: SingleChildScrollView(
                          child: Card(
                            elevation: 3,
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12)),
                                height: 300,
                                width: MediaQuery.of(context).size.width * 0.85,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        //  width: MediaQuery.of(context).size.width,
                                        color: HexColor(details['roomcolor']),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              'Add ' + type,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  showDeleteDialog(context, () {
                                                    showPop = false;
                                                    comments?.clear();
                                                    hour = '1h';
                                                    min = '0m';
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  });
                                                })
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              height: 235,
                                              child: ListView(children: [
                                                Text('Time'),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    hours != null
                                                        ? DropdownButtonHideUnderline(
                                                            child: Container(
                                                              height: 40,
                                                              width: 80,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Constants
                                                                          .greyColor),
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                child: Center(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    //  isExpanded: true,
                                                                    value: hour,
                                                                    items: hours
                                                                        .map((String
                                                                            value) {
                                                                      return new DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child: new Text(
                                                                            value),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                            value) {
                                                                      if (value ==
                                                                          null)
                                                                        return;
                                                                      hour =
                                                                          value!;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    Container(
                                                      width: 20,
                                                    ),
                                                    minutes != null
                                                        ? DropdownButtonHideUnderline(
                                                            child: Container(
                                                              height: 40,
                                                              width: 80,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Constants
                                                                          .greyColor),
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                child: Center(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    //  isExpanded: true,
                                                                    value: min,
                                                                    items: minutes
                                                                        .map((String
                                                                            value) {
                                                                      return new DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child: new Text(
                                                                            value),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                            value) {
                                                                      if (value ==
                                                                          null)
                                                                        return;
                                                                      min =
                                                                          value!;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Comments'),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  height: 60,
                                                  child: TextField(
                                                      maxLines: 2,
                                                      controller: comments,
                                                      decoration:
                                                          new InputDecoration(
                                                        enabledBorder:
                                                            const OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .black26,
                                                                  width: 0.0),
                                                        ),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            const Radius
                                                                .circular(4),
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          var _toSend = Constants
                                                                  .BASE_URL +
                                                              'dailyDiary/addSunscreenRecord';

                                                          var objToSend = {
                                                            "userid": MyApp
                                                                .LOGIN_ID_VALUE,
                                                            "startTime": hour +
                                                                ":" +
                                                                min,
                                                            "comments": comments
                                                                ?.text
                                                                .toString(),
                                                            "createdAt":
                                                                DateTime.now()
                                                                    .toString(),
                                                            "type": type
                                                                .toUpperCase(),
                                                            "childids": [
                                                              _allChildrens[
                                                                      selectedIndex]
                                                                  .id
                                                            ]
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
                                                          print(response.body);
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            MyApp.ShowToast(
                                                                "updated",
                                                                context);
                                                            showPop = false;
                                                            if (this.mounted)
                                                              setState(() {});
                                                            _fetchData();
                                                          } else if (response
                                                                  .statusCode ==
                                                              401) {
                                                            MyApp.Show401Dialog(
                                                                context);
                                                          }
                                                        },
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Constants
                                                                    .kButton,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      12,
                                                                      8,
                                                                      12,
                                                                      8),
                                                              child: Text(
                                                                'SAVE',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            )),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ])))
                                    ])),
                          ),
                        ))
                      : Container(),
                  type == 'Sleep' && details != null && showPop
                      ? Center(
                          child: SingleChildScrollView(
                          child: Card(
                            elevation: 3,
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12)),
                                height: 370,
                                width: MediaQuery.of(context).size.width * 0.85,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        //  width: MediaQuery.of(context).size.width,
                                        color: HexColor(details['roomcolor']),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              'Add ' + type,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  showDeleteDialog(context, () {
                                                    showPop = false;
                                                    comments?.clear();
                                                    hour = '1h';
                                                    min = '0m';
                                                    hour2 = '1h';
                                                    min2 = '0m';
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  });
                                                })
                                          ],
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              height: 305,
                                              child: ListView(children: [
                                                Text('Time'),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    hours != null
                                                        ? DropdownButtonHideUnderline(
                                                            child: Container(
                                                              height: 40,
                                                              width: 80,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Constants
                                                                          .greyColor),
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                child: Center(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    //  isExpanded: true,
                                                                    value: hour,
                                                                    items: hours
                                                                        .map((String
                                                                            value) {
                                                                      return new DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child: new Text(
                                                                            value),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                            value) {
                                                                      if (value ==
                                                                          null)
                                                                        return;
                                                                      hour =
                                                                          value!;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    Container(
                                                      width: 20,
                                                    ),
                                                    minutes != null
                                                        ? DropdownButtonHideUnderline(
                                                            child: Container(
                                                              height: 40,
                                                              width: 80,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Constants
                                                                          .greyColor),
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                child: Center(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    //  isExpanded: true,
                                                                    value: min,
                                                                    items: minutes
                                                                        .map((String
                                                                            value) {
                                                                      return new DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child: new Text(
                                                                            value),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                            value) {
                                                                      if (value ==
                                                                          null)
                                                                        return;
                                                                      min =
                                                                          value!;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('To'),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    hours != null
                                                        ? DropdownButtonHideUnderline(
                                                            child: Container(
                                                              height: 40,
                                                              width: 80,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Constants
                                                                          .greyColor),
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                child: Center(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    //  isExpanded: true,
                                                                    value:
                                                                        hour2,
                                                                    items: hours
                                                                        .map((String
                                                                            value) {
                                                                      return new DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child: new Text(
                                                                            value),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                            value) {
                                                                      if (value ==
                                                                          null)
                                                                        return;
                                                                      hour2 =
                                                                          value!;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    Container(
                                                      width: 20,
                                                    ),
                                                    minutes != null
                                                        ? DropdownButtonHideUnderline(
                                                            child: Container(
                                                              height: 40,
                                                              width: 80,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Constants
                                                                          .greyColor),
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8))),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                child: Center(
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    //  isExpanded: true,
                                                                    value: min2,
                                                                    items: minutes
                                                                        .map((String
                                                                            value) {
                                                                      return new DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            value,
                                                                        child: new Text(
                                                                            value),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                            value) {
                                                                      if (value ==
                                                                          null)
                                                                        return;
                                                                      min2 =
                                                                          value!;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Text('Comments'),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  height: 60,
                                                  child: TextField(
                                                      maxLines: 2,
                                                      controller: comments,
                                                      decoration:
                                                          new InputDecoration(
                                                        enabledBorder:
                                                            const OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .black26,
                                                                  width: 0.0),
                                                        ),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            const Radius
                                                                .circular(4),
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          var _toSend = Constants
                                                                  .BASE_URL +
                                                              'dailyDiary/addSleepRecord';

                                                          var objToSend = {
                                                            "userid": MyApp
                                                                .LOGIN_ID_VALUE,
                                                            "startTime": hour +
                                                                ":" +
                                                                min,
                                                            "endTime": hour2 +
                                                                ":" +
                                                                min2,
                                                            "comments": comments
                                                                ?.text
                                                                .toString(),
                                                            "createdAt":
                                                                DateTime.now()
                                                                    .toString(),
                                                            "type": type
                                                                .toUpperCase(),
                                                            "childids": [
                                                              _allChildrens[
                                                                      selectedIndex]
                                                                  .id
                                                            ]
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
                                                          print(response.body);
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            MyApp.ShowToast(
                                                                "updated",
                                                                context);
                                                            showPop = false;
                                                            comments?.clear();
                                                            hour = '1h';
                                                            min = '0m';
                                                            hour2 = '1h';
                                                            min2 = '0m';
                                                            setState(() {});
                                                            _fetchData();
                                                          } else if (response
                                                                  .statusCode ==
                                                              401) {
                                                            MyApp.Show401Dialog(
                                                                context);
                                                          }
                                                        },
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Constants
                                                                    .kButton,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      12,
                                                                      8,
                                                                      12,
                                                                      8),
                                                              child: Text(
                                                                'SAVE',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            )),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ])))
                                    ])),
                          ),
                        ))
                      : Container(),
                  type == 'Toileting' && details != null && showPop
                      ? Center(
                          child: SingleChildScrollView(
                            child: Card(
                              elevation: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12)),
                                  height: 420,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        //  width: MediaQuery.of(context).size.width,
                                        color: HexColor(details['roomcolor']),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              'Add ' + type,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  showDeleteDialog(context, () {
                                                    showPop = false;
                                                    nappy?.clear();
                                                    potty?.clear();
                                                    toilet?.clear();
                                                    signature?.clear();
                                                    comments?.clear();
                                                    hour = '1h';
                                                    min = '0m';
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  });
                                                })
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 355,
                                          child: ListView(
                                            children: [
                                              Text('Time'),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  hours != null
                                                      ? DropdownButtonHideUnderline(
                                                          child: Container(
                                                            height: 40,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Constants
                                                                        .greyColor),
                                                                color: Colors
                                                                    .white,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 8,
                                                                      right: 8),
                                                              child: Center(
                                                                child:
                                                                    DropdownButton<
                                                                        String>(
                                                                  //  isExpanded: true,
                                                                  value: hour,
                                                                  items: hours
                                                                      .map((String
                                                                          value) {
                                                                    return new DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child: new Text(
                                                                          value),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (String?
                                                                          value) {
                                                                    if (value ==
                                                                        null)
                                                                      return;
                                                                    hour =
                                                                        value!;
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                  Container(
                                                    width: 20,
                                                  ),
                                                  minutes != null
                                                      ? DropdownButtonHideUnderline(
                                                          child: Container(
                                                            height: 40,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    color: Constants
                                                                        .greyColor),
                                                                color: Colors
                                                                    .white,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 8,
                                                                      right: 8),
                                                              child: Center(
                                                                child:
                                                                    DropdownButton<
                                                                        String>(
                                                                  //  isExpanded: true,
                                                                  value: min,
                                                                  items: minutes
                                                                      .map((String
                                                                          value) {
                                                                    return new DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child: new Text(
                                                                          value),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (String?
                                                                          value) {
                                                                    if (value ==
                                                                        null)
                                                                      return;
                                                                    min =
                                                                        value!;
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                              // SizedBox(
                                              //   height: 15,
                                              // ),
                                              // Text('Nappy'),
                                              // SizedBox(
                                              //   height: 5,
                                              // ),
                                              // Container(
                                              //   height: 40,
                                              //   child: TextField(
                                              //       maxLines: 1,
                                              //       controller: nappy,
                                              //       decoration:
                                              //           new InputDecoration(
                                              //         contentPadding:
                                              //             EdgeInsets.only(
                                              //                 bottom: 10,
                                              //                 left: 10),
                                              //         enabledBorder:
                                              //             const OutlineInputBorder(
                                              //           borderSide:
                                              //               const BorderSide(
                                              //                   color: Colors
                                              //                       .black26,
                                              //                   width: 0.0),
                                              //         ),
                                              //         border:
                                              //             new OutlineInputBorder(
                                              //           borderRadius:
                                              //               const BorderRadius
                                              //                   .all(
                                              //             const Radius.circular(
                                              //                 4),
                                              //           ),
                                              //         ),
                                              //       )),
                                              // ),
                                              // SizedBox(
                                              //   height: 15,
                                              // ),
                                              // Text('Potty'),
                                              // SizedBox(
                                              //   height: 5,
                                              // ),
                                              // Container(
                                              //   height: 40,
                                              //   child: TextField(
                                              //       maxLines: 1,
                                              //       controller: potty,
                                              //       decoration:
                                              //           new InputDecoration(
                                              //         contentPadding:
                                              //             EdgeInsets.only(
                                              //                 bottom: 10,
                                              //                 left: 10),
                                              //         enabledBorder:
                                              //             const OutlineInputBorder(
                                              //           borderSide:
                                              //               const BorderSide(
                                              //                   color: Colors
                                              //                       .black26,
                                              //                   width: 0.0),
                                              //         ),
                                              //         border:
                                              //             new OutlineInputBorder(
                                              //           borderRadius:
                                              //               const BorderRadius
                                              //                   .all(
                                              //             const Radius.circular(
                                              //                 4),
                                              //           ),
                                              //         ),
                                              //       )),
                                              // ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Text('Signature'),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                height: 40,
                                                child: TextField(
                                                    maxLines: 1,
                                                    controller: signature,
                                                    decoration:
                                                        new InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              bottom: 10,
                                                              left: 10),
                                                      enabledBorder:
                                                          const OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .black26,
                                                                width: 0.0),
                                                      ),
                                                      border:
                                                          new OutlineInputBorder(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          const Radius.circular(
                                                              4),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              // SizedBox(
                                              //   height: 15,
                                              // ),
                                              // Text('Toilet'),
                                              // SizedBox(
                                              //   height: 5,
                                              // ),
                                              // Container(
                                              //   height: 40,
                                              //   child: TextField(
                                              //       maxLines: 1,
                                              //       controller: toilet,
                                              //       decoration:
                                              //           new InputDecoration(
                                              //         contentPadding:
                                              //             EdgeInsets.only(
                                              //                 bottom: 10,
                                              //                 left: 10),
                                              //         enabledBorder:
                                              //             const OutlineInputBorder(
                                              //           borderSide:
                                              //               const BorderSide(
                                              //                   color: Colors
                                              //                       .black26,
                                              //                   width: 0.0),
                                              //         ),
                                              //         border:
                                              //             new OutlineInputBorder(
                                              //           borderRadius:
                                              //               const BorderRadius
                                              //                   .all(
                                              //             const Radius.circular(
                                              //                 4),
                                              //           ),
                                              //         ),
                                              //       )),
                                              // ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Text('Comments'),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                height: 60,
                                                child: TextField(
                                                    maxLines: 2,
                                                    controller: comments,
                                                    decoration:
                                                        new InputDecoration(
                                                      enabledBorder:
                                                          const OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .black26,
                                                                width: 0.0),
                                                      ),
                                                      border:
                                                          new OutlineInputBorder(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          const Radius.circular(
                                                              4),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        var _toSend = Constants
                                                                .BASE_URL +
                                                            'dailyDiary/addToiletingRecord';

                                                        var objToSend = {
                                                          "userid": MyApp
                                                              .LOGIN_ID_VALUE,
                                                          "startTime": [
                                                            hour + ":" + min
                                                          ],
                                                          "signature": signature
                                                              ?.text
                                                              .toString(),
                                                          "comments": comments
                                                              ?.text
                                                              .toString(),
                                                          // "createdAt":
                                                          //     DateTime.now()
                                                          //         .toString(),
                                                          "diarydate": DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(date!),
                                                          "type": type
                                                              .toUpperCase(),
                                                          "childids": [
                                                            _allChildrens[
                                                                    selectedIndex]
                                                                .id
                                                          ]
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
                                                        print(response.body);
                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          MyApp.ShowToast(
                                                              "updated",
                                                              context);
                                                          showPop = false;

                                                          potty?.clear();
                                                          nappy?.clear();
                                                          signature?.clear();
                                                          toilet?.clear();

                                                          comments?.clear();
                                                          hour = '1h';
                                                          min = '0m';
                                                          setState(() {});
                                                          _fetchData();
                                                        } else if (response
                                                                .statusCode ==
                                                            401) {
                                                          MyApp.Show401Dialog(
                                                              context);
                                                        }
                                                      },
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Constants
                                                                  .kButton,
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          8))),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    12,
                                                                    8,
                                                                    12,
                                                                    8),
                                                            child: Text(
                                                              'SAVE',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16),
                                                            ),
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        )
                      : Container(),
                ],
              )
            : Container(
                height: MediaQuery.of(context).size.height * .7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 40,
                        width: 40,
                        child: Center(child: CircularProgressIndicator())),
                  ],
                )));
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime dateTime) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: new DateTime(1800),
      lastDate: new DateTime(2100),
    );
    return picked;
  }
}
