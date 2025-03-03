import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/assignmenteylfapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/eylfmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;

class EylfAssignmentSettings extends StatefulWidget {
  @override
  _EylfAssignmentSettingsState createState() => _EylfAssignmentSettingsState();
}

class _EylfAssignmentSettingsState extends State<EylfAssignmentSettings>
    with TickerProviderStateMixin {
  TabController _controller;

  List<EylfOutcomeModel> eylfData;

  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

  @override
  void initState() {
    _controller = new TabController(length: 5, vsync: this);
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
    _fetchData();
  }

  Future<void> _fetchData() async {
    AssignmentEylfAPIHandler hlr = AssignmentEylfAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var dt = await hlr.getEylfData();
    if (!dt.containsKey('error')) {
      print(dt);
      var eyData = dt['Outcomes'];
      eylfData = [];
      if (eyData != null) {
        for (int a = 0; a < eyData.length; a++) {
          EylfOutcomeModel eylfOutcomeModel =
              EylfOutcomeModel.fromJson(eyData[a]);
          List<EylfActivityModel> activityModel = [];
          for (int b = 0; b < eyData[a]['activities'].length; b++) {
            EylfActivityModel act =
                EylfActivityModel.fromJson(eyData[a]['activities'][b]);
            List<EylfSubActivityModel> subActivityModel = [];
            for (int c = 0;
                c < eyData[a]['activities'][b]['subactivity'].length;
                c++) {
              subActivityModel.add(EylfSubActivityModel.fromJson(
                  eyData[a]['activities'][b]['subactivity'][c]));
            }
            act.subActivity = subActivityModel;
            activityModel.add(act);
          }
          eylfOutcomeModel.activity = activityModel;
          eylfData.add(eylfOutcomeModel);
        }
      }

      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assesment Settings',
                style: Constants.header1,
              ),
              SizedBox(
                height: 12,
              ),
              if (centersFetched)
                DropdownButtonHideUnderline(
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]),
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
              new Container(
                // decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
                child: new TabBar(
                  controller: _controller,
                  labelColor: Constants.kMain,
                  isScrollable: true,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    new Tab(
                      text: 'Outcome 1',
                    ),
                    new Tab(
                      text: 'Outcome 2',
                    ),
                    new Tab(
                      text: 'Outcome 3',
                    ),
                    new Tab(
                      text: 'Outcome 4',
                    ),
                    new Tab(
                      text: 'Outcome 5',
                    ),
                  ],
                ),
              ),
              if (eylfData != null)
                new Container(
                    height: MediaQuery.of(context).size.height - 210,
                    child: new TabBarView(
                        controller: _controller,
                        children: List.generate(
                            5,
                            (index) => SingleChildScrollView(
                                    child: Container(
                                        child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Container(
                                            width: 200,
                                            child: Text(
                                              eylfData[index].name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            TextEditingController controller =
                                                TextEditingController();
                                            showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            "Add New Activity"),
                                                        content:
                                                            SingleChildScrollView(
                                                          child: Container(
                                                            height:
                                                                //  MediaQuery.of(
                                                                //             context)
                                                                //         .size
                                                                //         .height *
                                                                120,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.7,
                                                            child: ListView(
                                                              children: [
                                                                Text(
                                                                  'Title',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                TextField(
                                                                  controller:
                                                                      controller,
                                                                  decoration:
                                                                      InputDecoration(
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
                                                                            .circular(4),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              if (controller
                                                                      .text !=
                                                                  '') {
                                                                print(controller
                                                                    .text);

                                                                AssignmentEylfAPIHandler
                                                                    assesmentEylfAPIHandler =
                                                                    AssignmentEylfAPIHandler({
                                                                  "outcome":
                                                                      eylfData[
                                                                              index]
                                                                          .id,
                                                                  "activity":
                                                                      "",
                                                                  "centerid":
                                                                      centers[currentIndex]
                                                                          .id,
                                                                  "title":
                                                                      controller
                                                                          .text,
                                                                  "userid": MyApp
                                                                      .LOGIN_ID_VALUE
                                                                });
                                                                var data =
                                                                    await assesmentEylfAPIHandler
                                                                        .saveEylfActivityData();
                                                                if (data[
                                                                        'Status'] ==
                                                                    'SUCCESS') {
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              } else {
                                                                MyApp.ShowToast(
                                                                    'Title should not be empty',
                                                                    context);
                                                              }
                                                            },
                                                            child: Text(
                                                              'ok',
                                                              style: TextStyle(
                                                                  fontSize: 18),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    })
                                                .then((value) => _fetchData());
                                          },
                                          child: Text('+ Add Activity'))
                                    ],
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          eylfData[index].activity.length,
                                      itemBuilder: (context, i) {
                                        return Card(
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Transform.translate(
                                                  offset: Offset(-20, 0),
                                                  child: ListTile(
                                                    leading: Checkbox(
                                                      value: eylfData[index]
                                                              .activity[i]
                                                              .checked ==
                                                          'checked',
                                                      onChanged: (val) {
                                                        if (val) {
                                                          eylfData[index]
                                                                  .activity[i]
                                                                  .checked =
                                                              'checked';
                                                        } else {
                                                          eylfData[index]
                                                              .activity[i]
                                                              .checked = '';
                                                        }
                                                        setState(() {});
                                                      },
                                                    ),
                                                    title: Transform.translate(
                                                      offset: Offset(-10, 0),
                                                      child: Text(
                                                          eylfData[index]
                                                              .activity[i]
                                                              .title),
                                                    ),
                                                    trailing:
                                                        MyApp.LOGIN_ID_VALUE ==
                                                                eylfData[index]
                                                                    .activity[i]
                                                                    .addedBy
                                                            ? Container(
                                                                width: 75,
                                                                child: Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          TextEditingController
                                                                              controller =
                                                                              TextEditingController();
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: Text("Add Sub Activity"),
                                                                                  content: SingleChildScrollView(
                                                                                    child: Container(
                                                                                      height: 120,
                                                                                      width: MediaQuery.of(context).size.width * 0.7,
                                                                                      child: ListView(
                                                                                        children: [
                                                                                          Text(
                                                                                            'Title',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 15,
                                                                                          ),
                                                                                          TextField(
                                                                                            controller: controller,
                                                                                            decoration: InputDecoration(
                                                                                              enabledBorder: const OutlineInputBorder(
                                                                                                borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                              ),
                                                                                              border: new OutlineInputBorder(
                                                                                                borderRadius: const BorderRadius.all(
                                                                                                  const Radius.circular(4),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  actions: <Widget>[
                                                                                    TextButton(
                                                                                      onPressed: () async {
                                                                                        if (controller.text != '') {
                                                                                          print(controller.text);

                                                                                          AssignmentEylfAPIHandler assesmentEylfAPIHandler = AssignmentEylfAPIHandler({
                                                                                            "subactivity": "",
                                                                                            "activity": eylfData[index].activity[i].id,
                                                                                            "centerid": centers[currentIndex].id,
                                                                                            "title": controller.text,
                                                                                            "userid": MyApp.LOGIN_ID_VALUE
                                                                                          });
                                                                                          var data = await assesmentEylfAPIHandler.saveEylfSubActivityData();
                                                                                          if (data['Status'] == 'SUCCESS') {
                                                                                            Navigator.pop(context);
                                                                                          }
                                                                                        } else {
                                                                                          MyApp.ShowToast('Title should not be empty', context);
                                                                                        }
                                                                                      },
                                                                                      child: Text(
                                                                                        'ok',
                                                                                        style: TextStyle(fontSize: 18),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              }).then((value) => _fetchData());
                                                                        },
                                                                        child: Icon(
                                                                            Icons.add)),
                                                                    GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          TextEditingController
                                                                              controller =
                                                                              TextEditingController(text: eylfData[index].activity[i].title);
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: Text("Edit Activity"),
                                                                                  content: SingleChildScrollView(
                                                                                    child: Container(
                                                                                      height:
                                                                                          //  MediaQuery.of(
                                                                                          //             context)
                                                                                          //         .size
                                                                                          //         .height *
                                                                                          120,
                                                                                      width: MediaQuery.of(context).size.width * 0.7,
                                                                                      child: ListView(
                                                                                        children: [
                                                                                          Text(
                                                                                            'Title',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 15,
                                                                                          ),
                                                                                          TextField(
                                                                                            controller: controller,
                                                                                            decoration: InputDecoration(
                                                                                              enabledBorder: const OutlineInputBorder(
                                                                                                borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                              ),
                                                                                              border: new OutlineInputBorder(
                                                                                                borderRadius: const BorderRadius.all(
                                                                                                  const Radius.circular(4),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  actions: <Widget>[
                                                                                    TextButton(
                                                                                      onPressed: () async {
                                                                                        if (controller.text != '') {
                                                                                          print(controller.text);

                                                                                          AssignmentEylfAPIHandler assesmentEylfAPIHandler = AssignmentEylfAPIHandler({
                                                                                            "outcome": eylfData[index].id,
                                                                                            "activity": eylfData[index].activity[i].id,
                                                                                            "centerid": centers[currentIndex].id,
                                                                                            "title": controller.text,
                                                                                            "userid": MyApp.LOGIN_ID_VALUE
                                                                                          });
                                                                                          var data = await assesmentEylfAPIHandler.saveEylfActivityData();
                                                                                          if (data['Status'] == 'SUCCESS') {
                                                                                            MyApp.ShowToast('edited successfully', context);
                                                                                            Navigator.pop(context);
                                                                                          }
                                                                                        } else {
                                                                                          MyApp.ShowToast('Title should not be empty', context);
                                                                                        }
                                                                                      },
                                                                                      child: Text(
                                                                                        'ok',
                                                                                        style: TextStyle(fontSize: 18),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              }).then((value) => _fetchData());
                                                                        },
                                                                        child: Icon(
                                                                            Icons.edit)),
                                                                    GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          AssignmentEylfAPIHandler
                                                                              assignmentEylfAPIHandler =
                                                                              AssignmentEylfAPIHandler({
                                                                            "id":
                                                                                eylfData[index].activity[i].id,
                                                                            "centerid":
                                                                                centers[currentIndex].id,
                                                                            "userid":
                                                                                MyApp.LOGIN_ID_VALUE
                                                                          });
                                                                          var data =
                                                                              await assignmentEylfAPIHandler.delEylfActivityData();
                                                                          if (data['Status'] ==
                                                                              'SUCCESS') {
                                                                            MyApp.ShowToast('Successfully Deleted',
                                                                                context);
                                                                            _fetchData();
                                                                          }
                                                                        },
                                                                        child: Icon(
                                                                            Icons.delete)),
                                                                  ],
                                                                ),
                                                              )
                                                            : null,
                                                  ),
                                                ),
                                                ListView.builder(
                                                    itemCount: eylfData[index]
                                                        .activity[i]
                                                        .subActivity
                                                        .length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemBuilder: (context, j) {
                                                      return ListTile(
                                                        title: Text(
                                                            eylfData[index]
                                                                .activity[i]
                                                                .subActivity[j]
                                                                .title),
                                                        leading: Checkbox(
                                                          value: eylfData[index]
                                                                  .activity[i]
                                                                  .subActivity[
                                                                      j]
                                                                  .checked ==
                                                              'checked',
                                                          onChanged: (val) {
                                                            if (val) {
                                                              eylfData[index]
                                                                      .activity[i]
                                                                      .subActivity[
                                                                          j]
                                                                      .checked =
                                                                  'checked';
                                                            } else {
                                                              eylfData[index]
                                                                  .activity[i]
                                                                  .subActivity[
                                                                      j]
                                                                  .checked = '';
                                                            }
                                                            setState(() {});
                                                          },
                                                        ),
                                                        trailing: Container(
                                                          width: 60,
                                                          child: eylfData[index]
                                                                      .activity[
                                                                          i]
                                                                      .subActivity[
                                                                          j]
                                                                      .addedBy ==
                                                                  MyApp
                                                                      .LOGIN_ID_VALUE
                                                              ? Row(
                                                                  children: [
                                                                    GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          TextEditingController
                                                                              controller =
                                                                              TextEditingController(text: eylfData[index].activity[i].subActivity[j].title);
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: Text("Edit Sub Activity"),
                                                                                  content: SingleChildScrollView(
                                                                                    child: Container(
                                                                                      height: 120,
                                                                                      width: MediaQuery.of(context).size.width * 0.7,
                                                                                      child: ListView(
                                                                                        children: [
                                                                                          Text(
                                                                                            'Title',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 15,
                                                                                          ),
                                                                                          TextField(
                                                                                            controller: controller,
                                                                                            decoration: InputDecoration(
                                                                                              enabledBorder: const OutlineInputBorder(
                                                                                                borderSide: const BorderSide(color: Colors.black26, width: 0.0),
                                                                                              ),
                                                                                              border: new OutlineInputBorder(
                                                                                                borderRadius: const BorderRadius.all(
                                                                                                  const Radius.circular(4),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  actions: <Widget>[
                                                                                    TextButton(
                                                                                      onPressed: () async {
                                                                                        if (controller.text != '') {
                                                                                          print(controller.text);

                                                                                          AssignmentEylfAPIHandler assesmentEylfAPIHandler = AssignmentEylfAPIHandler({
                                                                                            "subactivity": eylfData[index].activity[i].subActivity[j].id,
                                                                                            "activity": eylfData[index].activity[i].id,
                                                                                            "centerid": centers[currentIndex].id,
                                                                                            "title": controller.text,
                                                                                            "userid": MyApp.LOGIN_ID_VALUE
                                                                                          });
                                                                                          var data = await assesmentEylfAPIHandler.saveEylfSubActivityData();
                                                                                          if (data['Status'] == 'SUCCESS') {
                                                                                            Navigator.pop(context);
                                                                                          }
                                                                                        } else {
                                                                                          MyApp.ShowToast('Title should not be empty', context);
                                                                                        }
                                                                                      },
                                                                                      child: Text(
                                                                                        'ok',
                                                                                        style: TextStyle(fontSize: 18),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              }).then((value) => _fetchData());
                                                                        },
                                                                        child: Icon(
                                                                            Icons.edit)),
                                                                    GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          AssignmentEylfAPIHandler
                                                                              assignmentEylfAPIHandler =
                                                                              AssignmentEylfAPIHandler({
                                                                            "id":
                                                                                eylfData[index].activity[i].subActivity[j].id,
                                                                            "centerid":
                                                                                centers[currentIndex].id,
                                                                            "userid":
                                                                                MyApp.LOGIN_ID_VALUE
                                                                          });
                                                                          var data =
                                                                              await assignmentEylfAPIHandler.delEylfSubActivityData();
                                                                          if (data['Status'] ==
                                                                              'SUCCESS') {
                                                                            MyApp.ShowToast('Successfully Deleted',
                                                                                context);
                                                                            _fetchData();
                                                                          }
                                                                        },
                                                                        child: Icon(
                                                                            Icons.delete))
                                                                  ],
                                                                )
                                                              : null,
                                                        ),
                                                      );
                                                    })
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            List ids = [];
                                            List subIds = [];

                                            for (int i = 0;
                                                i <
                                                    eylfData[index]
                                                        .activity
                                                        .length;
                                                i++) {
                                              if (eylfData[index]
                                                      .activity[i]
                                                      .checked ==
                                                  'checked') {
                                                ids.add(eylfData[index]
                                                    .activity[i]
                                                    .id);
                                              }

                                              for (int j = 0;
                                                  j <
                                                      eylfData[index]
                                                          .activity[i]
                                                          .subActivity
                                                          .length;
                                                  j++) {
                                                if (eylfData[index]
                                                        .activity[i]
                                                        .subActivity[j]
                                                        .checked ==
                                                    'checked') {
                                                  subIds.add(eylfData[index]
                                                      .activity[i]
                                                      .subActivity[j]
                                                      .id);
                                                }
                                              }
                                            }
                                            var objToSend = {
                                              "centerid":
                                                  centers[currentIndex].id,
                                              "activity": ids,
                                              "subactivity": subIds,
                                              "userid": MyApp.LOGIN_ID_VALUE
                                            };

                                            var _toSend = Constants.BASE_URL +
                                                'Settings/saveEylfList';
                                            print(jsonEncode(objToSend));
                                            final response = await http.post(
                                                _toSend,
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
                                                  "updated", context);

                                              Navigator.pop(context);
                                            } else if (response.statusCode ==
                                                401) {
                                              MyApp.Show401Dialog(context);
                                            }
                                          },
                                          child: Text("Save"))
                                    ],
                                  )
                                ]))))))
            ],
          ),
        ),
      )),
    );
  }
}
