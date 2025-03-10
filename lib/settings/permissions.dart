import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class Permissions extends StatefulWidget {
  @override
  _PermissionsState createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  List<CentersModel> centers=[];
  bool centersFetched = false;
  int currentCenterIndex = 0;

  List<UserModel> users=[];
  bool usersFetched = false;
  int currentUserIndex = 0;

  bool addObservation = false;
  bool approveObservation = false;
  bool deleteObservation = false;
  bool updateObservation = false;
  bool viewAllObservation = false;
  bool addRoom = false;
  bool deleteRoom = false;
  bool updateRoom = false;
  bool addProgramPlan = false;
  bool editProgramPlan = false;
  bool viewProgramPlan = false;
  bool addAnnouncement = false;
  bool approveAnnouncement = false;
  bool deleteAnnouncement = false;
  bool updateAnnouncement = false;
  bool viewAllAnnouncement = false;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    SettingsApiHandler handler = SettingsApiHandler({
      "userid": MyApp.LOGIN_ID_VALUE,
    });

    var data = await handler.getPermissions();

    if (!data.containsKey('error')) {
      print(data.keys);
      print(data['users']);
      print(data['centers']);
      print(data['permissions']);

      var res = data['centers'];
      var res1 = data['users'];

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

      users = [];
      try {
        assert(res1 is List);
        for (int i = 0; i < res1.length; i++) {
          users.add(UserModel.fromJson(res1[i]));
        }
        usersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
    _fetchPermissionsData();
  }

  Future<void> _fetchPermissionsData() async {
    SettingsApiHandler handler = SettingsApiHandler({
      "userid": MyApp.LOGIN_ID_VALUE,
      "user": users[currentUserIndex].userid,
      "center": centers[currentCenterIndex].id
    });

    var data = await handler.getPermissions();

    if (!data.containsKey('error')) {
      print('perrr' + data['permissions'].toString());

      var r = data['permissions'];
      if (r != null && r != 'null') {
        addObservation = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['addObservation'] == '1')
            ? true
            : false;
        approveObservation = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['approveObservation'] == '1')
            ? true
            : false;
        deleteObservation = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['deleteObservation'] == '1')
            ? true
            : false;
        updateObservation = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['updateObservation'] == '1')
            ? true
            : false;
        viewAllObservation = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['viewAllObservation'] == '1')
            ? true
            : false;
        addRoom = (MyApp.USER_TYPE_VALUE == 'Superadmin' || r['addRoom'] == '1')
            ? true
            : false;
        deleteRoom =
            (MyApp.USER_TYPE_VALUE == 'Superadmin' || r['deleteRoom'] == '1')
                ? true
                : false;
        updateRoom =
            (MyApp.USER_TYPE_VALUE == 'Superadmin' || r['updateRoom'] == '1')
                ? true
                : false;
        addProgramPlan = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['addProgramPlan'] == '1')
            ? true
            : false;
        editProgramPlan = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['editProgramPlan'] == '1')
            ? true
            : false;
        viewProgramPlan = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['viewProgramPlan'] == '1')
            ? true
            : false;
        addAnnouncement = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['addAnnouncement'] == '1')
            ? true
            : false;

        approveAnnouncement = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['approveAnnouncement'] == '1')
            ? true
            : false;
        deleteAnnouncement = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['deleteAnnouncement'] == '1')
            ? true
            : false;
        updateAnnouncement = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['updateAnnouncement'] == '1')
            ? true
            : false;
        viewAllAnnouncement = (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
                r['viewAllAnnouncement'] == '1')
            ? true
            : false;
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
            children: [
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
                          value: centers[currentCenterIndex].id,
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
                                  currentCenterIndex = i;
                                  _fetchPermissionsData();
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
              if (usersFetched)
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
                          value: users[currentUserIndex].userid,
                          items: users.map((UserModel value) {
                            return DropdownMenuItem<String>(
                              value: value.userid,
                              child: Text(value.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            for (int i = 0; i < users.length; i++) {
                              if (users[i].userid == value) {
                                setState(() {
                                  currentUserIndex = i;
                                  _fetchPermissionsData();
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
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          addObservation = !addObservation;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('addObservation'),
                            Expanded(child: Container()),
                            addObservation
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
                          approveObservation = !approveObservation;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('approveObservation'),
                            Expanded(child: Container()),
                            approveObservation
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
                          deleteObservation = !deleteObservation;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('deleteObservation'),
                            Expanded(child: Container()),
                            deleteObservation
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
                          updateObservation = !updateObservation;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('updateObservation'),
                            Expanded(child: Container()),
                            updateObservation
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
                          viewAllObservation = !viewAllObservation;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('viewAllObservation'),
                            Expanded(child: Container()),
                            viewAllObservation
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
                          addRoom = !addRoom;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('addRoom'),
                            Expanded(child: Container()),
                            addRoom
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
                          deleteRoom = !deleteRoom;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('deleteRoom'),
                            Expanded(child: Container()),
                            deleteRoom
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
                          updateRoom = !updateRoom;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('updateRoom'),
                            Expanded(child: Container()),
                            updateRoom
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
                          addProgramPlan = !addProgramPlan;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('addProgramPlan'),
                            Expanded(child: Container()),
                            addProgramPlan
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
                          editProgramPlan = !editProgramPlan;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('editProgramPlan'),
                            Expanded(child: Container()),
                            editProgramPlan
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
                          viewProgramPlan = !viewProgramPlan;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('viewProgramPlan'),
                            Expanded(child: Container()),
                            viewProgramPlan
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
                          addAnnouncement = !addAnnouncement;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('addAnnouncement'),
                            Expanded(child: Container()),
                            addAnnouncement
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
                          approveAnnouncement = !approveAnnouncement;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('approveAnnouncement'),
                            Expanded(child: Container()),
                            approveAnnouncement
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
                          deleteAnnouncement = !deleteAnnouncement;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('deleteAnnouncement'),
                            Expanded(child: Container()),
                            deleteAnnouncement
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
                          updateAnnouncement = !updateAnnouncement;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('updateAnnouncement'),
                            Expanded(child: Container()),
                            updateAnnouncement
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
                          approveAnnouncement = !approveAnnouncement;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('approveAnnouncement'),
                            Expanded(child: Container()),
                            approveAnnouncement
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
                          deleteAnnouncement = !deleteAnnouncement;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('deleteAnnouncement'),
                            Expanded(child: Container()),
                            deleteAnnouncement
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
                          updateAnnouncement = !updateAnnouncement;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('updateAnnouncement'),
                            Expanded(child: Container()),
                            updateAnnouncement
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
                          viewAllAnnouncement = !viewAllAnnouncement;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Text('viewAllAnnouncement'),
                            Expanded(child: Container()),
                            viewAllAnnouncement
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
                        height: 20,
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
                                  "center":
                                      centers[currentCenterIndex].id.toString(),
                                  "user": users[currentUserIndex].id.toString(),
                                  "addObservation": addObservation ? '1' : '0',
                                  "approveObservation":
                                      approveObservation ? '1' : '0',
                                  "deleteObservation":
                                      deleteObservation ? '1' : '0',
                                  "updateObservation":
                                      updateObservation ? '1' : '0',
                                  "viewAllObservation":
                                      viewAllObservation ? '1' : '0',
                                  "deleteRoom": deleteRoom ? '1' : '0',
                                  "updateRoom": updateRoom ? '1' : '0',
                                  "addProgramPlan": addProgramPlan ? '1' : '0',
                                  "editProgramPlan":
                                      editProgramPlan ? '1' : '0',
                                  "viewProgramPlan":
                                      viewProgramPlan ? '1' : '0',
                                  "addAnnouncement":
                                      addAnnouncement ? '1' : '0',
                                  "approveAnnouncement":
                                      approveAnnouncement ? '1' : '0',
                                  "deleteAnnouncement":
                                      deleteAnnouncement ? '1' : '0',
                                  "updateAnnouncement":
                                      updateAnnouncement ? '1' : '0',
                                  "viewAllAnnouncement":
                                      viewAllAnnouncement ? '1' : '0',
                                };

                                SettingsApiHandler res =
                                    SettingsApiHandler(body);
                                var result = await res.setPermissions();

                                if (!result.containsKey('error')) {
                                  MyApp.ShowToast('Updated', context);
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
                    ],
                  ),
                )),
              )
            ],
          ),
        )),
      ),
    );
  }
}
