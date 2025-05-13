import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/adduser.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:http/http.dart' as http;

class UserSettings extends StatefulWidget {
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  String searchString = '';

  bool showGroup = false;
  bool showStatus = false;
  bool showGender = false;

  bool maleGender = false;
  bool femaleGender = false;
  bool otherGender = false;

  bool active = false;
  bool inactive = false;
  bool pending = false;
  bool settingsDataFetched = false;

  List groups = [];
  List gender = [];
  List status = [];

  List groupsData = [];
  String order = 'ASC';
  List<UserModel> _allUsers = [];
  Map<String, dynamic> userStats = {};
  GlobalKey<ScaffoldState> key = GlobalKey();

  Map<String, bool> groupValues = {};

  Widget getEndDrawer(BuildContext context) {
    return Drawer(
        child: Container(
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 5,
          ),
          ListTile(
            title: Text(
              'Apply Filters',
              style: Constants.header2,
            ),
            trailing: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            //   onTap: () {},
          ),
          ListTile(
            title: Text(
              'Groups',
              style: Constants.header2,
            ),
            trailing: IconButton(
              icon: Icon(showGroup
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () {
                showGroup = !showGroup;
                setState(() {});
              },
            ),
          ),
          Visibility(
            visible: groupsData != null && showGroup,
            child: Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: groupsData != null ? groupsData.length : 0,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    String key = groupValues.keys.elementAt(index);
                    return CheckboxListTile(
                        title: Text(key),
                        value: groupValues[key],
                        onChanged: (value) {
                          for (int i = 0; i < groupsData.length; i++) {
                            if (groupsData[i]['name'] == key) {
                              if (value == true && groupValues[key] == false) {
                                groupValues[key] = true;

                                if (!groups.contains(groupsData[i]['id'])) {
                                  groups.add(groupsData[i]['id']);
                                }
                              } else if (value == false) {
                                groupValues[key] = false;

                                if (groups.contains(groupsData[i]['id'])) {
                                  groups.remove(groupsData[i]['id']);
                                }
                              }
                              break;
                            }
                          }

                          settingsDataFetched = false;
                          setState(() {});
                          _fetchFilterData();
                        });
                  }),
            ),
          ),
          ListTile(
            title: Text(
              'Status',
              style: Constants.header2,
            ),
            trailing: IconButton(
              icon: Icon(showStatus
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () {
                showStatus = !showStatus;
                setState(() {});
              },
            ),
          ),
          Visibility(
              visible: showStatus,
              child: Container(
                  child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                    ListTile(
                      trailing: Checkbox(
                          value: active,
                          onChanged: (value) {
                            if (value == true && active == false) {
                              active = true;

                              if (!status.contains('ACTIVE')) {
                                status.add('ACTIVE');
                              }
                            } else if (value == false) {
                              active = false;
                              if (status.contains('ACTIVE')) {
                                status.remove('ACTIVE');
                              }
                            }
                            settingsDataFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Active'),
                    ),
                    ListTile(
                      trailing: Checkbox(
                          value: inactive,
                          onChanged: (value) {
                            if (value == true && inactive == false) {
                              inactive = true;

                              if (!status.contains('IN-ACTIVE')) {
                                status.add('IN-ACTIVE');
                              }
                            } else if (value == false) {
                              inactive = false;
                              if (status.contains('IN-ACTIVE')) {
                                status.remove('IN-ACTIVE');
                              }
                            }
                            settingsDataFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('In Active'),
                    ),
                    ListTile(
                      trailing: Checkbox(
                          value: pending,
                          onChanged: (value) {
                            if (value == true && pending == false) {
                              pending = true;

                              if (!status.contains('PENDING')) {
                                status.add('PENDING');
                              }
                            } else if (value == false) {
                              pending = false;
                              if (status.contains('PENDING')) {
                                status.remove('PENDING');
                              }
                            }
                            settingsDataFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Pending'),
                    ),
                  ]))),
          ListTile(
            title: Text(
              'Gender',
              style: Constants.header2,
            ),
            trailing: IconButton(
              icon: Icon(showGender
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () {
                showGender = !showGender;
                setState(() {});
              },
            ),
          ),
          Visibility(
              visible: showGender,
              child: Container(
                  child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                    ListTile(
                      trailing: Checkbox(
                          value: maleGender,
                          onChanged: (value) {
                            if (value == true && maleGender == false) {
                              maleGender = true;

                              if (!gender.contains('MALE')) {
                                gender.add('MALE');
                              }
                            } else if (value == false) {
                              maleGender = false;
                              if (gender.contains('MALE')) {
                                gender.remove('MALE');
                              }
                            }
                            settingsDataFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Male'),
                    ),
                    ListTile(
                      trailing: Checkbox(
                          value: femaleGender,
                          onChanged: (value) {
                            if (value == true && femaleGender == false) {
                              femaleGender = true;

                              if (!gender.contains('FEMALE')) {
                                gender.add('FEMALE');
                              }
                            } else if (value == false) {
                              femaleGender = false;
                              if (gender.contains('FEMALE')) {
                                gender.remove('FEMALE');
                              }
                            }
                            settingsDataFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Female'),
                    ),
                    ListTile(
                      trailing: Checkbox(
                          value: otherGender,
                          onChanged: (value) {
                            if (value == true && otherGender == false) {
                              otherGender = true;

                              if (!gender.contains('OTHERS')) {
                                gender.add('OTHERS');
                              }
                            } else if (value == false) {
                              otherGender = false;
                              if (gender.contains('OTHERS')) {
                                gender.remove('OTHERS');
                              }
                            }
                            settingsDataFetched = false;
                            setState(() {});
                            _fetchFilterData();
                          }),
                      title: Text('Other'),
                    ),
                  ])))
        ],
      ),
    ));
  }

  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;
  Future<void> _fetchCenters() async {
    print('_fetchCenters');
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
        print('+++++++++++++success is in _fetchCenters+++++++++++++');
      } catch (e, s) {
        print('+++++++++++++error is in _fetchCenters+++++++++++++');
        print(e);
        print(s);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  Future<void> _fetchData() async {
    SettingsApiHandler handler = SettingsApiHandler({
      "userid": MyApp.LOGIN_ID_VALUE,
      "order": order,
      "centerid": centers[currentIndex].id
    });
    var data = await handler.getUsers();
    if (!data.containsKey('error')) {
      print(data);
      var users = data['users'];
      try {
        groupsData = data['groups'];
      } catch (e) {
        print(e.toString());
      }

      try {
        userStats = data['userStats'];
      } catch (e) {
        print(e.toString());
      }

      _allUsers = [];
      try {
        assert(users is List);
        for (int i = 0; i < users.length; i++) {
          _allUsers.add(UserModel.fromJson(users[i]));
        }
        for (int i = 0; i < groupsData.length; i++) {
          groupValues[groupsData[i]['name']] = false;
        }
        settingsDataFetched = true;
        print(userStats);
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  Future<void> _fetchFilterData() async {
    var _toSend = Constants.BASE_URL + 'Settings/getUsersSettings';

    var objToSend = {
      "groups": groups,
      "status": status,
      "gender": gender,
      "order": order,
      "userid": MyApp.LOGIN_ID_VALUE
    };
    print(jsonEncode(objToSend));
    final response = await http
        .post(Uri.parse(_toSend), body: jsonEncode(objToSend), headers: {
      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
    });
    print(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);

      var users = data['users'];
      groupsData = data['groups'];
      userStats = data['userStats'];
      _allUsers = [];
      try {
        assert(users is List);
        for (int i = 0; i < users.length; i++) {
          _allUsers.add(UserModel.fromJson(users[i]));
        }
        for (int i = 0; i < groupsData.length; i++) {
          groupValues[groupsData[i]['name']] = false;
        }
        settingsDataFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        endDrawer: getEndDrawer(context),
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: settingsDataFetched
                    ? Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            centersFetched
                                ? DropdownButtonHideUnderline(
                                    child: Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Constants.greyColor),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: Center(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: centers[currentIndex].id,
                                            items: centers
                                                .map((CentersModel value) {
                                              return new DropdownMenuItem<
                                                  String>(
                                                value: value.id,
                                                child:
                                                    new Text(value.centerName),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              for (int i = 0;
                                                  i < centers.length;
                                                  i++) {
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
                                  )
                                : Container(),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Text(
                                  'User Settings',
                                  style: Constants.header2,
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      if (order == 'ASC') {
                                        order = 'DESC';
                                      } else {
                                        order = 'ASC';
                                      }
                                      settingsDataFetched = false;
                                      setState(() {});
                                      _fetchFilterData();
                                    },
                                    child: Icon(
                                      Entypo.select_arrows,
                                      color: Constants.kButton,
                                    )),
                                // GestureDetector(
                                //     onTap: () {
                                //       key.currentState?.openEndDrawer();
                                //     },
                                //     child: Icon(
                                //       AntDesign.filter,
                                //       color: Constants.kButton,
                                //     )),
                                SizedBox(
                                  width: 5,
                                ),
                                if (MyApp.USER_TYPE_VALUE == 'Superadmin')
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddUser('add', '')))
                                          .then((value) {
                                        if (value != null) {
                                          settingsDataFetched = false;
                                          setState(() {});
                                          _fetchData();
                                        }
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Constants.kButton,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8))),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 8, 12, 8),
                                          child: Text(
                                            '+ Add User',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        )),
                                  )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                              child: Theme(
                                data: new ThemeData(
                                  primaryColor: Colors.grey,
                                  primaryColorDark: Colors.grey,
                                ),
                                child: Container(
                                  height: 33.0,
                                  width: MediaQuery.of(context).size.width,
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    keyboardType: TextInputType.text,
                                    //validator: validatePassword,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        labelStyle:
                                            new TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.grey)),
                                        hintStyle: new TextStyle(
                                          inherit: true,
                                          color: Colors.grey,
                                        ),
                                        hintText: 'Search By Name'),
                                    onChanged: (String val) {
                                      searchString = val;
                                      print(searchString);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  color: Constants.kContainer,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Total Users',
                                          style:
                                              Constants.containerHeadingStyle),
                                      Text(userStats['totalUsers'].toString(),
                                          style: Constants
                                              .containerNumberHeadingStyle)
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  color: Constants.kContainer,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Active Users',
                                          style:
                                              Constants.containerHeadingStyle),
                                      Text(userStats['activeUsers'].toString(),
                                          style: Constants
                                              .containerNumberHeadingStyle)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  color: Constants.kContainer,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('InActive Users',
                                          style:
                                              Constants.containerHeadingStyle),
                                      Text(
                                          userStats['inactiveUsers'].toString(),
                                          style: Constants
                                              .containerNumberHeadingStyle)
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.44,
                                  color: Constants.kContainer,
                                  height: 80,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Pending Users',
                                          style:
                                              Constants.containerHeadingStyle),
                                      Text(userStats['pendingUsers'].toString(),
                                          style: Constants
                                              .containerNumberHeadingStyle)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (_allUsers != null)
                              Container(
                                child: ListView.builder(
                                  itemCount: _allUsers.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return userCard(index);
                                  },
                                ),
                              ),
                          ]))
                    : Container())));
  }

  Widget userCard(int index) {
    return _allUsers[index]
                .name
                .toLowerCase()
                .contains(searchString.toLowerCase()) &&
            _allUsers[index].userType != 'Parent'
        ? Card(
            child: Container(
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                                Constants.ImageBaseUrl +
                                    _allUsers[index].imageUrl)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                              onTap: () {
                                if (MyApp.USER_TYPE_VALUE == 'Superadmin') {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AddUser(
                                                  'edit',
                                                  _allUsers[index].userid)))
                                      .then((value) {
                                    if (value != null) {
                                      settingsDataFetched = false;
                                      setState(() {});
                                      _fetchData();
                                    }
                                  });
                                }
                              },
                              child: Text(_allUsers[index].name,
                                  style: Constants.cardHeadingStyle)),
                          SizedBox(
                            height: 10,
                          ),
                          Builder(
                            builder: (context) {
                              String? text;
                              try{
                                text = _allUsers[index].userStatus;
                              }catch(e){
                                  debugPrint(e.toString());
                              }
                              return Text(text.toString());
                            }
                          ),
                          // Text(_allUsers[index].dob)
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        : Container();
  }
}
