import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/progressplan.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/montessorimodel.dart';
import 'package:mykronicle_mobile/models/process_child.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class ProgressPlan extends StatefulWidget {
  @override
  _ProgressPlanState createState() => _ProgressPlanState();
}

class _ProgressPlanState extends State<ProgressPlan> {
  bool typeFlag = false;

  List<ProcessChildSubModel> childList = [];
  List<MontessoriActivityModel> montessoriList= [];
  List<CentersModel> centers= [];
  bool centersFetched = false;
  int currentIndex = 0;
  bool dataFetched = false;
  bool loaded = false;
  String error = "";
  var processData;

  @override
  void initState() {
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
    _load();
  }

  void _load() async {
    ProgressPlanApiHandler progressPlan = ProgressPlanApiHandler({
      "usertype": MyApp.USER_TYPE_VALUE,
      "userid": MyApp.LOGIN_ID_VALUE,
      "center_id": centers[currentIndex].id,
      "centerid": centers[currentIndex].id
    });
    var data = await progressPlan.getProgressPlanDetails();
    print(data.containsKey("error"));
    if (!data.containsKey("error")) {
      var child = data['new_process'];
      var montessori = data['montessorisubactivity'];
      processData = child;
      print(child);
      childList = [];
      for (int i = 0; i < (child.length / 2); i++) {
        childList.add(ProcessChildSubModel.fromJson(child[i.toString()]));
      }
      montessoriList = [];
      for (int i = 0; i < montessori.length; i++) {
        montessoriList.add(MontessoriActivityModel.fromJson(montessori[i]));
      }
      error = '';
    } else {
      error = data['error'];
    }
    dataFetched = true;
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: floating(context),
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Montessori Progress Plan',
                  style: Constants.header1,
                ),
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
                                        //   details = null;
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FontAwesome.flag,
                                size: 25,
                                color: Color(0xffFFF505),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Introduced',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                FontAwesome.flag,
                                size: 25,
                                color: Color(0xffFF8A00),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Needs More',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FontAwesome.flag,
                                size: 25,
                                color: Colors.purple,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Working',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                FontAwesome.flag,
                                size: 25,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Planned',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FontAwesome.flag,
                                size: 25,
                                color: Color(0xffF97E7F),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Completed',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                FontAwesome.flag,
                                size: 25,
                                color: Color(0xff297DB6),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Planned',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '(by someone)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              if (dataFetched && error == '')
                ListTile(
                  title: InkWell(
                    onTap: (){
                      _load();
                    },
                    child: Text(
                      typeFlag ? "Planned" : "Record",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  trailing: MyApp.USER_TYPE_VALUE != 'Parent'? Switch(
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    activeTrackColor: Colors.green,
                    inactiveTrackColor: Colors.red,
                    value: typeFlag,
                    onChanged: (newval) {
                      typeFlag = newval;
                      setState(() {});
                    },
                  ):Container(height: 0,width: 0,),
                ),
              if (dataFetched && error == '')
                SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildCellsWithHeader(),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _buildRows(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if (dataFetched && error != '')
                Container(
                  child: Center(child: Text(error)),
                )
            ],
          ),
        ),
      )),
    );
  }

  List<Widget> _buildCellsWithHeader() {
    return List.generate(
      montessoriList.length + 1,
      (index) => Container(
        alignment: Alignment.center,
        width: 175.0,
        height: 60.0,
        color: Colors.white,
        margin: EdgeInsets.all(4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: index == 0
              ? Text("Preliminary Exercises",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 140,
                      child: Text(montessoriList[index - 1].title,
                          style: TextStyle(color: Colors.blue)),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.arrow_forward_outlined,
                        size: 14,
                      ),
                      onTap: null,
                    )
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> _buildCells(ProcessChildSubModel childSubModel, int p) {
    var nameType = childSubModel.childName + "_" + childSubModel.childId;
    var data = processData[nameType];
    var aData = processData[p.toString()]['processactivityid'].toString().split(',');
    var pData = processData[p.toString()]['subid'].toString().split(',');

    return List.generate(
      montessoriList.length + 1,
      (index) => Container(
        alignment: Alignment.center,
        width: 120.0,
        height: 60.0,
        color: Colors.white,
        margin: EdgeInsets.all(4.0),
        child: index == 0
            ? Text(childSubModel.childName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
            : InkWell(
                onTap: () async {
                  if (typeFlag) {
                    if (data[index.toString()] == "") {
                      var obj = {
                        "usertype": MyApp.USER_TYPE_VALUE,
                        "created": MyApp.LOGIN_ID_VALUE,
                        "userid": MyApp.LOGIN_ID_VALUE,
                        "centerid": centers[currentIndex].id,
                        "status": "Planned",
                        "actvityid": aData[index - 1],
                        "childid": childSubModel.childId,
                        "subid": pData[index - 1]
                      };
                      print(obj);
                      ProgressPlanApiHandler plan = ProgressPlanApiHandler(obj);
                      var planDetails = await plan.createPlan();
                      print(planDetails);

                      data[index.toString()] = "Planned";
                      setState(() {});
                    } else if (data[index.toString()] == "Planned") {
                      var obj = {
                        "usertype": MyApp.USER_TYPE_VALUE,
                        "created": MyApp.LOGIN_ID_VALUE,
                        "userid": MyApp.LOGIN_ID_VALUE,
                        "centerid": centers[currentIndex].id,
                        "status": "",
                        "actvityid": aData[index - 1],
                        "childid": childSubModel.childId,
                        "subid": pData[index - 1]
                      };
                      print(obj);
                      ProgressPlanApiHandler plan = ProgressPlanApiHandler(obj);
                      var planDetails = await plan.createPlan();
                      print(planDetails);

                      data[index.toString()] = "";
                      setState(() {});
                    }
                  } else {
                    if (data[index.toString()] == "") {
                      var obj = {
                        "usertype": MyApp.USER_TYPE_VALUE,
                        "created": MyApp.LOGIN_ID_VALUE,
                        "userid": MyApp.LOGIN_ID_VALUE,
                        "centerid": centers[currentIndex].id,
                        "status": "Introduced",
                        "actvityid": aData[index - 1],
                        "childid": childSubModel.childId,
                        "subid": pData[index - 1]
                      };
                      print(obj);
                      ProgressPlanApiHandler plan = ProgressPlanApiHandler(obj);
                      var planDetails = await plan.createPlan();
                      print(planDetails);

                      data[index.toString()] = "Introduced";
                      setState(() {});
                    } else if (data[index.toString()] == "Introduced") {
                      var obj = {
                        "usertype": MyApp.USER_TYPE_VALUE,
                        "created": MyApp.LOGIN_ID_VALUE,
                        "userid": MyApp.LOGIN_ID_VALUE,
                        "centerid": centers[currentIndex].id,
                        "status": "Working",
                        "actvityid": aData[index - 1],
                        "childid": childSubModel.childId,
                        "subid": pData[index - 1]
                      };
                      print(obj);
                      ProgressPlanApiHandler plan = ProgressPlanApiHandler(obj);
                      var planDetails = await plan.updatePlan();
                      print(planDetails);

                      data[index.toString()] = "Working";
                      setState(() {});
                    } else if (data[index.toString()] == "Working") {
                      var obj = {
                        "usertype": MyApp.USER_TYPE_VALUE,
                        "created": MyApp.LOGIN_ID_VALUE,
                        "userid": MyApp.LOGIN_ID_VALUE,
                        "centerid": centers[currentIndex].id,
                        "status": "Completed",
                        "actvityid": aData[index - 1],
                        "childid": childSubModel.childId,
                        "subid": pData[index - 1]
                      };
                      print(obj);

                      ProgressPlanApiHandler plan = ProgressPlanApiHandler(obj);
                      var planDetails = await plan.updatePlan();
                      print(planDetails);

                      data[index.toString()] = "Completed";
                      setState(() {});
                    } else if (data[index.toString()] == "Completed") {
                      var obj = {
                        "usertype": MyApp.USER_TYPE_VALUE,
                        "created": MyApp.LOGIN_ID_VALUE,
                        "userid": MyApp.LOGIN_ID_VALUE,
                        "centerid": centers[currentIndex].id,
                        "status": "Needs More",
                        "actvityid": aData[index - 1],
                        "childid": childSubModel.childId,
                        "subid": pData[index - 1]
                      };
                      print(obj);

                      ProgressPlanApiHandler plan = ProgressPlanApiHandler(obj);
                      var planDetails = await plan.updatePlan();
                      print(planDetails);

                      data[index.toString()] = "Needs More";
                      setState(() {});
                    } else if (data[index.toString()] == "Needs More") {
                      var obj = {
                        "usertype": MyApp.USER_TYPE_VALUE,
                        "created": MyApp.LOGIN_ID_VALUE,
                        "userid": MyApp.LOGIN_ID_VALUE,
                        "centerid": centers[currentIndex].id,
                        "status": "",
                        "actvityid": aData[index - 1],
                        "childid": childSubModel.childId,
                        "subid": pData[index - 1]
                      };
                      print(obj);

                      ProgressPlanApiHandler plan = ProgressPlanApiHandler(obj);
                      var planDetails = await plan.updatePlan();
                      print(planDetails);

                      data[index.toString()] = "";
                      setState(() {});
                    }
                  }
                },
                child: Text(data.toString()),
                // child: flag(data!=null? data[index.toString()]:'', childSubModel.createdBy)
                ),
      ),
    );
  }

  Widget flag(String type, String created) {
    if (type == 'Introduced') {
      return Icon(
        FontAwesome.flag,
        size: 25,
        color: Color(0xffFFF505),
      );
    } else if (type == 'Needs More') {
      return Icon(
        FontAwesome.flag,
        size: 25,
        color: Color(0xffFF8A00),
      );
    } else if (type == 'Working') {
      return Icon(
        FontAwesome.flag,
        size: 25,
        color: Colors.purple,
      );
    } else if (type == 'Planned') {
      if (MyApp.LOGIN_ID_VALUE == created) {
        return Icon(
          FontAwesome.flag,
          size: 25,
          color: Colors.black,
        );
      } else {
        return Icon(
          FontAwesome.flag,
          size: 25,
          color: Color(0xff297DB6),
        );
      }
    } else if (type == 'Completed') {
      return Icon(
        FontAwesome.flag,
        size: 25,
        color: Color(0xffF97E7F),
      );
    } else {
      return Container(
        width: 120.0,
        height: 60.0,
      );
    }
  }

  List<Widget> _buildRows() {
    return List.generate(
      childList.length,
      (index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildCells(childList[index], index),
      ),
    );
  }
}
