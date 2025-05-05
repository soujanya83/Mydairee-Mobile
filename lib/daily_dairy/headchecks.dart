import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/dailydairyapi.dart';
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

    _fetchData();
  }

  Future<void> _fetchData() async {
    Map<String, String> data = {
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': centers![currentIndex].id
    };
    if (roomsFetched) {
      data['roomid'] = rooms![currentRoomIndex].id;
      data['date'] = DateFormat("yyyy-MM-dd").format(date!);
    }
    print(data);
    DailyDairyAPIHandler hlr = DailyDairyAPIHandler(data);
    var dt = await hlr.getHeadChecksData();
    if (!dt.containsKey('error')) {
      print(dt);
      details = dt;
      var res = dt['rooms'];
      rooms = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          rooms!.add(RoomsDescModel.fromJson(res[i]));
        }
        roomsFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    }
    hour.clear();
    comments.clear();
    min.clear();
    signature.clear();
    headCount.clear();

    print('+++++here+1++');
    if (dt['headChecks'] != null && dt['headChecks'].length > 0){
      print('+++++here+2++');
      for (int i = 0; i < dt['headChecks'].length; i++){
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
    setState(() {});
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
              Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: hour.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: [
                                            Text('Time'),
                                            Spacer(),
                                            IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: () {
                                                  hour.add("1h");
                                                  min.add("0m");

                                                  comments.add(
                                                      TextEditingController());
                                                  signature.add(
                                                      TextEditingController());
                                                  headCount.add(
                                                      TextEditingController());
                                                  setState(() {});
                                                }),
                                            index == 0
                                                ? Container()
                                                : IconButton(
                                                    icon: Icon(
                                                      Icons.remove,
                                                    ),
                                                    onPressed: () {
                                                      hour.removeAt(index);
                                                      min.removeAt(index);

                                                      comments.removeAt(index);
                                                      signature.removeAt(index);
                                                      headCount.removeAt(index);
                                                      setState(() {});
                                                    }),
                                          ],
                                        ),
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
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8),
                                                      child: Center(
                                                        child: DropdownButton<
                                                            String>(
                                                          //  isExpanded: true,
                                                          value: hour[index],
                                                          items: hours!.map(
                                                              (String value) {
                                                            return new DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: new Text(
                                                                  value),
                                                            );
                                                          }).toList(),
                                                          onChanged:
                                                              (String? value) {
                                                            if (value == null)
                                                              return;
                                                            hour[index] =
                                                                value!;
                                                            setState(() {});
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
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8),
                                                      child: Center(
                                                        child: DropdownButton<
                                                            String>(
                                                          //  isExpanded: true,
                                                          value: min[index],
                                                          items: minutes?.map(
                                                              (String value) {
                                                            return new DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: new Text(
                                                                  value),
                                                            );
                                                          }).toList(),
                                                          onChanged:
                                                              (String? value) {
                                                            if (value == null)
                                                              return;
                                                            min[index] = value!;
                                                            setState(() {});
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
                                      Text('Head Count'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        height: 40,
                                        child: TextField(
                                            maxLines: 1,
                                            keyboardType: TextInputType.number,
                                            controller: headCount[index],
                                            decoration: new InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black26,
                                                    width: 0.0),
                                              ),
                                              border: new OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(4),
                                                ),
                                              ),
                                            )),
                                      ),
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
                                            controller: signature[index],
                                            decoration: new InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black26,
                                                    width: 0.0),
                                              ),
                                              border: new OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(4),
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
                                            controller: comments[index],
                                            decoration: new InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black26,
                                                    width: 0.0),
                                              ),
                                              border: new OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(4),
                                                ),
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ]))));
                      })),
              SizedBox(
                height: 15,
              ),
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
                            "diarydate": DateFormat("yyyy-MM-dd").format(date!),
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
                          MyApp.ShowToast("updated", context);
                          Navigator.pop(context, 'kill');
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
