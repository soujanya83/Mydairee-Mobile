import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/assesmentsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/assesment/dev_assignment_settings.dart';
import 'package:mykronicle_mobile/assesment/eylf_assignment_settings.dart';
import 'package:mykronicle_mobile/assesment/montessori_assignment_settings.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class AssesmentsList extends StatefulWidget {
  @override
  _AssesmentsListState createState() => _AssesmentsListState();
}

class _AssesmentsListState extends State<AssesmentsList> {
  var settingsData;

  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

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
    _fetchData();
  }

  Future<void> _fetchData() async {
    AssesmentAPIHandler hlr = AssesmentAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var dt = await hlr.getAssesments();
    if (!dt.containsKey('error')) {
      print(dt);

      settingsData = dt['Settings'];
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
              if (settingsData != null)
                Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MontessoriAssignmentSettings()));
                        },
                        title: Text('Montessori'),
                        trailing: Checkbox(
                          value: settingsData['montessori'] == '1',
                          onChanged: (val) {
                            if (val) {
                              settingsData['montessori'] = '1';
                            } else {
                              settingsData['montessori'] = '0';
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EylfAssignmentSettings()));
                        },
                        title: Text('Eylf'),
                        trailing: Checkbox(
                          value: settingsData['eylf'] == '1',
                          onChanged: (val) {
                            if (val) {
                              settingsData['eylf'] = '1';
                            } else {
                              settingsData['eylf'] = '0';
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DevAssignmentSettings()));
                        },
                        title: Text('Devlopment Milestone'),
                        trailing: Checkbox(
                          value: settingsData['devmile'] == '1',
                          onChanged: (val) {
                            if (val) {
                              settingsData['devmile'] = '1';
                            } else {
                              settingsData['devmile'] = '0';
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              AssesmentAPIHandler hlr = AssesmentAPIHandler({
                                "userid": MyApp.LOGIN_ID_VALUE,
                                "centerid": centers[currentIndex].id,
                                "montessori": settingsData['montessori'],
                                "eylf": settingsData['eylf'],
                                "devmile": settingsData['devmile'],
                              });
                              var data = await hlr.saveAssesments();
                              if (data['Status'] == 'SUCCESS') {
                                MyApp.ShowToast('Saved Successfully', context);
                              }
                            },
                            child: Text('Save'))
                      ],
                    )
                  ],
                ),
            ],
          ),
        ),
      )),
    );
  }
}
