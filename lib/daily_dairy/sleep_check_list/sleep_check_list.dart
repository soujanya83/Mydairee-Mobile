import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/dailydairyapi.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/accidents.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/models/sleepchecklist.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class SleepCheckList extends StatefulWidget {
  const SleepCheckList({super.key});

  @override
  State<SleepCheckList> createState() => _SleepCheckListState();
}

class _SleepCheckListState extends State<SleepCheckList> {
  List<String> breathingOptions = ['Regular', 'Fast', 'Difficult'];
  // String? selectedBreathing;

  List<String> bodyTempOptions = ['Warm', 'Cool', 'Hot'];
  // String? selectedBodyTemp;

  @override
  void dispose() {
    super.dispose();
  }

  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;

  List<RoomsDescModel> rooms = [];
  bool roomsFetched = false;
  int currentRoomIndex = 0;

  DateTime? date;

  List<String>? hours;
  List<String>? minutes;
  // String? gHour1, gMin1;

  @override
  void initState() {
    hours = List<String>.generate(24, (counter) => "${counter + 1}h");
    minutes = List<String>.generate(60, (counter) => "${counter}m");
    // gMin1 = minutes?[0];
    // gHour1 = hours?[0];
    date = DateTime.now();
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
  List<SlipChecksChildModel> slipChecksChildModel = [];
  Future<void> _fetchData() async {
    Map<String, String> data1 = {
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': centers[currentIndex].id,
    };
    if (rooms.isNotEmpty) {
      data1.addAll({'roomid': rooms[currentRoomIndex].id});
      data1['date'] = DateFormat("yyyy-MM-dd").format(date!);
    }

    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data1);
    var json = await hlr.getSlipCheckListsData();
    if (!json.containsKey('error')) {
      var res = json['children'];
      try {
        slipChecksChildModel = [];
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          print('++++++++++++++++++++parental index = $i');
          slipChecksChildModel.add(SlipChecksChildModel.fromJson(res[i]));
          print(json['sleepChecks'].toString());
          for (int j = 0; j < (json['sleepChecks'].length); j++) {
            print('--------------------internal index = $j');
            if (slipChecksChildModel[i].id.toString() ==
                json['sleepChecks'][j]['childid'].toString()) {
              slipChecksChildModel[i]
                  .sleepChecks
                  .add(SleepCheckModel.fromJson(json['sleepChecks'][j]));
            }
          }
        }
      } catch (e, s) {
        print('getting error at fetch data time');
        print(e);
        print(s.toString());
      }
      if (this.mounted) setState(() {});
    } else {
      MyApp.Show401Dialog(context);
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

  String addSleepMinute = '';
  String addSleepHour = '';
  String addBreathing = '';
  String addTemprature = '';
  TextEditingController addNotesController = TextEditingController(text: '');
  int currentAddIndex = -1;

  addCheckApi2({
    required String childId,
    required String roomId,
  }) async {
    var headers = {
      'Accept': 'application/json',
      'X-Device-Id': 'AP3A.240617.008',
      'X-Token': '68120f5b5c11b'
    };
    var request = http.MultipartRequest('POST',
        Uri.parse('${Constants.BASE_URL}HeadChecks/saveSleepChecklist'));
    request.fields.addAll({
      'userid': MyApp.LOGIN_ID_VALUE,
      'childid': childId,
      "roomid": roomId,
      "time": formatTimeString("$addSleepHour:$addSleepMinute"),
      "diarydate": DateFormat("dd-MM-yyyy").format(date!).toString(),
      "breathing": addBreathing,
      "body_temperature": addTemprature,
      "notes": addNotesController.text
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print('response is =========');
    print(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      _fetchData();
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
    if (this.mounted) setState(() {});
  }

  addCheckApi({
    required String childId,
    required String roomId,
  }) async {
    Map<String, String> data = {
      'userid': MyApp.LOGIN_ID_VALUE,
      'childid': childId,
      "roomid": roomId,
      "time": formatTimeString("$addSleepHour:$addSleepMinute"),
      "diarydate": DateFormat("dd-MM-yyyy").format(date!).toString(),
      "breathing": addBreathing,
      "body_temperature": addTemprature,
      "notes": addNotesController.text
    };

    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data);
    var json = await hlr.addSleepChecks();
    print(json);
    print('=================');
    print(!json.containsKey('error'));
    if (!json.containsKey('error')) {
      MyApp.ShowToast('Added Successfully!', context);
      _fetchData();
    }
    if (this.mounted) setState(() {});
  }

  editCehckApi(
      {required String childId,
      required String roomId,
      required String time,
      required String breathing,
      required String temprature,
      required String notes,
      required String id}) async {
    Map<String, String> data1 = {
      'userid': MyApp.LOGIN_ID_VALUE,
      "id": id,
      'childid': childId.toString(),
      "roomid": roomId.toString(),
      "diarydate": DateFormat("dd-MM-yyyy").format(date!).toString(),
      "time": formatTimeString(time),
      "breathing": breathing,
      "body_temperature": temprature,
      "notes": notes,
    };

    // Map<String, String> data = {
    //   // "userid": "1",
    //   // "id": "36",
    //   'userid': MyApp.LOGIN_ID_VALUE,
    //   "id": id,
    //   // "childid": "2",
    //   // "roomid": "298293519",
    //   'childId': childId.toString(),
    //   "roomid": roomId.toString(),
    //   "diarydate": "01-05-2025",
    //   "time": "23:15",
    //   "breathing": "Regular",
    //   "body_temperature": "Warm",
    //   "notes": "Child sleeping well update the data"
    // };
    // print('$data');
    print('kdjfikejfidif');
    print('$data1');
    // return;

    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data1);
    var json = await hlr.updateSleepChecks();
    if (!json.containsKey('error')) {
      MyApp.ShowToast('Updated Successfully!', context);
      _fetchData();
    }
    if (this.mounted) setState(() {});
  }

  deleteCehckApi({required String id}) async {
    Map<String, String> data = {
      'userid': MyApp.LOGIN_ID_VALUE,
      "id": id,
    };
    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data);
    var json = await hlr.deleteSleepChecks();
    if (!json.containsKey('error')) {
      MyApp.ShowToast('Deleted Successfully!', context);
      _fetchData();
    }
    if (this.mounted) setState(() {});
  }

  Widget addWidget(
    BuildContext context, {
    required String roomId,
    required String childId,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('ADD NEW SLEEP CHECKS', style: Constants.header2),
            ),
            Text(
              'Time',
              style: Constants.head1,
            ),
            SizedBox(height: 5),
            Builder(builder: (context) {
              return Row(
                children: [
                  hours != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  value: hours!.contains(addSleepHour)
                                      ? addSleepHour
                                      : null,
                                  items: hours?.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value + "h"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    // Handle hour change
                                    setState(() {
                                      addSleepHour = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(width: 20),
                  minutes != null
                      ? DropdownButtonHideUnderline(
                          child: Container(
                            height: 40,
                            width: 90,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Center(
                                child: DropdownButton<String>(
                                  value: minutes!.contains(addSleepMinute)
                                      ? addSleepMinute
                                      : null,
                                  items: minutes?.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value + "m"),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    // Handle minute change
                                    setState(() {
                                      addSleepMinute = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              );
            }),
            SizedBox(height: 15),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Breathing',
                      style: Constants.head1,
                    ),
                    SizedBox(height: 5),
                    DropdownButtonHideUnderline(
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * .40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Center(
                            child: DropdownButton<String>(
                              alignment: AlignmentDirectional.centerStart,
                              value: breathingOptions.contains(addBreathing)
                                  ? addBreathing
                                  : null,
                              hint: Text("Select"),
                              items: breathingOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                // Handle breathing change
                                setState(() {
                                  addBreathing = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Temperature',
                      style: Constants.head1,
                    ),
                    SizedBox(height: 5),
                    DropdownButtonHideUnderline(
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * .40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Center(
                            child: DropdownButton<String>(
                              alignment: AlignmentDirectional.centerStart,
                              value: bodyTempOptions.contains(addTemprature)
                                  ? addTemprature
                                  : null,
                              hint: Text("Select"),
                              items: bodyTempOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  addTemprature = value!;
                                });
                                // Handle body temp change
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              'Notes',
              style: Constants.head1,
            ),
            SizedBox(height: 5),
            Container(
              height: 60,
              child: TextField(
                controller: addNotesController,
                maxLines: 2,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 0.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      addCheckApi(childId: childId, roomId: roomId);
                      // Handle Add
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Text(
                          'ADD',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTimeString(String inputTime) {
    try {
      // Remove all non-digit characters and split by h/m
      String cleaned = inputTime.replaceAll(RegExp(r'[^0-9:]'), '');
      List<String> parts = cleaned.split(':');

      if (parts.length != 2) {
        throw FormatException('Invalid time format');
      }

      // Parse hours and minutes
      int hours = int.tryParse(parts[0]) ?? 0;
      int minutes = int.tryParse(parts[1]) ?? 0;

      // Validate ranges
      if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
        throw FormatException('Time values out of range');
      }

      // Format with leading zeros
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      // Return default/error value
      print('Error formatting time: $e');
      return '00:00'; // or throw the exception if you prefer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * .03),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Text(
                    'Sleep Check List',
                    style: Constants.header1,
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Constants.greyColor)),
                    height: 35,
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Text(
                            date != null
                                ? DateFormat("dd-MM-yyyy").format(date!)
                                : '',
                            style:
                                TextStyle(fontSize: 14.0, color: Colors.black),
                          ),
                          Spacer(),
                          GestureDetector(
                              onTap: () async {
                                date = await _selectDate(context, date!);
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
                // Expanded(
                //   child: Container(),
                // ),
                SizedBox(height: 10),
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
                            child: rooms.isEmpty
                                ? null
                                : Center(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: rooms[currentRoomIndex].id,
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
            Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: slipChecksChildModel.length,
                    itemBuilder: (BuildContext context, int parentalIndex) {
                      return Card(
                          child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width:
                                          50, // Double the radius you had (50 x 2)
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(slipChecksChildModel[
                                                              parentalIndex]
                                                          .imageUrl !=
                                                      '' &&
                                                  slipChecksChildModel[
                                                              parentalIndex]
                                                          .imageUrl !=
                                                      'null'
                                              ? Constants.ImageBaseUrl +
                                                  slipChecksChildModel[
                                                          parentalIndex]
                                                      .imageUrl
                                              : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                                        ),
                                        border: Border.all(
                                          color: Colors
                                              .grey, // Optional border color
                                          width: 1.0, // Optional border width
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      slipChecksChildModel[parentalIndex]
                                                  .name !=
                                              null
                                          ? slipChecksChildModel[parentalIndex]
                                              .name
                                          : '',
                                      style: Constants.header2,
                                    ),
                                  ],
                                ),
                              )),
                          Divider(
                            color: Colors.black.withOpacity(.1),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: slipChecksChildModel[parentalIndex]
                                          .sleepChecks
                                          .length +
                                      1,
                                  itemBuilder: (BuildContext context,
                                      int internalIndex) {
                                    return Container(
                                        child: Column(
                                      children: [
                                        Builder(builder: (context) {
                                          if (internalIndex !=
                                              slipChecksChildModel[
                                                      parentalIndex]
                                                  .sleepChecks
                                                  .length)
                                            return Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        'Time',
                                                        style: Constants.head1,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Builder(
                                                          builder: (context) {
                                                        String time =
                                                            slipChecksChildModel[
                                                                    parentalIndex]
                                                                .sleepChecks[
                                                                    internalIndex]
                                                                .time;
                                                        if (parentalIndex ==
                                                            0) {
                                                          print(
                                                              '=======================');
                                                          print(
                                                              time.toString());
                                                        }
                                                        List<String> parts =
                                                            formatTimeString(
                                                                    time)
                                                                .split(":");
                                                        String sleepHour = int
                                                                    .parse(
                                                                        parts[
                                                                            0])
                                                                .toString() +
                                                            "h";
                                                        String sleepMinute = int
                                                                    .parse(
                                                                        parts[
                                                                            1])
                                                                .toString() +
                                                            'm';
                                                        return Row(
                                                          children: [
                                                            hours != null &&
                                                                    slipChecksChildModel[
                                                                            parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .time
                                                                        .isNotEmpty
                                                                ? DropdownButtonHideUnderline(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      width: 80,
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              color: Constants
                                                                                  .greyColor),
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(8))),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                8,
                                                                            right:
                                                                                8),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Builder(builder: (context) {
                                                                            return DropdownButton<String>(
                                                                              //  isExpanded: true,
                                                                              value: (hours != null && hours!.contains(sleepHour)) ? sleepHour : null,
                                                                              items: hours?.map((String value) {
                                                                                return new DropdownMenuItem<String>(
                                                                                  value: value,
                                                                                  child: new Text(value + "h"),
                                                                                );
                                                                              }).toList(),
                                                                              onChanged: (String? value) {
                                                                                sleepHour = value!;
                                                                                slipChecksChildModel[parentalIndex].sleepChecks[internalIndex].time = (sleepHour.replaceAll('h', '')) + ':' + sleepMinute.replaceAll('m', '');

                                                                                setState(() {});
                                                                              },
                                                                            );
                                                                          }),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            Container(
                                                              width: 20,
                                                            ),
                                                            minutes != null &&
                                                                    slipChecksChildModel[
                                                                            parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .time
                                                                        .isNotEmpty
                                                                ? DropdownButtonHideUnderline(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      width: 90,
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              color: Constants
                                                                                  .greyColor),
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(8))),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                8,
                                                                            right:
                                                                                8),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Builder(builder: (context) {
                                                                            return DropdownButton<String>(
                                                                              //  isExpanded: true,
                                                                              value: minutes != null && minutes!.contains(sleepMinute) ? sleepMinute : null,
                                                                              items: minutes?.map((String value) {
                                                                                return new DropdownMenuItem<String>(
                                                                                  value: value,
                                                                                  child: new Text(value + "m"),
                                                                                );
                                                                              }).toList(),
                                                                              onChanged: (String? value) {
                                                                                sleepMinute = value!;
                                                                                slipChecksChildModel[parentalIndex].sleepChecks[internalIndex].time = (sleepHour.replaceAll('h', '')) + ':' + sleepMinute.replaceAll('m', '');
                                                                                // gMin1 =
                                                                                //     value!;
                                                                                setState(() {});
                                                                              },
                                                                            );
                                                                          }),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(),
                                                          ],
                                                        );
                                                      }),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Breathing',
                                                                style: Constants
                                                                    .head1,
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              DropdownButtonHideUnderline(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Constants
                                                                            .greyColor),
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8)),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                8),
                                                                    child:
                                                                        Center(
                                                                      child: DropdownButton<
                                                                          String>(
                                                                        alignment:
                                                                            AlignmentDirectional.centerStart,
                                                                        value: breathingOptions.contains(slipChecksChildModel[parentalIndex].sleepChecks[internalIndex].breathing)
                                                                            ? slipChecksChildModel[parentalIndex].sleepChecks[internalIndex].breathing
                                                                            : null,
                                                                        hint: Text(
                                                                            "Select  "),
                                                                        items: breathingOptions.map((String
                                                                            value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value,
                                                                            child:
                                                                                Text(value),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (String?
                                                                                value) {
                                                                          setState(
                                                                              () {
                                                                            slipChecksChildModel[parentalIndex].sleepChecks[internalIndex].breathing =
                                                                                value!;
                                                                            // selectedBreathing =
                                                                            //     value!;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Expanded(
                                                              child:
                                                                  SizedBox()),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Body Temperatur',
                                                                style: Constants
                                                                    .head1,
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              DropdownButtonHideUnderline(
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Constants
                                                                            .greyColor),
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8)),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                8),
                                                                    child:
                                                                        Center(
                                                                      child: DropdownButton<
                                                                          String>(
                                                                        alignment:
                                                                            AlignmentDirectional.centerStart,
                                                                        value: bodyTempOptions.contains(slipChecksChildModel[parentalIndex].sleepChecks[internalIndex].bodyTemperature)
                                                                            ? slipChecksChildModel[parentalIndex].sleepChecks[internalIndex].bodyTemperature
                                                                            : null,
                                                                        hint: Text(
                                                                            "Select  "),
                                                                        items: bodyTempOptions.map((String
                                                                            value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value,
                                                                            child:
                                                                                Text(value),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (String?
                                                                                value) {
                                                                          setState(
                                                                              () {
                                                                            slipChecksChildModel[parentalIndex].sleepChecks[internalIndex].bodyTemperature =
                                                                                value!;
                                                                            // selectedBreathing =
                                                                            //     value!;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Text(
                                                        'Notes',
                                                        style: Constants.head1,
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Container(
                                                        height: 60,
                                                        child: Builder(
                                                            builder: (context) {
                                                          return TextField(
                                                              controller: TextEditingController(
                                                                  text: slipChecksChildModel[
                                                                          parentalIndex]
                                                                      .sleepChecks[
                                                                          internalIndex]
                                                                      .notes),
                                                              maxLines: 2,
                                                              onChanged:
                                                                  (value) {
                                                                slipChecksChildModel[parentalIndex]
                                                                    .sleepChecks[
                                                                        internalIndex]
                                                                    .notes = value;
                                                              },
                                                              decoration:
                                                                  new InputDecoration(
                                                                enabledBorder:
                                                                    const OutlineInputBorder(
                                                                  borderSide: const BorderSide(
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
                                                              ));
                                                        }),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                top: 10,
                                                                bottom: 10),
                                                        child: Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                editCehckApi(
                                                                    childId: slipChecksChildModel[parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .childId,
                                                                    roomId: slipChecksChildModel[parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .roomId,
                                                                    time: slipChecksChildModel[
                                                                            parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .time,
                                                                    breathing: slipChecksChildModel[
                                                                            parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .breathing,
                                                                    temprature: slipChecksChildModel[
                                                                            parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .bodyTemperature,
                                                                    notes: slipChecksChildModel[
                                                                            parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .notes,
                                                                    id: slipChecksChildModel[
                                                                            parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .id);
                                                              },
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Constants
                                                                          .kButton,
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              8))),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                            12,
                                                                            8,
                                                                            12,
                                                                            8),
                                                                    child: Text(
                                                                      'UPDATE',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  )),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                deleteCehckApi(
                                                                    id: slipChecksChildModel[
                                                                            parentalIndex]
                                                                        .sleepChecks[
                                                                            internalIndex]
                                                                        .id);
                                                              },
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              8))),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                            12,
                                                                            8,
                                                                            12,
                                                                            8),
                                                                    child: Text(
                                                                      'DELETE',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            );
                                          else {
                                            if ((internalIndex ==
                                                    slipChecksChildModel[
                                                            parentalIndex]
                                                        .sleepChecks
                                                        .length &&
                                                currentAddIndex ==
                                                    parentalIndex))
                                              return addWidget(context,
                                                  roomId: slipChecksChildModel[
                                                          parentalIndex]
                                                      .room,
                                                  childId: slipChecksChildModel[
                                                          parentalIndex]
                                                      .id);
                                            else
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'ADD SLEEPCHECKs',
                                                        style:
                                                            Constants.header2,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          addBreathing = '';
                                                          addTemprature = '';
                                                          addNotesController
                                                              .clear();
                                                          addSleepHour = '';
                                                          addSleepMinute = '';

                                                          setState(() {
                                                            currentAddIndex =
                                                                parentalIndex;
                                                          });
                                                          // Handle Add
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    12,
                                                                    8,
                                                                    12,
                                                                    8),
                                                            child: Text(
                                                              'ADD',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                          }
                                        }),
                                      ],
                                    ));
                                  })),
                        ],
                      ));
                    })),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {required TextEditingController controller,
      bool readOnly = false,
      VoidCallback? onTap,
      int maxLines = 1}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSmallField({required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(8),
        ),
      ),
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submitForm() {
    // Handle submission logic here
    print("Submitting form...");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sleep Check List submitted.")),
    );
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

// class SleepCheckForm extends StatelessWidget {
//   final int parentalIndex;
//   final int internalIndex;
//   final List<String>? hours;
//   final List<String>? minutes;
//   final List<String> breathingOptions;
//   final List<String> bodyTempOptions;
//   final Function(String) onTimeUpdated;
//   final Function(String) onBreathingUpdated;
//   final Function(String) onBodyTempUpdated;
//   final Function(String) onNotesUpdated;
//   final VoidCallback onUpdatePressed;
//   final VoidCallback onDeletePressed;
//   final String currentTime;
//   final String currentBreathing;
//   final String currentBodyTemp;
//   final String currentNotes;
//   final TextEditingController notesController;

//   const SleepCheckForm({
//     Key? key,
//     required this.parentalIndex,
//     required this.internalIndex,
//     this.hours,
//     this.minutes,
//     required this.breathingOptions,
//     required this.bodyTempOptions,
//     required this.onTimeUpdated,
//     required this.onBreathingUpdated,
//     required this.onBodyTempUpdated,
//     required this.onNotesUpdated,
//     required this.onUpdatePressed,
//     required this.onDeletePressed,
//     required this.currentTime,
//     required this.currentBreathing,
//     required this.currentBodyTemp,
//     required this.currentNotes,
//     required this.notesController,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Parse current time
//     List<String> parts = currentTime.split(":");
//     String sleepHour = parts.isNotEmpty ? "${int.parse(parts[0])}h" : "0h";
//     String sleepMinute = parts.length > 1 ? "${int.parse(parts[1])}m" : "0m";

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Time Dropdowns
//         Row(
//           children: [
//             if (hours != null && currentTime.isNotEmpty)
//               DropdownButtonHideUnderline(
//                 child: Container(
//                   height: 40,
//                   width: 80,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     color: Colors.white,
//                     borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 8, right: 8),
//                     child: Center(
//                       child: DropdownButton<String>(
//                         value: hours!.contains(sleepHour) ? sleepHour : null,
//                         items: hours!.map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text('${value}h'),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           onTimeUpdated(
//                             '${value!.replaceAll('h', '')}:${sleepMinute.replaceAll('m', '')}',
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(width: 20),
//             if (minutes != null && currentTime.isNotEmpty)
//               DropdownButtonHideUnderline(
//                 child: Container(
//                   height: 40,
//                   width: 90,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     color: Colors.white,
//                     borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 8, right: 8),
//                     child: Center(
//                       child: DropdownButton<String>(
//                         value:
//                             minutes!.contains(sleepMinute) ? sleepMinute : null,
//                         items: minutes!.map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text('${value}m'),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           onTimeUpdated(
//                             '${sleepHour.replaceAll('h', '')}:${value!.replaceAll('m', '')}',
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 15),
//         // Breathing and Temperature Row
//         Row(
//           children: [
//             // Breathing Dropdown
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Breathing'),
//                 const SizedBox(height: 5),
//                 DropdownButtonHideUnderline(
//                   child: Container(
//                     height: 40,
//                     width: MediaQuery.of(context).size.width * .40,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       color: Colors.white,
//                       borderRadius: const BorderRadius.all(Radius.circular(8)),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Center(
//                         child: DropdownButton<String>(
//                           alignment: AlignmentDirectional.centerStart,
//                           value: breathingOptions.contains(currentBreathing)
//                               ? currentBreathing
//                               : null,
//                           hint: const Text("Select"),
//                           items: breathingOptions.map((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             onBreathingUpdated(value!);
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const Expanded(child: SizedBox()),
//             // Body Temperature Dropdown
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Body Temperature'),
//                 const SizedBox(height: 5),
//                 DropdownButtonHideUnderline(
//                   child: Container(
//                     height: 40,
//                     width: MediaQuery.of(context).size.width * .40,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       color: Colors.white,
//                       borderRadius: const BorderRadius.all(Radius.circular(8)),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Center(
//                         child: DropdownButton<String>(
//                           alignment: AlignmentDirectional.centerStart,
//                           value: bodyTempOptions.contains(currentBodyTemp)
//                               ? currentBodyTemp
//                               : null,
//                           hint: const Text("Select"),
//                           items: bodyTempOptions.map((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             onBodyTempUpdated(value!);
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 15),
//         // Notes Field
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Notes'),
//             const SizedBox(height: 5),
//             Container(
//               height: 60,
//               child: TextField(
//                 controller: notesController,
//                 maxLines: 2,
//                 onChanged: onNotesUpdated,
//                 decoration: const InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black26, width: 0.0),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(4)),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         // Action Buttons
//         Padding(
//           padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
//           child: Row(
//             children: [
//               InkWell(
//                 onTap: onUpdatePressed,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.blue, // Replace with your Constants.kButton
//                     borderRadius: BorderRadius.all(Radius.circular(8)),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
//                     child: Text(
//                       'UPDATE',
//                       style: TextStyle(color: Colors.white, fontSize: 14),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               InkWell(
//                 onTap: onDeletePressed,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.all(Radius.circular(8)),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
//                     child: Text(
//                       'DELETE',
//                       style: TextStyle(color: Colors.white, fontSize: 14),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
