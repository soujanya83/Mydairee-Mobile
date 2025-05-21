import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/surveyapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/models/surveymodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/surveys/addsurvey.dart';
import 'package:mykronicle_mobile/surveys/saveSurvey.dart';
import 'package:mykronicle_mobile/utils/deleteDialog.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:intl/intl.dart';

class SurveyList extends StatefulWidget {
  @override
  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  bool surveyFetched = false;
  List<SurveyModel> _survey = [];

  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;
  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  bool permissionShow = true;
  bool permissionAdd = true;
  bool permissionEdit = true;
  bool permissionDelete = true;

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    print(dt);
    if (!dt.containsKey('error')) {
      print(dt);
      if (dt['permissions'] != null) {
        if (dt['permissions']['add'] == null) {
          permissionAdd = false;
        }
        if (dt['permissions']['edit'] == null) {
          permissionEdit = false;
        }
        if (dt['permissions']['delete'] == null) {
          permissionDelete = false;
        }
      } else {
        permissionAdd = false;
        permissionDelete = false;
        permissionEdit = false;
      }
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

  bool loading = true;
  Future<void> _fetchData() async {
    if (this.mounted)
      setState(() {
        loading = true;
      });
    SurveyAPIHandler handler = SurveyAPIHandler({
      "userid": MyApp.LOGIN_ID_VALUE,
      "centerid": centers[currentIndex].id,
      "usertype": MyApp.USER_TYPE_VALUE
    });
    var data = await handler.getList();
    if (!data.containsKey('error')) {
      print(data);
      var res = data['records'];
      _survey = [];
      try {
        if (res != null) {
          assert(res is List);
          for (int i = 0; i < res.length; i++) {
            _survey.add(SurveyModel.fromJson(res[i]));
          }
        } else {
          if (data['errormsg']
              .toString()
              .toLowerCase()
              .contains('permission')) {
            permissionShow = false;
          }
        }

        surveyFetched = true;
        if (this.mounted)
          setState(() {
            loading = false;
          });
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
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: surveyFetched && centersFetched
                    ? Container(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          centersFetched
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: DropdownButtonHideUnderline(
                                    child: Container(
                                      height: 40,
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
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                'Survey',
                                style: Constants.header1,
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              if ((MyApp.USER_TYPE_VALUE != 'Parent' &&
                                      permissionAdd) ||
                                  (MyApp.USER_TYPE_VALUE == 'Superadmin'))
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddSurvey(
                                                  type: 'add',
                                                  id: '',
                                                  centerId:
                                                      centers[currentIndex].id,
                                                ))).then(
                                        (value) => _fetchData());
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
                                          'Add New',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      )),
                                )
                            ],
                          ),
                          !(surveyFetched && !loading)
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * .7,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: 40,
                                          width: 40,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator())),
                                    ],
                                  ))
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.75,
                                  width: MediaQuery.of(context).size.width,
                                  child: _survey.length == 0
                                      ? ((!permissionShow) &&
                                              (MyApp.USER_TYPE_VALUE !=
                                                  'Superadmin')
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    "You need permission to view all surveys!"),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("No survey found"),
                                              ],
                                            ))
                                      : ListView.builder(
                                          itemCount: _survey != null
                                              ? _survey.length
                                              : 0,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            var inputFormat =
                                                DateFormat("yyyy-MM-dd");
                                            final DateFormat formatter =
                                                DateFormat('dd-MM-yyyy');

                                            var date1 = inputFormat.parse(
                                                _survey[index].createdAt);
                                            var date = formatter.format(date1);

                                            return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 8, 0, 8),
                                                child: Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      )
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 5,
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          SaveSurvey(
                                                                        id: _survey[index]
                                                                            .id,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Text(
                                                                  _survey[index]
                                                                              .title !=
                                                                          null
                                                                      ? _survey[
                                                                              index]
                                                                          .title
                                                                      : '',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Constants
                                                                        .kMain,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 2,
                                                                ),
                                                              ),
                                                            ),
                                                            if (_survey[index]
                                                                    .createdByName !=
                                                                null)
                                                              Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                  'By: ${_survey[index].createdByName.toString()}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 12),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              date.toString(),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            if ((MyApp.USER_TYPE_VALUE !=
                                                                        'Parent' &&
                                                                    permissionEdit) ||
                                                                (MyApp.USER_TYPE_VALUE ==
                                                                    'Superadmin')) ...[
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              AddSurvey(
                                                                        type:
                                                                            'edit',
                                                                        centerId:
                                                                            centers[currentIndex].id,
                                                                        id: _survey[index]
                                                                            .id,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Constants
                                                                        .kMain
                                                                        .withOpacity(
                                                                            0.1),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons.edit,
                                                                    color: Constants
                                                                        .kMain,
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 8),
                                                              if (permissionDelete ||
                                                                  (MyApp.USER_TYPE_VALUE ==
                                                                      'Superadmin'))
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    showDeleteDialog(
                                                                        context,
                                                                        () async {
                                                                      SurveyAPIHandler
                                                                          handler =
                                                                          SurveyAPIHandler({
                                                                        "userid":
                                                                            MyApp.LOGIN_ID_VALUE,
                                                                        "id": _survey[index]
                                                                            .id,
                                                                      });
                                                                      var data =
                                                                          await handler
                                                                              .deleteListItem();
                                                                      print('heyys' +
                                                                          data.toString());
                                                                      if (!data
                                                                          .containsKey(
                                                                              'error')) {
                                                                        surveyFetched =
                                                                            false;
                                                                        _fetchData();
                                                                        setState(
                                                                            () {});
                                                                      }
                                                                      Navigator.pop(
                                                                          context);
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(6),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .red
                                                                          .withOpacity(
                                                                              0.1),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child: Icon(
                                                                      AntDesign
                                                                          .delete,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                          }),
                                )
                        ],
                      ))
                    : Container(
                        height: MediaQuery.of(context).size.height * .7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 40,
                                width: 40,
                                child:
                                    Center(child: CircularProgressIndicator())),
                          ],
                        )))));
  }
}
