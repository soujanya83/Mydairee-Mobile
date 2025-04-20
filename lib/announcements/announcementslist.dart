import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:mykronicle_mobile/announcements/newannouncements.dart';
import 'package:mykronicle_mobile/api/announcementsapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/announcementmodel.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/utils/removeTags.dart';

class AnnouncementsList extends StatefulWidget {
  @override
  _AnnouncementsListState createState() => _AnnouncementsListState();
}

class _AnnouncementsListState extends State<AnnouncementsList> {
  bool announcementsFetched = false;
  List<AnnouncementModel> _announcements = [];
  late List<CentersModel> centers;
  bool centersFetched = false;
  int currentIndex = 0;

  bool permission = true;
  bool permissionAdd = true;

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
      //MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  Future<void> _fetchData() async {
    AnnouncementsAPIHandler handler = AnnouncementsAPIHandler(
        {"userid": MyApp.LOGIN_ID_VALUE, "centerid": centers[currentIndex].id});
    var data = await handler.getList(centers[currentIndex].id.toString());
    if (!data.containsKey('error')) {
      if (data['permissions'] != null ||
          MyApp.USER_TYPE_VALUE == 'Superadmin' ||
          MyApp.USER_TYPE_VALUE == 'Parent') {
        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            MyApp.USER_TYPE_VALUE == 'Parent' ||
            data['permissions']['addAnnouncement'] == '1') {
          permissionAdd = true;
        } else {
          permissionAdd = false;
        }

        if (MyApp.USER_TYPE_VALUE == 'Superadmin' ||
            MyApp.USER_TYPE_VALUE == 'Parent' ||
            data['permissions']['viewAllAnnouncement'] == '1') {
          var res = data['records'];
          _announcements = [];
          try {
            assert(res is List);
            for (int i = 0; i < res.length; i++) {
              _announcements.add(AnnouncementModel.fromJson(res[i]));
            }
            announcementsFetched = true;
            permission = true;
            if (this.mounted) setState(() {});
          } catch (e) {
            print(e);
          }
        } else {
          permission = false;
        }
      } else {
        permission = false;
        permissionAdd = false;
      }
      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: floating(context),
        drawer: GetDrawer(),
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Announcements',
                          style: Constants.header1,
                        ),
                        if (permissionAdd && MyApp.USER_TYPE_VALUE != 'Parent')
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewAnnouncements(
                                            type: 'new',
                                            centerid: centers[currentIndex].id,
                                            id: '',
                                          )));
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
                                    'Add New',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                )),
                          )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if (centersFetched)
                      DropdownButtonHideUnderline(
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
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
                    if (!announcementsFetched && permission)
                      Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('Loading...')],
                          )),
                    if (!permission)
                      Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("You don't have permission for this center")
                            ],
                          )),
                    if (announcementsFetched &&
                        _announcements.length == 0 &&
                        permission)
                      Container(
                          child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Center(
                              child: SizedBox(
                                  height: 100.0,
                                  child: Image.asset(Constants.FILE))),
                          Text('No announcements')
                        ],
                      )),
                    if (announcementsFetched &&
                        permission &&
                        _announcements.length > 0)
                      Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            itemCount: _announcements != null
                                ? _announcements.length
                                : 0,
                            itemBuilder: (BuildContext context, int index) {
                              var inputFormat = DateFormat("yyyy-MM-dd");
                              final DateFormat formatter =
                                  DateFormat('dd-MM-yyyy');

                              var date1 = inputFormat
                                  .parse(_announcements[index].eventDate);
                              var date = formatter.format(date1);

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: GestureDetector(
                                  onTap: () {
                                    if (MyApp.USER_TYPE_VALUE != 'Parent') {
                                      print(_announcements[index].id);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewAnnouncements(
                                                    type: 'update',
                                                    id: _announcements[index]
                                                        .aid,
                                                    centerid:
                                                        centers[currentIndex]
                                                            .id,
                                                  )));
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              children: [
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.35,
                                                    child: Text(
                                                      _announcements[index]
                                                          .title,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Constants.kMain),
                                                    )),
                                                Spacer(),
                                                Text('By: ' +
                                                    _announcements[index]
                                                        .createdBy),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Builder(
                                                        builder: (context) {
                                                          Timer(Duration(seconds: 3), (){
                                                            print( _announcements[index]
                                                            .eventDate.toString());
                                                          });
                                                      
                                                          return Text(_announcements[index]
                                                            .eventDate.toString());
                                                        }
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Container(),
                                              ),
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color: _announcements[
                                                                      index]
                                                                  .status ==
                                                              'Sent'
                                                          ? Colors.green
                                                          : Color(0xffFFEFB8),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(20, 8, 20, 8),
                                                    child: Text(
                                                      _announcements[index]
                                                          .status,
                                                      style: TextStyle(
                                                          color: _announcements[
                                                                          index]
                                                                      .status ==
                                                                  'Sent'
                                                              ? Colors.white
                                                              : Color(
                                                                  0xffCC9D00)),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Builder(builder: (context) {
                                                String htmlToPlainText(
                                                    String htmlString) {
                                                  final document =
                                                      parse(htmlString);
                                                  return parse(document
                                                                  .body?.text ??
                                                              "")
                                                          .documentElement
                                                          ?.text ??
                                                      "";
                                                }

                                                return SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      55,
                                                  child: Text(
                                                    htmlToPlainText(
                                                        _announcements[index]
                                                            .text),
                                                    maxLines: 4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
                  ],
                )))));
  }
}
