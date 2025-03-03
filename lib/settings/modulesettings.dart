import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/roomsmodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class ModuleSettings extends StatefulWidget {
  @override
  _ModuleSettingsState createState() => _ModuleSettingsState();
}

class _ModuleSettingsState extends State<ModuleSettings> {
  bool roomsFetched = false;
  bool usersFetched = false;
  List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

  bool programming = false;
  bool observation = false;
  bool rooms = false;
  bool programPlans = false;

  bool qip = false;

  bool community = false;
  bool announcements = false;
  bool survey = false;

  bool healthyEating = false;
  bool menus = false;
  bool recipe = false;

  bool dailyDiaryHead = false;
  bool dailyDiary = false;
  bool headChecks = false;
  bool accidents = false;

  bool resources = false;

  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchData() async {
    SettingsApiHandler handler = SettingsApiHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var data = await handler.getModules();
    print(data);

    var r = data['modules'];
    if (r != null && r != 'null') {
      observation = r['observation'] == '1' ? true : false;
      qip = r['qip'] == '1' ? true : false;
      rooms = r['room'] == '1' ? true : false;
      programPlans = r['programplans'] == '1' ? true : false;
      announcements = r['announcements'] == '1' ? true : false;
      survey = r['survey'] == '1' ? true : false;
      menus = r['menu'] == '1' ? true : false;
      recipe = r['recipe'] == '1' ? true : false;
      resources = r['resources'] == '1' ? true : false;
      headChecks = r['headchecks'] == '1' ? true : false;
      accidents = r['accidents'] == '1' ? true : false;
      dailyDiary = r['dailydiary'] == '1' ? true : false;
      if (observation == rooms && rooms == programPlans) {
        programming = observation;
      }
      if (announcements == survey) {
        community = announcements;
      }
      if (menus == recipe) {
        healthyEating = menus;
      }
      if (dailyDiary == headChecks && headChecks == accidents) {
        dailyDiaryHead = dailyDiary;
      }

      //   servicedetails=r['modules']['servicedetails']==1?true:false;
    }
    print(accidents);
    setState(() {});
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    print(dt);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        ' Module Settings',
                        style: Constants.header1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      programming = !programming;
                                      observation =
                                          rooms = programPlans = programming;
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        Text('Programming'),
                                        Expanded(child: Container()),
                                        programming
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
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      right: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      )),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          observation = !observation;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Observation'),
                                            Expanded(child: Container()),
                                            observation
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
                                      SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          rooms = !rooms;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Rooms'),
                                            Expanded(child: Container()),
                                            rooms
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
                                      SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          programPlans = !programPlans;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Program Plans'),
                                            Expanded(child: Container()),
                                            programPlans
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
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      qip = !qip;
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        Text('QIP'),
                                        Expanded(child: Container()),
                                        qip
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
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      community =
                                          announcements = survey = !community;
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        Text('Community'),
                                        Expanded(child: Container()),
                                        community
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
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      right: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      )),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          announcements = !announcements;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Announcements'),
                                            Expanded(child: Container()),
                                            announcements
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
                                      SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          survey = !survey;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Survey'),
                                            Expanded(child: Container()),
                                            survey
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
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      healthyEating =
                                          menus = recipe = !healthyEating;
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        Text('Healthy Eating'),
                                        Expanded(child: Container()),
                                        healthyEating
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
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      right: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      )),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          menus = !menus;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Menus'),
                                            Expanded(child: Container()),
                                            menus
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
                                      SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          recipe = !recipe;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Recipes'),
                                            Expanded(child: Container()),
                                            recipe
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
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      dailyDiaryHead = dailyDiary = headChecks =
                                          accidents = !dailyDiaryHead;
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        Text('Daily Dairy'),
                                        Expanded(child: Container()),
                                        dailyDiaryHead
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
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      right: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      )),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          dailyDiary = !dailyDiary;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Daily Dairy'),
                                            Expanded(child: Container()),
                                            dailyDiary
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
                                      SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          headChecks = !headChecks;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Head Checks'),
                                            Expanded(child: Container()),
                                            headChecks
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
                                      SizedBox(
                                        height: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          accidents = !accidents;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Text('Accidents'),
                                            Expanded(child: Container()),
                                            accidents
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
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      resources = !resources;
                                      setState(() {});
                                    },
                                    child: Row(
                                      children: [
                                        Text('Resources'),
                                        Expanded(child: Container()),
                                        resources
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
                                var body = {
                                  "userid": MyApp.LOGIN_ID_VALUE,
                                  "centerid":
                                      centers[currentIndex].id.toString(),
                                  "observation": observation ? '1' : '0',
                                  "qip": qip ? '1' : '0',
                                  "room": rooms ? '1' : '0',
                                  "programplans": programPlans ? '1' : '0',
                                  "announcements": announcements ? '1' : '0',
                                  "survey": survey ? '1' : '0',
                                  "menu": menus ? '1' : '0',
                                  "recipe": recipe ? '1' : '0',
                                  "resources": resources ? '1' : '0',
                                  "dailydiary": dailyDiary ? '1' : '0',
                                  "headchecks": headChecks ? '1' : '0',
                                  "accidents": accidents ? '1' : '0',
                                  "servicedetails": "0"
                                };

                                SettingsApiHandler res =
                                    SettingsApiHandler(body);
                                var result = await res.setModules();

                                if (!result.containsKey('error')) {
                                  Navigator.pop(context);
                                } else {
                                  MyApp.ShowToast(result['error'], context);
                                }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Constants.kButton,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
                    ])))));
  }
}
