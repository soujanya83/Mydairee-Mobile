import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/progressnotes.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/progressrecord.dart';
import 'package:mykronicle_mobile/progress_notes/add_progress_notes.dart';
import 'package:mykronicle_mobile/progress_notes/edit_progress_note.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:http/http.dart' as http;

class ProgressNotesActivity extends StatefulWidget {
  final String childid;

  ProgressNotesActivity({required this.childid});
  @override
  _ProgressNotesActivityState createState() => _ProgressNotesActivityState();
}

class _ProgressNotesActivityState extends State<ProgressNotesActivity> {
  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

  List<Records> _records;
  bool recordFetched = false;
  var details;

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
      //MyApp.Show401Dialog(context);
    }
    _load();
  }

  Future<void> _load() async {
    Map<String, String> data = {
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': centers[currentIndex].id,
    };
    ProgramNotesApiHandler hlr = ProgramNotesApiHandler(data);
    var adt = await hlr.getDetails();
    print(adt);
    print("object1");
    if (!adt.containsKey('error')) {
      details = adt;
      print("details1");
      print(details);
      var res = adt['records'];
      _records = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
           Records record=Records.fromJson(res[i]);
           if(record.childid==widget.childid){
              _records.add(record);
           }
        }
        recordFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress Notes',
                  style: Constants.header1,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddProgressNotesActivity(
                                  centerid: centers[currentIndex].id,
                                  childid: widget.childid,
                                ))).then((value) {
                      details = null;
                      _load();
                    });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Constants.kButton,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        child: Text(
                          'Add New',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            centersFetched
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 3.0, right: 3, bottom: 3),
                    child: DropdownButtonHideUnderline(
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            border: Border.all(color: Constants.greyColor),
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(8))),
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
                                      details = null;
                                      _load();
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
                  )
                : Container(),
            details != null
                ? Expanded(
                    child: recordFetched
                        ? ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: _records.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 8, 5, 10),
                                      child: Row(
                                        children: [
                                          _records[index].image != '' &&
                                                  _records[index].image != null
                                              ? CircleAvatar(
                                                  radius: 30.0,
                                                  backgroundImage: NetworkImage(
                                                      Constants.ImageBaseUrl +
                                                          _records[index]
                                                              .image),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                )
                                              : CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: Colors.grey,
                                                ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _records[index].name,
                                                style: Constants.header4,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      color: Constants.kprogresscard,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 10),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditProgressNotesActivity(
                                                                centerid: centers[
                                                                        currentIndex]
                                                                    .id,
                                                                childid: widget
                                                                    .childid,
                                                                pnid: _records[
                                                                        index]
                                                                    .id,
                                                                phydevelopment:
                                                                    _records[
                                                                            index]
                                                                        .pDevelopment,
                                                                emodeveloment:
                                                                    _records[
                                                                            index]
                                                                        .emotionDevelopment,
                                                                scodeveloment:
                                                                    _records[
                                                                            index]
                                                                        .socialDevelopment,
                                                                childinter: _records[
                                                                        index]
                                                                    .childInterests,
                                                                othergoal: _records[
                                                                        index]
                                                                    .otherGoal,
                                                              ))).then((value) {
                                                    details = null;
                                                    _load();
                                                  });
                                                },
                                                child: Icon(Icons.edit),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                return showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: new Text(
                                                          "Delete Note"),
                                                      content: new Text(
                                                          "Are you sure you want to delete note"),
                                                      actions: <Widget>[
                                                        new TextButton(
                                                          child: new Text(
                                                              "Cancel"),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        new TextButton(
                                                          child: new Text("Ok"),
                                                          onPressed: () async {
                                                            var _toSend = Constants
                                                                    .BASE_URL +
                                                                'ProgressNotes/deleteProgressNote';
                                                            var objTOSend = {
                                                              "userid": MyApp
                                                                  .LOGIN_ID_VALUE,
                                                              "pnid": _records[
                                                                      index]
                                                                  .id,
                                                            };
                                                            final response =
                                                                await http.post(
                                                                    Uri.parse(_toSend),
                                                                    body: jsonEncode(
                                                                        objTOSend),
                                                                    headers: {
                                                                  "X-DEVICE-ID":
                                                                      await MyApp
                                                                          .getDeviceIdentity(),
                                                                  "X-TOKEN": MyApp
                                                                      .AUTH_TOKEN_VALUE,
                                                                });
                                                            print(
                                                                response.body);
                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              details = null;
                                                              setState(() {});
                                                              _load();
                                                              Navigator.pop(
                                                                  context);
                                                              MyApp.ShowToast(
                                                                  "deleted",
                                                                  context);
                                                            } else if (response
                                                                    .statusCode ==
                                                                401) {
                                                              MyApp
                                                                  .Show401Dialog(
                                                                      context);
                                                            }
                                                          },
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(Icons.delete),
                                            ),
                                            Expanded(
                                              child: Container(),
                                            ),
                                            Text(
                                              DateFormat('dd/MM/yyyy')
                                                  .format(DateTime.parse(
                                                      _records[index]
                                                          .createdAt))
                                                  .toString(),
                                              style: Constants.header4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                        : Container())
                : Container()
          ],
        ),
      )),
    );
  }
}
