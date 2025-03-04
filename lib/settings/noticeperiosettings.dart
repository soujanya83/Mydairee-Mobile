import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class NoticePeriodSettings extends StatefulWidget {
  @override
  _NoticePeriodSettingsState createState() => _NoticePeriodSettingsState();
}

class _NoticePeriodSettingsState extends State<NoticePeriodSettings> {
  TextEditingController controller;
  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

  @override
  void initState() {
    controller = TextEditingController();
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    if (!dt.containsKey('error')) {
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
    var objToSend = {
      "centerid": centers[currentIndex].id,
      "userid": MyApp.LOGIN_ID_VALUE
    };
    SettingsApiHandler settingsApiHandler = SettingsApiHandler(objToSend);
    var data = await settingsApiHandler.getNoticePeriod();
    print(data);
    if (data['Notice']['days'] != null) {
      controller.text = data['Notice']['days'];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 12),
                  child: Text(
                    Constants.NOTICEPERIOD_SETTIGSTAG,
                    style: Constants.header1,
                  ),
                ),
                centersFetched
                    ? DropdownButtonHideUnderline(
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
                      )
                    : Container(),
                SizedBox(
                  height: 15,
                ),
                Text('Number of days'),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: 30,
                  child: TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(4),
                          ),
                        ),
                      )),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Constants.kMain)),
                        onPressed: () async {
                          var objToSend = {
                            "centerid": centers[currentIndex].id,
                            "userid": MyApp.LOGIN_ID_VALUE,
                            "number": controller.text
                          };
                          SettingsApiHandler settingsApiHandler =
                              SettingsApiHandler(objToSend);
                          var data = await settingsApiHandler.setNoticePeriod();
                          print(data);
                          if (data['Status'] == 'SUCCESS') {
                            MyApp.ShowToast('Success', context);
                          }
                        },
                        child: Text('Save'))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
