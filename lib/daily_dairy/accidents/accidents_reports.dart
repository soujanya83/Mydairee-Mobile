import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/dailydairyapi.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/daily_dairy/accidents/add_accidents.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/accidents.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/hexconversion.dart';

class AccidentsReports extends StatefulWidget {
  @override
  _AccidentsReportsState createState() => _AccidentsReportsState();
}

class _AccidentsReportsState extends State<AccidentsReports> {
  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;

  List<RoomsDescModel> rooms = [];
  bool roomsFetched = false;
  int currentRoomIndex = 0;
  List<AccidentsModel> _accident = [];
  bool accidentFetched = false;
  int accidentIndedx = 0;
  var details;

  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    print(dt);
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

    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    currentRoomIndex = 0;
    RoomAPIHandler handler = RoomAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var data = await handler.getList();
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

  // Future<void> _fetchData() async {
  //   Map<String, String> data = {
  //     'userid': MyApp.LOGIN_ID_VALUE,
  //     'centerid': centers[currentIndex].id
  //   };

  //   if (roomsFetched && rooms.isNotEmpty) {
  //     data['roomid'] = rooms[currentRoomIndex].id;
  //     // data['date'] = DateFormat("yyyy-MM-dd").format(date);
  //   }

  //   print(data);
  //   DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data);
  //   var dt = await hlr.getData();
  //   if (!dt.containsKey('error')) {
  //     // print(dt);
  //     // details = dt;
  //     var res = dt['rooms'];
  //     rooms = [];
  //     try {
  //       assert(res is List);
  //       for (int i = 0; i < res.length; i++) {
  //         rooms.add(RoomsDescModel.fromJson(res[i]));
  //       }
  //       roomsFetched = true;
  //       if (this.mounted) setState(() {});
  //     } catch (e) {
  //       print(e);
  //     }
  //     // var child = dt['childs'];
  //     // _allChildrens = [];
  //     // try {
  //     //   assert(child is List);
  //     //   for (int i = 0; i < child.length; i++) {
  //     //     _allChildrens.add(ChildModel.fromJson(child[i]));
  //     //     childValues[_allChildrens[i].id] = false;
  //     //   }
  //     //   childrensFetched = true;
  //     // } catch (e) {
  //     //   print(e);
  //     // }

  //     // showType = dt['columns'];
  //   } else {
  //     MyApp.Show401Dialog(context);
  //   }
  //   _fetchDataui();
  // }

  bool loading = true;
  Future<void> _fetchData() async {
    if (this.mounted && !loading) {
      setState(() {
        loading = true;
      });
    }
    Map<String, String> data1 = {
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': centers[currentIndex].id,
    };
    if (rooms.isNotEmpty) {
      data1.addAll({'roomid': rooms[currentRoomIndex].id});
    }
    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data1);
    var adt = await hlr.getAccidentsData();
    if (!adt.containsKey('error')) {
      details = adt;
      var res = adt['accidents'];
      _accident = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          _accident.add(AccidentsModel.fromJson(res[i]));
        }
        accidentFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  // void _fetchData() async {
  //   // var _objToSend = {
  //   //   "usertype": MyApp.USER_TYPE_VALUE,
  //   //   "userid": MyApp.LOGIN_ID_VALUE,
  //   //   "centerid": centers[currentIndex].id
  //   // };
  //   // ProgramPlanApiHandler planApiHandler = ProgramPlanApiHandler(_objToSend);
  //   // var data = await planApiHandler.getProgramPlanList();
  //   // planList = data['get_program_details'];
  //   // //  progHead=data['get_details']['']
  //   // setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Accident Reports',
                    style: Constants.header1,
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  if (MyApp.USER_TYPE_VALUE != 'Parent')
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddAccidents(
                                      centerid: centers[currentIndex].id,
                                      roomid: rooms[currentRoomIndex].id,
                                      type: 'add',
                                      accid: '',
                                    ))).then((value) {
                          _fetchData();
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Constants.kButton,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Text(
                              'Add Accident',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          )),
                    )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  centersFetched
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.9,
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
                  SizedBox(
                    height: 20,
                  ),
                  roomsFetched
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.9,
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
                                  value: rooms.isNotEmpty &&
                                          List.generate(rooms.length, (i) {
                                            return rooms[i].id;
                                          }).contains(
                                              rooms[currentRoomIndex].id)
                                      ? rooms[currentRoomIndex].id
                                      : null,
                                  items: rooms.map((RoomsDescModel value) {
                                    return new DropdownMenuItem<String>(
                                      value: value.id,
                                      child: new Text(value.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    for (int i = 0; i < rooms.length; i++) {
                                      if (rooms[i].id == value) {
                                        setState(() {
                                          currentRoomIndex = i;
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
              details != null && !loading
                  ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(builder: (context) {
                            Color? hexColor;
                            try {
                              hexColor = HexColor(details['roomcolor']);
                            } catch (e) {
                              print(e.toString());
                            }
                            return Container(
                              color: hexColor,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 8, 5, 5),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                              .40 - 15,
                                      child: Text(
                                        "S No" + "    " + "Name",
                                        style: Constants.sideHeadingStyle,
                                      ),
                                    ),
                                    // Expanded(child: Container()),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                    .25 -
                                                8,
                                        child: Text(
                                          "Created By",
                                          style: Constants.sideHeadingStyle,
                                        ),
                                      ),
                                    ),
                                    // Expanded(child: Container()),
                                    Text(
                                      "Date",
                                      style: Constants.sideHeadingStyle,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 8, 5, 5),
                            child: accidentFetched
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _accident.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        // child: ListTile(
                                        //   title: Text(_accident[index].childName),
                                        // ),

                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                AddAccidents(
                                                                  centerid:
                                                                      centers[currentIndex]
                                                                          .id,
                                                                  roomid: rooms[
                                                                          currentRoomIndex]
                                                                      .id,
                                                                  accid: _accident[
                                                                          index]
                                                                      .id,
                                                                  type: 'edit',
                                                                ))).then(
                                                    (value) {
                                                  _fetchData();
                                                });
                                              },
                                              child: Container(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .40-15,
                                                        child: Text(
                                                          _accident[index].id +
                                                              "    " +
                                                              _accident[index]
                                                                  .childName,
                                                          style: TextStyle(
                                                              fontSize: 13.0,
                                                              color: Constants
                                                                  .kHeader1,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: Container()),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .3,
                                                        child: Text(
                                                          _accident[index]
                                                              .username,
                                                          style: TextStyle(
                                                              fontSize: 13.0,
                                                              color: Constants
                                                                  .kMain,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: Container()),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .25 -
                                                            8,
                                                        child: Text(
                                                            formatDateToDdMmYyyy(
                                                                _accident[index]
                                                                    .incidentDate),
                                                            style: TextStyle(
                                                                fontSize: 13.0,
                                                                color: Constants
                                                                    .kMain,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Container(),
                          )
                        ],
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height * .7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: 40,
                              width: 40,
                              child:
                                  Center(child: CircularProgressIndicator())),
                        ],
                      )),
            ],
          ),
        ),
      )),
    );
  }
}

String formatDateToDdMmYyyy(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return "Invalid Date";

  try {
    DateTime date = DateTime.parse(dateStr);
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  } catch (e) {
    return "";
  }
}
