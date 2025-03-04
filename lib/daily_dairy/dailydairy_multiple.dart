import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/hexconversion.dart';
import 'package:http/http.dart' as http;

class DailyDairyMultiple extends StatefulWidget {
  final ChildModel child;
  final String type;
  final Map details;

  DailyDairyMultiple(this.child, this.type, this.details);

  @override
  _DailyDairyMultipleState createState() => _DailyDairyMultipleState();
}

class _DailyDairyMultipleState extends State<DailyDairyMultiple> {
  List<String> hour = [];
  List<String> hour2 = [];
  List<String> min = [];
  List<String> min2 = [];

  List<TextEditingController> controller = [];
  bool loaded = false;
  int len = 0;

  List<String>? hours;
  List<String>? minutes;

  @override
  void initState() {
    hours = List<String>.generate(12, (counter) => "${counter + 1}h");
    minutes = List<String>.generate(60, (counter) => "${counter}m");
    _load();
    super.initState();
  }

  Future<void> _load() async {
    if (!loaded && widget.type == 'Sleep') {
      len = widget.child.sleep.length;
      for (var i = 0; i < len; i++) {
        var time = widget.child.sleep[i]['startTime'].toString().split(":");
        var time2 = widget.child.sleep[i]['endTime'].toString().split(":");
        hour.add(time[0]);
        min.add(time[1]);
        hour2.add(time2[0]);
        min2.add(time2[1]);
        controller.add(
            TextEditingController(text: widget.child.sleep[i]['comments']));
      }
    }

    if (!loaded && widget.type == 'Sunscreen') {
      len = widget.child.sunscreen.length;
      for (var i = 0; i < len; i++) {
        var time = widget.child.sunscreen[i]['startTime'].toString().split(":");
        hour.add(time[0]);
        min.add(time[1]);
        controller.add(
            TextEditingController(text: widget.child.sunscreen[i]['comments']));
      }
    }

    loaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header.appBar(),
        body: Stack(children: [
          SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          'Daily Dairy',
                          style: Constants.header1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: HexColor(widget.details['roomcolor']),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text(
                                  widget.type,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        loaded && widget.type == 'Sleep'
                            ? Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: len,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Row(
                                                    children: [
                                                      Text('Time'),
                                                      Spacer(),
                                                      IconButton(
                                                          icon: Icon(Icons.add),
                                                          onPressed: () {
                                                            len = len + 1;
                                                            hour.add("1h");
                                                            min.add("0m");
                                                            hour2.add("1h");
                                                            min2.add("0m");
                                                            controller.add(
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
                                                                len = len - 1;
                                                                hour.removeAt(
                                                                    index);
                                                                min.removeAt(
                                                                    index);
                                                                hour2.removeAt(
                                                                    index);
                                                                min2.removeAt(
                                                                    index);
                                                                controller
                                                                    .removeAt(
                                                                        index);
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
                                                                    value: hour[
                                                                        index],
                                                                    items: hours
                                                                        ?.map((String
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
                                                                      hour[index] =
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
                                                                    value: min[
                                                                        index],
                                                                    items: minutes
                                                                        ?.map((String
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
                                                                      min[index] =
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
                                                                    value: hour2[
                                                                        index],
                                                                    items: hours
                                                                        ?.map((String
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
                                                                      hour2[index] =
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
                                                                    value: min2[
                                                                        index],
                                                                    items: minutes
                                                                        ?.map((String
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
                                                                      min2[index] =
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
                                                      controller:
                                                          controller[index],
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Container(),
                        loaded && widget.type == 'Sunscreen'
                            ? Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: len,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Row(
                                                    children: [
                                                      Text('Time'),
                                                      Spacer(),
                                                      IconButton(
                                                          icon: Icon(Icons.add),
                                                          onPressed: () {
                                                            len = len + 1;
                                                            hour.add("1h");
                                                            min.add("0m");
                                                            controller.add(
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
                                                                len = len - 1;
                                                                hour.removeAt(
                                                                    index);
                                                                min.removeAt(
                                                                    index);
                                                                controller
                                                                    .removeAt(
                                                                        index);
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
                                                                    value: hour[
                                                                        index],
                                                                    items: hours
                                                                        ?.map((String
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
                                                                      hour[index] =
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
                                                                    value: min[
                                                                        index],
                                                                    items: minutes
                                                                        ?.map((String
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
                                                                      min[index] =
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
                                                      controller:
                                                          controller[index],
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Container(),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var _toSend = Constants.BASE_URL +
                                      'dailyDiary/addMultiSunscreenRecord';
                                  List data = [];
                                  for (var i = 0; i < len; i++) {
                                    data.add({
                                      "startTime": hour[i] + ":" + min[i],
                                      "comments": controller[i].text.toString(),
                                      "createdAt": DateTime.now().toString(),
                                      "childid": widget.child.id,
                                      "dairydate": DateTime.now().toString(),
                                      "userid": MyApp.LOGIN_ID_VALUE,
                                    });
                                  }
                                  var objToSend = {
                                    "userid": MyApp.LOGIN_ID_VALUE,
                                    "sunscreen": data
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
                                    MyApp.ShowToast("updated", context);
                                    Navigator.pop(context, 'kill');
                                  } else if (response.statusCode == 401) {
                                    MyApp.Show401Dialog(context);
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
                      ]))))
        ]));
  }
}
