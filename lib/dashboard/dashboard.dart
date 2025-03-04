
import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/announcements/announcementslist.dart';
import 'package:mykronicle_mobile/api/dashboardapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/observation/childdetails.dart';
import 'package:mykronicle_mobile/observation/observationmain.dart';
import 'package:mykronicle_mobile/rooms/roomslist.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/settingslist.dart';
import 'package:mykronicle_mobile/settings/usersettings.dart';
import 'package:mykronicle_mobile/utils/day_tile_builder.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Dashboard extends StatefulWidget {
  static String Tag = Constants.DASHBOARD_TAG;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static List months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static var now = new DateTime.now();
  static int month = int.parse(now.month.toString());
  String currentMon = months[month - 1];
  String year = now.year.toString();
  List<DateTime> dates = [];
  var details;
  var dateDetails = new Map();

  late final WebViewController _webViewController;
  @override
  void initState() {
    _fetchData();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse("https://flutter.dev"));
    super.initState();
  }

  Future<void> _fetchData() async {
    DateFormat inputFormat = DateFormat("yyyy-MM-dd");
    print("loggg" + MyApp.LOGIN_ID_VALUE);
    DashboardAPIHandler handler = DashboardAPIHandler({});
    var data = await handler.getCalendarDetails();
    if (!data.containsKey('error')) {
      var ann = data['Announcements'];
      print(ann);
      for (var i = 0; i < ann.length; i++) {
        dates.add(inputFormat.parse(ann[i]['eventDate']));

        if (dateDetails.containsKey(inputFormat.parse(ann[i]['eventDate']))) {
          List n = dateDetails[inputFormat.parse(ann[i]['eventDate'])];
          n.add({"event": 'announcement', "extra": ann[i]['title']});
          dateDetails[inputFormat.parse(ann[i]['eventDate'])] = n;
        } else {
          List m = [];
          m.add({"event": 'announcement', "extra": ann[i]['title']});
          dateDetails[inputFormat.parse(ann[i]['eventDate'])] = m;
        }
      }
      var staff = data['StaffBirthdays'];
      print(staff);
      for (var i = 0; i < staff.length; i++) {
        dates.add(inputFormat.parse(
            now.year.toString() + staff[i]['dob'].toString().substring(4)));
        if (dateDetails.containsKey(inputFormat.parse(
            now.year.toString() + staff[i]['dob'].toString().substring(4)))) {
          List n = dateDetails[inputFormat.parse(
              now.year.toString() + staff[i]['dob'].toString().substring(4))];
          n.add({
            "event": 'StaffBirthdays',
            "extra": staff[i]['name'] + '(Staff Birthday)'
          });
          dateDetails[inputFormat.parse(now.year.toString() +
              staff[i]['dob'].toString().substring(4))] = n;
        } else {
          List m = [];
          m.add({
            "event": 'StaffBirthdays',
            "extra": staff[i]['name'] + '(Staff Birthday)'
          });
          dateDetails[inputFormat.parse(now.year.toString() +
              staff[i]['dob'].toString().substring(4))] = m;
        }
      }
      var pub = data['PublicHolidays'];
      print(pub);
      for (var i = 0; i < pub.length; i++) {
        dates.add(inputFormat.parse(pub[i]['date']));

        if (dateDetails.containsKey(inputFormat.parse(pub[i]['date']))) {
          List n = dateDetails[inputFormat.parse(pub[i]['date'])];
          n.add({"event": 'PublicHolidays', "extra": pub[i]['occasion']});
          dateDetails[inputFormat.parse(pub[i]['date'])] = n;
        } else {
          List m = [];
          m.add({"event": 'PublicHolidays', "extra": pub[i]['occasion']});
          dateDetails[inputFormat.parse(pub[i]['date'])] = m;
        }
      }
      var child = data['ChildBirthdays'];
      for (var i = 0; i < child.length; i++) {
        dates.add(inputFormat.parse(
            now.year.toString() + child[i]['dob'].toString().substring(4)));

        if (dateDetails.containsKey(inputFormat.parse(
            now.year.toString() + child[i]['dob'].toString().substring(4)))) {
          List n = dateDetails[inputFormat.parse(
              now.year.toString() + child[i]['dob'].toString().substring(4))];
          n.add({
            "event": 'ChildBirthdays',
            "extra": child[i]['name'] + '(Child Birthday)'
          });
          dateDetails[inputFormat.parse(now.year.toString() +
              child[i]['dob'].toString().substring(4))] = n;
        } else {
          List m = [];
          m.add({
            "event": 'ChildBirthdays',
            "extra": child[i]['name'] + '(Child Birthday)'
          });
          dateDetails[inputFormat.parse(now.year.toString() +
              child[i]['dob'].toString().substring(4))] = m;
        }
      }
      if (this.mounted) setState(() {});
      //print(_allQips[0].name);
    } else {
      MyApp.Show401Dialog(context);
    }

    DashboardAPIHandler hand = DashboardAPIHandler({});
    var dat = await hand.getDashboardDetails();
    if (!dat.containsKey('error')) {
      details = dat;

      if (this.mounted) setState(() {});
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
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (MyApp.USER_TYPE_VALUE != 'Parent') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RoomsList()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnnouncementsList()));
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.46,
                      child: Card(
                        child: Column(
                          children: [
                            SizedBox(
                                height: 110.0,
                                child: Image.asset(Constants.ROOM_IMG)),
                            MyApp.USER_TYPE_VALUE != 'Parent'
                                ? Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Text('Rooms'),
                                      Expanded(child: Container()),
                                      Text(details != null
                                          ? details['roomsCount'].toString()
                                          : ''),
                                      SizedBox(width: 5),
                                    ],
                                  )
                                : Container(),
                            MyApp.USER_TYPE_VALUE == 'Parent'
                                ? Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Text('Upcoming Events'),
                                      Expanded(child: Container()),
                                      Text(details != null
                                          ? details['upcomingEventsCount']
                                              .toString()
                                          : ''),
                                      SizedBox(width: 5),
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: 5,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (MyApp.USER_TYPE_VALUE != 'Parent') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserSettings()));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ObservationMain()));
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.46,
                      child: Card(
                        child: Column(
                          children: [
                            SizedBox(
                                height: 110.0,
                                child: Image.asset(Constants.ANALYTICS_IMG)),
                            MyApp.USER_TYPE_VALUE != 'Parent'
                                ? Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Text('Staff'),
                                      Expanded(child: Container()),
                                      Text(details != null
                                          ? details['staffCount'].toString()
                                          : ''),
                                      SizedBox(width: 5),
                                    ],
                                  )
                                : Container(),
                            MyApp.USER_TYPE_VALUE == 'Parent'
                                ? Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Text('Observation'),
                                      Expanded(child: Container()),
                                      Text(details != null
                                          ? details['observationCount']
                                              .toString()
                                          : ''),
                                      SizedBox(width: 5),
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: 5,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChildDetails(
                                    childId: '',
                                    centerId: '',
                                  )));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.46,
                      child: Card(
                        child: Column(
                          children: [
                            SizedBox(
                                height: 110.0,
                                child: Image.asset(Constants.STUDENTS_IMG)),
                            Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Children'),
                                Expanded(child: Container()),
                                Text(details != null
                                    ? details['childrenCount'].toString()
                                    : ''),
                                SizedBox(width: 5),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnnouncementsList()));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.46,
                      child: Card(
                        child: Column(
                          children: [
                            SizedBox(
                                height: 110.0,
                                child: Image.asset(Constants.ACTIVITIES_IMG)),
                            Row(
                              children: [
                                SizedBox(width: 5),
                                Text('Events'),
                                Expanded(child: Container()),
                                Text(details != null
                                    ? details['eventsCount'].toString()
                                    : ''),
                                SizedBox(width: 5),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              //observation count not added

              Container(
                width: MediaQuery.of(context).size.width * 0.92,
                height: 300,
                child: WebViewWidget(controller: _webViewController),
              ),
              Container(
                height: 20,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.68,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                setState(() {
                                  if (month == 1) {
                                    month = 12;
                                    currentMon = months[month - 1];
                                    year = (int.parse(year) - 1).toString();
                                  } else {
                                    month = month - 1;
                                    currentMon = months[month - 1];
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    currentMon + " " + year,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                setState(() {
                                  if (month + 1 == 13) {
                                    year = (int.parse(year) + 1).toString();
                                    month = 1;
                                    currentMon = months[month - 1];
                                  } else {
                                    month = month + 1;
                                    currentMon = months[month - 1];
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2000, 1, 1),
                            lastDay: DateTime.utc(2100, 12, 31),
                            focusedDay: DateTime(int.parse(year), month, 1),
                            selectedDayPredicate: (day) => dates.contains(day),
                            calendarFormat: CalendarFormat.month,
                            availableGestures: AvailableGestures.all,
                            onDaySelected: (selectedDay, focusedDay) {
                              if (dateDetails.containsKey(selectedDay)) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(DateFormat.yMMMMd('en_US')
                                          .format(selectedDay)),
                                      content: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        child: ListView.builder(
                                          itemCount: dateDetails[selectedDay]
                                                  ?.length ??
                                              0,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ListTile(
                                              title: Text(dateDetails[
                                                      selectedDay]![index]
                                                  ['extra']!),
                                            );
                                          },
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
