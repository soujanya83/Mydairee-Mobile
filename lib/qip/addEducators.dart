import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/staffmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class AddEducators extends StatefulWidget {
  final String qipId;
  final String elementId;
  final String areaId;

  AddEducators(this.qipId, this.elementId, this.areaId);

  @override
  _AddEducatorsState createState() => _AddEducatorsState();
}

class _AddEducatorsState extends State<AddEducators> {
  List<StaffModel> staff = [];
  bool staffFetched = false;

  @override
  void initState() {
    _load();
    super.initState();
  }

  void _load() async {
    var _objToSend = {
      "qipid": widget.qipId,
      "elementid": widget.elementId,
      "userid": MyApp.LOGIN_ID_VALUE
    };
    QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
    var data = await qipAPIHandler.getStaff();
    var staffData = data['Staffs'];
    staff = [];
    try {
      assert(staffData is List);
      for (int i = 0; i < staffData.length; i++) {
        staff.add(StaffModel.fromJson(staffData[i]));
      }
      staffFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

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
              ListView.builder(
                  itemCount: staff.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                          trailing: Checkbox(
                            value: staff[index].selected == 'checked',
                            onChanged: (val) {
                              if(val==null)return;
                              if (val) {
                                staff[index].selected = 'checked';
                              } else {
                                staff[index].selected = '';
                              }
                              setState(() {});
                            },
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(staff[index]
                                        .imageUrl !=
                                    ""
                                ? Constants.ImageBaseUrl + staff[index].imageUrl
                                : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                          ),
                          title: Text(staff[index].name),
                          subtitle: Text(staff[index].gender)),
                    );
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.white),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        List ids = [];

                        for (int i = 0; i < staff.length; i++) {
                          if (staff[i].selected == 'checked') {
                            ids.add(staff[i].userid);
                          }
                        }

                        var _objToSend = {
                          "qipid": widget.qipId,
                          "areaid": widget.areaId,
                          "elementid": widget.elementId,
                          "staffids": jsonEncode(ids),
                          "userid": MyApp.LOGIN_ID_VALUE
                        };
                        QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
                        var data = await qipAPIHandler.addStaff();
                        var status = data['Status'];
                        if (status == 'SUCCESS') {
                          MyApp.ShowToast('Upadated Successfully', context);
                            RestartWidget.restartApp(context);
                        }
                      },
                      child: Text('Save')),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
