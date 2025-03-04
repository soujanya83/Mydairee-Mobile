import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/areamodel.dart';
import 'package:mykronicle_mobile/models/assesmentmodel.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/lrmodel.dart';
import 'package:mykronicle_mobile/models/qamodel.dart';
import 'package:mykronicle_mobile/qip/selfAssesment/selfAddEdu.dart';
import 'package:mykronicle_mobile/qip/selfAssesment/selfAddToQip.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:http/http.dart' as http;

class ViewAssesment extends StatefulWidget {
  final AssesmentModel assesmentModel;
  ViewAssesment(this.assesmentModel);

  @override
  _ViewAssesmentState createState() => _ViewAssesmentState();
}

class _ViewAssesmentState extends State<ViewAssesment>
    with SingleTickerProviderStateMixin {
  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;
  int areaIndex = 0;
  List<AreaModel> areas;
  List<LRModel> lrList = [];
  List<QAModel> qaList = [];
  List<TextEditingController> lrController = [];
  List<TextEditingController> qaController = [];

  TabController _controller;
  List tabNames = ["Legislative Requirements", "Quality Area"];

  @override
  void initState() {
    _fetchCenters();
    _controller = new TabController(length: 2, vsync: this);
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

  void _fetchData() async {
    var _objToSend = {
      "id": widget.assesmentModel.id,
      "centerid": centers[currentIndex].id,
      "userid": MyApp.LOGIN_ID_VALUE
    };

    if (areas != null) {
      _objToSend["areaid"] = areas[areaIndex].id;
    }
    QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
    var data = await qipAPIHandler.viewSelfAsses();
    if (areas == null) {
      var area = data['Areas'];
      print(area);
      areas = [];
      lrController = [];
      qaController = [];
      try {
        assert(area is List);
        for (int i = 0; i < area.length; i++) {
          areas.add(AreaModel.fromJson(area[i]));
        }
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    }
    var lr = data['LR'];
    print(lr);
    lrList = [];
    try {
      assert(lr is List);
      for (int i = 0; i < lr.length; i++) {
        lrList.add(LRModel.fromJson(lr[i]));
        lrController.add(TextEditingController(text: lrList[i].actions));
      }
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    var qa = data['QA'];
    print(qa);
    qaList = [];
    try {
      assert(qa is List);
      for (int i = 0; i < qa.length; i++) {
        qaList.add(QAModel.fromJson(qa[i]));
        qaController
            .add(TextEditingController(text: qaList[i].identifiedPractice));
      }
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  widget.assesmentModel.name,
                  style: Constants.header1,
                ),
              ),
              if (centersFetched)
                DropdownButtonHideUnderline(
                  child: Container(
                    height: 30,
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
              if (areas != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5),
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
                            value: areas[areaIndex].id,
                            items: areas.map((AreaModel value) {
                              return new DropdownMenuItem<String>(
                                value: value.id,
                                child: new Text(value.title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              for (int i = 0; i < areas.length; i++) {
                                if (areas[i].id == value) {
                                  setState(() {
                                    areaIndex = i;
                                  });
                                  _fetchData();
                                  break;
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelfAddEducators(
                                    widget.assesmentModel.id)));
                      },
                      child: Text("+ Add Educators")),
                  Row(
                    children: [
                      if (widget.assesmentModel.educators.length > 0)
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.assesmentModel
                                      .educators[0]['imageUrl'] !=
                                  ""
                              ? Constants.ImageBaseUrl +
                                  widget.assesmentModel.educators[0]['imageUrl']
                              : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                        ),
                      SizedBox(
                        width: 8,
                      ),
                      if (widget.assesmentModel.educators.length - 1 > 0)
                        CircleAvatar(
                          backgroundColor: Constants.greyColor,
                          child: Text("+" +
                              (widget.assesmentModel.educators.length - 1)
                                  .toString()),
                        ),
                    ],
                  )
                ],
              ),
              Container(
                child: DefaultTabController(
                  length: tabNames.length,
                  child: new TabBar(
                      isScrollable: true,
                      controller: _controller,
                      labelColor: Constants.kMain,
                      unselectedLabelColor: Colors.grey,
                      tabs: List<Tab>.generate(tabNames.length, (i) {
                        return Tab(
                          text: tabNames[i],
                        );
                      })),
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: new TabBarView(controller: _controller, children: [
                    lrList.length > 0
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.55,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                                itemCount: lrList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Card(
                                      child: Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 20, 8, 4),
                                      child: Container(
                                        width: size.width,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: size.width * 0.3,
                                                child: Text(
                                                    "National Law \n (NL)")),
                                            Container(
                                                width: size.width * 0.55,
                                                child: Text(
                                                    lrList[index].nationalLaw)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 10, 8, 4),
                                      child: Container(
                                        width: size.width,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: size.width * 0.3,
                                                child: Text(
                                                    "National \nRegulation \n(NR)")),
                                            Container(
                                                width: size.width * 0.55,
                                                child: Text(lrList[index]
                                                    .nationalRegulation)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 10, 8, 4),
                                      child: Container(
                                        width: size.width,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: size.width * 0.3,
                                                child: Text(
                                                    "Associated \nElement\n(AE)")),
                                            Container(
                                                width: size.width * 0.55,
                                                child: Text(lrList[index]
                                                    .associatedElements)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 10, 8, 4),
                                      child: Container(
                                        width: size.width,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: size.width * 0.3,
                                                child: Text("Status")),
                                            Container(
                                                width: size.width * 0.55,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            value: lrList[index]
                                                                    .status ==
                                                                'Compliant',
                                                            onChanged: (val) {
                                                              if (val) {
                                                                lrList[index]
                                                                        .status =
                                                                    'Compliant';
                                                                lrController[
                                                                        index]
                                                                    .text = '';
                                                              } else {
                                                                lrList[index]
                                                                    .status = '';
                                                              }
                                                              setState(() {});
                                                            }),
                                                        Text('Compliant')
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Checkbox(
                                                            value: lrList[index]
                                                                    .status ==
                                                                'Noncompliant',
                                                            onChanged: (val) {
                                                              if (val) {
                                                                lrList[index]
                                                                        .status =
                                                                    'Noncompliant';
                                                              } else {
                                                                lrList[index]
                                                                    .status = '';
                                                              }
                                                              setState(() {});
                                                            }),
                                                        Text('Not Compliant')
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 10, 8, 4),
                                      child: Container(
                                        width: size.width,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: size.width * 0.3,
                                                child: Text("Action's")),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(lrList[index].status),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                if (lrList[index].status !=
                                                    'Compliant')
                                                  Container(
                                                      width: size.width * 0.55,
                                                      child: TextField(
                                                        controller:
                                                            lrController[index],
                                                        decoration:
                                                            InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                enabledBorder:
                                                                    const OutlineInputBorder(
                                                                  borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .grey,
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
                                                                )),
                                                      )),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ]));
                                }))
                        : Container(),
                    qaList.length > 0
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.55,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                                itemCount: qaList.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Card(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 20, 8, 4),
                                          child: Container(
                                            width: size.width,
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: size.width * 0.3,
                                                    child: Text("Concept")),
                                                Container(
                                                    width: size.width * 0.55,
                                                    child: Text(
                                                        qaList[index].concept)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 10, 8, 4),
                                          child: Container(
                                            width: size.width,
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: size.width * 0.3,
                                                    child: Text("Elements")),
                                                Container(
                                                    width: size.width * 0.55,
                                                    child: Text(qaList[index]
                                                        .elements)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 10, 8, 4),
                                          child: Container(
                                            width: size.width,
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: size.width * 0.3,
                                                    child: Text(
                                                        "Identifiend Practices")),
                                                Container(
                                                    width: size.width * 0.55,
                                                    child: TextField(
                                                      controller:
                                                          qaController[index],
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              enabledBorder:
                                                                  const OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .grey,
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
                                                              )),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 10, 8, 4),
                                          child: Container(
                                            width: size.width,
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: size.width * 0.3,
                                                    child: Text("Status")),
                                                Container(
                                                    width: size.width * 0.55,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Checkbox(
                                                                value: qaList[
                                                                            index]
                                                                        .status ==
                                                                    'Met',
                                                                onChanged:
                                                                    (val) {
                                                                  if (val) {
                                                                    qaList[index]
                                                                            .status =
                                                                        'Met';
                                                                  } else {
                                                                    qaList[index]
                                                                        .status = '';
                                                                  }
                                                                  setState(
                                                                      () {});
                                                                }),
                                                            Text('Met')
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Checkbox(
                                                                value: qaList[
                                                                            index]
                                                                        .status ==
                                                                    'Not-met',
                                                                onChanged:
                                                                    (val) {
                                                                  if (val) {
                                                                    qaList[index]
                                                                            .status =
                                                                        'Not-met';
                                                                  } else {
                                                                    qaList[index]
                                                                        .status = '';
                                                                  }
                                                                  setState(
                                                                      () {});
                                                                }),
                                                            Text('Not Met')
                                                          ],
                                                        ),
                                                        Container(
                                                          width:
                                                              size.width * 0.55,
                                                          child: ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => SelfAddToQip(
                                                                            widget.assesmentModel.centerid,
                                                                            qaController[index].text)));
                                                              },
                                                              child: Text(
                                                                  '+ Add To Qip')),
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))
                        : Container()
                  ])),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        List legalities = [];
                        List qualities = [];

                        for (int i = 0; i < lrList.length; i++) {
                          legalities.add({
                            "id": lrList[i].id,
                            "status": lrList[i].status,
                            "notice": lrController[i].text
                          });
                        }

                        for (int i = 0; i < qaList.length; i++) {
                          qualities.add({
                            "id": qaList[i].id,
                            "status": qaList[i].status,
                            "ip": qaController[i].text
                          });
                        }

                        var _toSend = Constants.BASE_URL +
                            'SelfAssessment/saveSelfAssessment/';

                        var _objToSend = {
                          "legalities": legalities,
                          "qualities": qualities,
                          "userid": MyApp.LOGIN_ID_VALUE
                        };

                        print(jsonEncode(_objToSend));
                        final response = await http.post(Uri.parse(_toSend),
                            body: jsonEncode(_objToSend),
                            headers: {
                              'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
                              'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
                            });
                        print(response.body);
                        if (response.statusCode == 200) {
                          MyApp.ShowToast("updated", context);
                        } else if (response.statusCode == 401) {
                          MyApp.Show401Dialog(context);
                        }
                      },
                      child: Text('Save Assesment'))
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
