import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/dailydairyapi.dart';
import 'package:mykronicle_mobile/api/roomsapi.dart' show RoomAPIHandler;
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:intl/intl.dart';

class HeadChecks extends StatefulWidget {
  @override
  _HeadChecksState createState() => _HeadChecksState();
}

class _HeadChecksState extends State<HeadChecks> {
  List<String>? hours;
  List<String>? minutes;

  List<String> hour = [];
  List<String> min = [];

  DateTime? date;
  List<CentersModel>? centers;
  bool centersFetched = false;
  int currentIndex = 0;

  List<TextEditingController> comments = [];

  List<TextEditingController> signature = [];

  List<TextEditingController> headCount = [];

  List<RoomsDescModel>? rooms;
  bool roomsFetched = false;

  int currentRoomIndex = 0;
  var details;

  @override
  void initState() {
    date = DateTime.now();

    hours = List<String>.generate(12, (counter) => "${counter + 1}h");
    minutes = List<String>.generate(60, (counter) => "${counter}m");

    _fetchCenters();
    super.initState();
  }

  void dispose() {
    // Clean up all controllers
    for (var controller in comments) {
      controller.dispose();
    }
    for (var controller in signature) {
      controller.dispose();
    }
    for (var controller in headCount) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      hour.add("1h");
      min.add("0m");
      comments.add(TextEditingController());
      signature.add(TextEditingController());
      headCount.add(TextEditingController());
    });
  }

  void _removeEntry(int index) {
    setState(() {
      hour.removeAt(index);
      min.removeAt(index);
      comments.removeAt(index).dispose();
      signature.removeAt(index).dispose();
      headCount.removeAt(index).dispose();
    });
  }

  void _updateHour(int index, String? value) {
    setState(() {
      hour[index] = value ?? "1h";
    });
  }

  void _updateMin(int index, String? value) {
    setState(() {
      min[index] = value ?? "0m";
    });
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
          centers?.add(CentersModel.fromJson(res[i]));
        }
        centersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      RoomAPIHandler handler = RoomAPIHandler({
        "userid": MyApp.LOGIN_ID_VALUE,
        "centerid": centers![currentIndex].id, // ✅ Use correct center id
      });

      var data = await handler.getList();
      print('=======data==1========');
      print(data.toString());
      if (data != null && !data.containsKey('error')) {
        print('=======data==2========');
        print(data.toString());
        var res = data['rooms'];
        rooms = [];
        try {
          assert(res is List);
          for (int i = 0; i < res.length; i++) {
            rooms!.add(RoomsDescModel.fromJson(res[i]));
          }
          currentRoomIndex = 0;
          roomsFetched = true;
          _fetchData();
        } catch (e) {
          print(e);
        }
      } else {
        print("Error in API: $data");
      }
    } catch (e, s) {
      print("Exception in fetchRoomsOnly: $e");
      print(s);
    }
    if (this.mounted) setState(() {});
  }

  bool loading = true;

  Future<void> _fetchData() async {
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }
    Map<String, String> data = {
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': centers![currentIndex].id
    };
    if (roomsFetched && rooms != null && rooms!.isNotEmpty) {
      data['roomid'] = rooms![currentRoomIndex].id;
    }
    data['date'] = DateFormat("yyyy-MM-dd").format(date!);
    print(data);
    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data);
    var dt = await hlr.getHeadChecksData();
    hour.clear();
    comments.clear();
    min.clear();
    signature.clear();
    headCount.clear();
    print('===============');
    debugPrint(dt.toString());
    print('+++++here+1++');
    if (dt['headChecks'] != null && dt['headChecks'].length > 0) {
      print('+++++here+2++');
      for (int i = 0; i < dt['headChecks'].length; i++) {
        var time = dt['headChecks'][i]['time'].toString().split(":");
        hour.add(time[0]);
        min.add(time[1]);
        comments
            .add(TextEditingController(text: dt['headChecks'][i]['comments']));
        signature
            .add(TextEditingController(text: dt['headChecks'][i]['signature']));
        headCount
            .add(TextEditingController(text: dt['headChecks'][i]['headcount']));
      }
    } else {
      print('+++++here+3++');
      ////
      hour.add("1h");
      min.add("0m");
      comments.add(TextEditingController());
      signature.add(TextEditingController());
      headCount.add(TextEditingController());
    }
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: floating(context),
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Text(
                      'Head Checks',
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
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                            Spacer(),
                            GestureDetector(
                                onTap: () async {
                                  date = await _selectDate(context, date!);
                                  details = null;
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
                                  value: centers![currentIndex].id,
                                  items: centers?.map((CentersModel value) {
                                    return new DropdownMenuItem<String>(
                                      value: value.id,
                                      child: new Text(value.centerName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    for (int i = 0; i < centers!.length; i++) {
                                      if (centers![i].id == value) {
                                        setState(() {
                                          currentIndex = i;
                                          details = null;
                                          fetchRooms();
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
                  roomsFetched && rooms != null && rooms!.isNotEmpty
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
                                  value: rooms![currentRoomIndex].id,
                                  items: rooms!.map((RoomsDescModel value) {
                                    return new DropdownMenuItem<String>(
                                      value: value.id,
                                      child: new Text(value.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    for (int i = 0; i < rooms!.length; i++) {
                                      if (rooms?[i].id == value) {
                                        setState(() {
                                          currentRoomIndex = i;
                                          details = null;
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
              loading
                  ? Container(
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
                      ))
                  : Container(
                      child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: hour.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TimeEntryCard(
                          index: index,
                          hour: hour,
                          min: min,
                          comments: comments,
                          signature: signature,
                          headCount: headCount,
                          hours: hours,
                          minutes: minutes,
                          onAdd: index == hour.length - 1 ? _addEntry : null,
                          onRemove: hour.length > 1
                              ? () => _removeEntry(index)
                              : null,
                          onHourChanged: (value) => _updateHour(index, value),
                          onMinChanged: (value) => _updateMin(index, value),
                        );
                      },
                    )),
              SizedBox(
                height: 15,
              ),
              if (!loading)
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                          var _toSend =
                              Constants.BASE_URL + 'HeadChecks/addHeadChecks';
                          List data = [];
                          print('lll' + comments.length.toString());
                          for (var i = 0; i < comments.length; i++) {
                            data.add({
                              "time": hour[i] + ":" + min[i],
                              "headCount": headCount[i].text.toString(),
                              "signature": signature[i].text.toString(),
                              "comments": comments[i].text.toString(),
                              "roomid": rooms![currentRoomIndex].id.toString(),
                              "createdAt": DateTime.now().toString(),
                              "diarydate":
                                  DateFormat("yyyy-MM-dd").format(date!),
                              "createdBy": MyApp.LOGIN_ID_VALUE,
                            });
                          }
                          var objToSend = {
                            "userid": MyApp.LOGIN_ID_VALUE,
                            "headcounts": data
                          };

                          print(jsonEncode(objToSend));
                          final response = await http.post(Uri.parse(_toSend),
                              body: jsonEncode(objToSend),
                              headers: {
                                'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                                'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                              });
                          print('heyyy' + response.body.toString());
                          if (response.statusCode == 200) {
                            MyApp.ShowToast("Save Successfully!", context);
                          } else if (response.statusCode == 401) {
                            MyApp.Show401Dialog(context);
                          }
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
                ),
            ],
          ),
        ),
      )),
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

class TimeEntryCard extends StatelessWidget {
  final int index;
  final List<String> hour;
  final List<String> min;
  final List<TextEditingController> comments;
  final List<TextEditingController> signature;
  final List<TextEditingController> headCount;
  final List<String>? hours;
  final List<String>? minutes;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final ValueChanged<String?> onHourChanged;
  final ValueChanged<String?> onMinChanged;

  const TimeEntryCard({
    Key? key,
    required this.index,
    required this.hour,
    required this.min,
    required this.comments,
    required this.signature,
    required this.headCount,
    this.hours,
    this.minutes,
    this.onAdd,
    this.onRemove,
    required this.onHourChanged,
    required this.onMinChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  'Time Entry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Spacer(),
                if (onAdd != null)
                  _buildIconButton(
                    icon: Icons.add,
                    color: Theme.of(context).primaryColor,
                    onPressed: onAdd,
                  ),
                if (onRemove != null) SizedBox(width: 8),
                if (onRemove != null)
                  _buildIconButton(
                    icon: Icons.remove,
                    color: Colors.red.shade400,
                    onPressed: onRemove,
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Time Selection
          Row(
            children: [
              if (hours != null)
                _buildTimeDropdown(
                  value: hour[index],
                  items: hours!,
                  onChanged: onHourChanged,
                  label: 'Hours',
                ),
              SizedBox(width: 16),
              if (minutes != null)
                _buildTimeDropdown(
                  value: min[index],
                  items: minutes!,
                  onChanged: onMinChanged,
                  label: 'Minutes',
                ),
            ],
          ),
          SizedBox(height: 20),

          // Head Count
          _buildSectionLabel('Head Count'),
          SizedBox(height: 8),
          _buildInputField(
            controller: headCount[index],
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),

          // Signature
          _buildSectionLabel('Signature'),
          SizedBox(height: 8),
          _buildInputField(controller: signature[index]),
          SizedBox(height: 20),

          // Comments
          _buildSectionLabel('Comments'),
          SizedBox(height: 8),
          _buildInputField(
            controller: comments[index],
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int minLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Constants.kButton),
        ),
      ),
    );
  }

  Widget _buildTimeDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: value,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down),
              borderRadius: BorderRadius.circular(8),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color),
        onPressed: onPressed,
        padding: EdgeInsets.all(6),
        constraints: BoxConstraints(),
      ),
    );
  }
}
