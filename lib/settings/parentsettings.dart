import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/parentmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/addparent.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class ParentSettings extends StatefulWidget {
  @override
  _ParentSettingsState createState() => _ParentSettingsState();
}

class _ParentSettingsState extends State<ParentSettings> {
  String searchString = '';

  String order = 'ASC';
  bool settingsDataFetched = false;
  List<ParentModel> _allParents = [];
  Map<String, dynamic> parentStats = {};

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
      // "order": order,
      "centerid": centers[currentIndex].id
    });

    var data = await handler.getParents();

    if (!data.containsKey('error')) {
      print(data);
      parentStats = data['parentStats'];
      var parents = data['parents'];
      _allParents = [];
      try {
        assert(parents is List);
        for (int i = 0; i < parents.length; i++) {
          _allParents.add(ParentModel.fromJson(parents[i]));
        }
        settingsDataFetched = true;
        print(parentStats);
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
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: settingsDataFetched
            ? SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Row(
                            children: [
                              Text(
                                'Parent Settings',
                                style: Constants.header2,
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    _allParents = _allParents.reversed.toList();
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Entypo.select_arrows,
                                    color: Constants.kButton,
                                  )),
                              // GestureDetector(
                              //     onTap: () {
                              //       //   key.currentState?.openEndDrawer();
                              //     },
                              //     child: Icon(
                              //       AntDesign.filter,
                              //       color: Constants.kButton,
                              //     )),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AddParent(
                                                  'add',
                                                  '',
                                                  centers[currentIndex].id)))
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
                                        '+ Add Parent',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    )),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
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
                                          items:
                                              centers.map((CentersModel value) {
                                            return new DropdownMenuItem<String>(
                                              value: value.id,
                                              child: new Text(value.centerName),
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
                            height: 20,
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
                                width: MediaQuery.of(context).size.width * 0.44,
                                color: Constants.kContainer,
                                height: 80,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Total Parents',
                                        style: Constants.containerHeadingStyle),
                                    Text(parentStats['totalParents'].toString(),
                                        style: Constants
                                            .containerNumberHeadingStyle)
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.44,
                                color: Constants.kContainer,
                                height: 80,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Active Parents',
                                        style: Constants.containerHeadingStyle),
                                    Text(
                                        parentStats['activeParents'].toString(),
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
                                width: MediaQuery.of(context).size.width * 0.44,
                                color: Constants.kContainer,
                                height: 80,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('InActive Parents',
                                        style: Constants.containerHeadingStyle),
                                    Text(
                                        parentStats['inactiveParents']
                                            .toString(),
                                        style: Constants
                                            .containerNumberHeadingStyle)
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.44,
                                color: Constants.kContainer,
                                height: 80,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Pending Parents',
                                        style: Constants.containerHeadingStyle),
                                    Text(
                                        parentStats['pendingParents']
                                            .toString(),
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
                          Container(
                            child: ListView.builder(
                              itemCount: _allParents.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return parentCard(index);
                              },
                            ),
                          ),
                        ]))))
            : Container());
  }

  Widget parentCard(int index) {
    return _allParents[index]
            .name
            .toLowerCase()
            .contains(searchString.toLowerCase())
        ? Card(
            child: Container(
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  // Row(
                  //   children: [
                  //     DropdownButtonHideUnderline(
                  //       child: Container(
                  //         height: 40,
                  //         width: 120,
                  //         child: Padding(
                  //           padding: const EdgeInsets.only(left: 8, right: 8),
                  //           child: Center(
                  //               child: DropdownButton<String>(
                  //             isExpanded: true,
                  //             value: _chosenValue,
                  //             items: <String>['Active', 'B', 'C', 'D']
                  //                 .map((String value) {
                  //               return new DropdownMenuItem<String>(
                  //                 value: value,
                  //                 child: new Text(value),
                  //               );
                  //             }).toList(),
                  //              onChanged: (String? value)  {
                  //               setState(() {
                  //                 _chosenValue = value!;
                  //               });
                  //             },
                  //           )),
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Container(),
                  //     ),
                  //     InkWell(
                  //         onTap: null,
                  //         child: Icon(
                  //           Icons.edit,
                  //           color: Colors.grey,
                  //         )),
                  //     Checkbox(
                  //       value: false,
                  //       onChanged: null,
                  //     ),
                  //   ],
                  // ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                _allParents[index].imageUrl != null &&
                                        _allParents[index].imageUrl != ''
                                    ? NetworkImage(Constants.ImageBaseUrl +
                                        _allParents[index].imageUrl)
                                    : null),
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
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddParent(
                                                'edit',
                                                _allParents[index].userId,
                                                centers[currentIndex].id)))
                                    .then((value) {
                                  if (value != null) {
                                    settingsDataFetched = false;
                                    setState(() {});
                                    _fetchData();
                                  }
                                });
                              },
                              child: Text(_allParents[index].name,
                                  style: Constants.cardHeadingStyle)),
                          Text(_allParents[index].status != null
                              ? _allParents[index].status
                              : ''),
                          Text(_allParents[index].dob != null
                              ? _allParents[index].dob
                              : '')
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
