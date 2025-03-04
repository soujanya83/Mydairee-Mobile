import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class DailyJournalSettings extends StatefulWidget {
  @override
  _DailyJournalSettingsState createState() => _DailyJournalSettingsState();
}

class _DailyJournalSettingsState extends State<DailyJournalSettings> {
  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

  bool breakfast = false;
  bool morningtea = false;
  bool lunch = false;
  bool sleep = false;
  bool afternoontea = false;
  bool latesnacks = false;
  bool sunscreen = false;
  bool toileting = false;

  @override
  void initState() {
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
    SettingsApiHandler settingsApiHandler = SettingsApiHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var data = await settingsApiHandler.getDailyJournalData();
    print(data);
    if (!data.containsKey('error')) {
      var choosen = data['JournalTabs'];
      if (choosen != null) {
        breakfast = choosen['breakfast'] == '1' ? true : false;
        morningtea = choosen['morningtea'] == '1' ? true : false;
        lunch = choosen['lunch'] == '1' ? true : false;
        sleep = choosen['sleep'] == '1' ? true : false;
        afternoontea = choosen['afternoontea'] == '1' ? true : false;
        latesnacks = choosen['latesnacks'] == '1' ? true : false;
        sunscreen = choosen['sunscreen'] == '1' ? true : false;
        toileting = choosen['toileting'] == '1' ? true : false;
        setState(() {});
      } else {
        breakfast = false;
        morningtea = false;
        lunch = false;
        sleep = false;
        afternoontea = false;
        latesnacks = false;
        sunscreen = false;
        toileting = false;
        setState(() {});
      }
    } else {
      MyApp.Show401Dialog(context);
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8),
                  child: Text(
                    Constants.DAILYJOURNAL_SETTINGSTAG,
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
                SizedBox(
                  height: 10,
                ),
                Card(
                    child: Container(
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  breakfast = !breakfast;
                                  setState(() {});
                                  callApi();
                                },
                                child: Row(
                                  children: [
                                    Text('Breakfast'),
                                    Expanded(child: Container()),
                                    breakfast
                                        ? Icon(
                                            Icons.radio_button_on,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ),
                              Divider(),
                              GestureDetector(
                                onTap: () {
                                  morningtea = !morningtea;
                                  setState(() {});
                                  callApi();
                                },
                                child: Row(
                                  children: [
                                    Text('Morningtea'),
                                    Expanded(child: Container()),
                                    morningtea
                                        ? Icon(
                                            Icons.radio_button_on,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ),
                              Divider(),
                              GestureDetector(
                                onTap: () {
                                  lunch = !lunch;
                                  setState(() {});
                                  callApi();
                                },
                                child: Row(
                                  children: [
                                    Text('Lunch'),
                                    Expanded(child: Container()),
                                    lunch
                                        ? Icon(
                                            Icons.radio_button_on,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ),
                              Divider(),
                              GestureDetector(
                                onTap: () {
                                  sleep = !sleep;
                                  setState(() {});
                                  callApi();
                                },
                                child: Row(
                                  children: [
                                    Text('Sleep'),
                                    Expanded(child: Container()),
                                    sleep
                                        ? Icon(
                                            Icons.radio_button_on,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ),
                              Divider(),
                              GestureDetector(
                                onTap: () {
                                  afternoontea = !afternoontea;
                                  setState(() {});
                                  callApi();
                                },
                                child: Row(
                                  children: [
                                    Text('Afternoon Tea'),
                                    Expanded(child: Container()),
                                    afternoontea
                                        ? Icon(
                                            Icons.radio_button_on,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ),
                              Divider(),
                              GestureDetector(
                                onTap: () {
                                  latesnacks = !latesnacks;
                                  setState(() {});
                                  callApi();
                                },
                                child: Row(
                                  children: [
                                    Text('Late Snacks'),
                                    Expanded(child: Container()),
                                    latesnacks
                                        ? Icon(
                                            Icons.radio_button_on,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ),
                              Divider(),
                              GestureDetector(
                                onTap: () {
                                  sunscreen = !sunscreen;
                                  setState(() {});
                                  callApi();
                                },
                                child: Row(
                                  children: [
                                    Text('Sunscreen'),
                                    Expanded(child: Container()),
                                    sunscreen
                                        ? Icon(
                                            Icons.radio_button_on,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ),
                              Divider(),
                              GestureDetector(
                                onTap: () {
                                  toileting = !toileting;
                                  setState(() {});
                                  callApi();
                                },
                                child: Row(
                                  children: [
                                    Text('Toileting'),
                                    Expanded(child: Container()),
                                    toileting
                                        ? Icon(
                                            Icons.radio_button_on,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.radio_button_off,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ),
                              Divider(),
                            ]))))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void callApi() async {
    var objToSend = {
      "centerid": centers[currentIndex].id,
      "breakfast": breakfast ? '1' : '0',
      "morningtea": morningtea ? '1' : '0',
      "lunch": lunch ? '1' : '0',
      "sleep": sleep ? '1' : '0',
      "afternoontea": afternoontea ? '1' : '0',
      "latesnacks": latesnacks ? '1' : '0',
      "sunscreen": sunscreen ? '1' : '0',
      "toileting": toileting ? '1' : '0',
      "userid": MyApp.LOGIN_ID_VALUE
    };

    SettingsApiHandler settingsApiHandler = SettingsApiHandler(objToSend);
    var data = await settingsApiHandler.setDailyJournalData();
    print(data);
  }
}
