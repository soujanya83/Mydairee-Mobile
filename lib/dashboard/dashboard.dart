import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/announcements/announcementslist.dart';
import 'package:mykronicle_mobile/api/dashboardapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/observation/childdetails.dart';
import 'package:mykronicle_mobile/observation/observationmain.dart';
import 'package:mykronicle_mobile/rooms/roomslist.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/usersettings.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';

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

  DateTime _focusDay = DateTime.now();
  Future<void> _fetchData({DateTime? date}) async {
    print('get getCalendarDetails');
    DateFormat inputFormat = DateFormat("yyyy-MM-dd");
    print("loggg" + MyApp.LOGIN_ID_VALUE);
    DashboardAPIHandler handler = DashboardAPIHandler({});
    //  var dateDetails = await handler.getCalendarDetails();
    var data = await handler.getCalendarDetails(date: date);
    print('getCalendarDetails == getCalendarDetails');
    print(data);
    if (!data.containsKey('error')) {
      dateDetails = data;
      // var ann = data['Announcements'];
      // print(ann);
      // for (var i = 0; i < ann.length; i++) {
      //   dates.add(inputFormat.parse(ann[i]['eventDate']));

      //   if (dateDetails.containsKey(inputFormat.parse(ann[i]['eventDate']))) {
      //     List n = dateDetails[inputFormat.parse(ann[i]['eventDate'])];
      //     n.add({"event": 'announcement', "extra": ann[i]['title']});
      //     dateDetails[inputFormat.parse(ann[i]['eventDate'])] = n;
      //   } else {
      //     List m = [];
      //     m.add({"event": 'announcement', "extra": ann[i]['title']});
      //     dateDetails[inputFormat.parse(ann[i]['eventDate'])] = m;
      //   }
      // }
      // var staff = data['StaffBirthdays'];
      // print(staff);
      // for (var i = 0; i < staff.length; i++) {
      //   dates.add(inputFormat.parse(
      //       now.year.toString() + staff[i]['dob'].toString().substring(4)));
      //   if (dateDetails.containsKey(inputFormat.parse(
      //       now.year.toString() + staff[i]['dob'].toString().substring(4)))) {
      //     List n = dateDetails[inputFormat.parse(
      //         now.year.toString() + staff[i]['dob'].toString().substring(4))];
      //     n.add({
      //       "event": 'StaffBirthdays',
      //       "extra": staff[i]['name'] + '(Staff Birthday)'
      //     });
      //     dateDetails[inputFormat.parse(now.year.toString() +
      //         staff[i]['dob'].toString().substring(4))] = n;
      //   } else {
      //     List m = [];
      //     m.add({
      //       "event": 'StaffBirthdays',
      //       "extra": staff[i]['name'] + '(Staff Birthday)'
      //     });
      //     dateDetails[inputFormat.parse(now.year.toString() +
      //         staff[i]['dob'].toString().substring(4))] = m;
      //   }
      // }
      // var pub = data['PublicHolidays'];
      // print(pub);
      // for (var i = 0; i < pub.length; i++) {
      //   dates.add(inputFormat.parse(pub[i]['date']));

      //   if (dateDetails.containsKey(inputFormat.parse(pub[i]['date']))) {
      //     List n = dateDetails[inputFormat.parse(pub[i]['date'])];
      //     n.add({"event": 'PublicHolidays', "extra": pub[i]['occasion']});
      //     dateDetails[inputFormat.parse(pub[i]['date'])] = n;
      //   } else {
      //     List m = [];
      //     m.add({"event": 'PublicHolidays', "extra": pub[i]['occasion']});
      //     dateDetails[inputFormat.parse(pub[i]['date'])] = m;
      //   }
      // }
      // var child = data['ChildBirthdays'];
      // for (var i = 0; i < child.length; i++) {
      //   dates.add(inputFormat.parse(
      //       now.year.toString() + child[i]['dob'].toString().substring(4)));

      //   if (dateDetails.containsKey(inputFormat.parse(
      //       now.year.toString() + child[i]['dob'].toString().substring(4)))) {
      //     List n = dateDetails[inputFormat.parse(
      //         now.year.toString() + child[i]['dob'].toString().substring(4))];
      //     n.add({
      //       "event": 'ChildBirthdays',
      //       "extra": child[i]['name'] + '(Child Birthday)'
      //     });
      //     dateDetails[inputFormat.parse(now.year.toString() +
      //         child[i]['dob'].toString().substring(4))] = n;
      //   } else {
      //     List m = [];
      //     m.add({
      //       "event": 'ChildBirthdays',
      //       "extra": child[i]['name'] + '(Child Birthday)'
      //     });
      //     dateDetails[inputFormat.parse(now.year.toString() +
      //         child[i]['dob'].toString().substring(4))] = m;
      //   }
      // }
      // if (this.mounted) setState(() {});
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
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomCard(
                      title: MyApp.USER_TYPE_VALUE != 'Parent'
                          ? 'Rooms'
                          : 'Upcoming Events',
                      count: details != null
                          ? MyApp.USER_TYPE_VALUE != 'Parent'
                              ? details['roomsCount'] ?? 0
                              : details['upcomingEventsCount'] ?? 0
                          : 0,
                      imagePath: Constants.ROOM_IMG,
                      onTap: () {
                        if (MyApp.USER_TYPE_VALUE != 'Parent') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RoomsList()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnnouncementsList()),
                          );
                        }
                      },
                    ),
                    CustomCard(
                      title: MyApp.USER_TYPE_VALUE != 'Parent'
                          ? 'Staff'
                          : 'Observation',
                      count: details != null
                          ? MyApp.USER_TYPE_VALUE != 'Parent'
                              ? details['staffCount'] ?? 0
                              : details['observationCount'] ?? 0
                          : 0,
                      imagePath: Constants.ANALYTICS_IMG,
                      onTap: () {
                        if (MyApp.USER_TYPE_VALUE != 'Parent') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserSettings(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ObservationMain(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: (MediaQuery.of(context).size.width * 0.02),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomCard(
                      title: 'Children',
                      count:
                          details != null ? details['childrenCount'] ?? 0 : 0,
                      imagePath: Constants.STUDENTS_IMG,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildDetails(
                              childId: '',
                              centerId: '',
                            ),
                          ),
                        );
                      },
                    ),
                    CustomCard(
                      title: 'Events',
                      count: details != null ? details['eventsCount'] ?? 0 : 0,
                      imagePath: Constants.ACTIVITIES_IMG,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnouncementsList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                //observation count not added

                // Container(
                //   width: MediaQuery.of(context).size.width * 0.92,
                //   height: 300,
                //   child: WebViewWidget(controller: _webViewController),
                // ),
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
                          // Row(
                          //   children: <Widget>[
                          //     IconButton(
                          //       icon: Icon(Icons.arrow_back_ios),
                          //       onPressed: () {
                          //         setState(() {
                          //           if (month == 1) {
                          //             month = 12;
                          //             currentMon = (months.isNotEmpty
                          //                 ? months[month - 1]
                          //                 : "");
                          //             year = ((int.tryParse(year) ?? 0) - 1)
                          //                 .toString();
                          //           } else {
                          //             month = month - 1;
                          //             currentMon = (months.length >= month
                          //                 ? months[month - 1]
                          //                 : "");
                          //           }
                          //         });
                          //       },
                          //     ),
                          //     Expanded(
                          //       child: Center(
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(8.0),
                          //           child: Text(
                          //             '${currentMon ?? ""} ${year ?? ""}',
                          //             style: TextStyle(fontSize: 16),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     IconButton(
                          //       icon: Icon(Icons.arrow_forward_ios),
                          //       onPressed: () {
                          //         setState(() {
                          //           if (month + 1 == 13) {
                          //             year = ((int.tryParse(year) ?? 0) + 1)
                          //                 .toString();
                          //             month = 1;
                          //             currentMon = (months.isNotEmpty
                          //                 ? months[month - 1]
                          //                 : "");
                          //           } else {
                          //             month = month + 1;
                          //             currentMon = (months.length >= month
                          //                 ? months[month - 1]
                          //                 : "");
                          //           }
                          //         });
                          //       },
                          //     ),
                          //   ],
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TableCalendar(
                              onPageChanged: (focusedDay) {
                                _focusDay = focusedDay;
                                _fetchData(date: focusedDay);
                              },
                              firstDay: DateTime.utc(2000, 1, 1),
                              lastDay: DateTime.utc(2100, 12, 31),
                              focusedDay: _focusDay,
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  final dateString =
                                      DateFormat('yyyy-MM-dd').format(date);
                                  bool hasEvent = false;
                                  String? eventType;

                                  if ((dateDetails['PublicHolidays'] ?? [])
                                      .isNotEmpty) {
                                    for (var holiday
                                        in dateDetails['PublicHolidays']) {
                                      if ((holiday['date'] ?? "") ==
                                          dateString) {
                                        hasEvent = true;
                                        eventType = 'holiday';
                                        break;
                                      }
                                    }
                                  }

                                  if (!hasEvent &&
                                      (dateDetails['ChildBirthdays'] ?? [])
                                          .isNotEmpty) {
                                    for (var birthday
                                        in dateDetails['ChildBirthdays']) {
                                      final dob = (birthday['dob'] ?? "")
                                          .toString()
                                          .split(' ')[0];
                                      if (dob == dateString) {
                                        hasEvent = true;
                                        eventType = 'birthday';
                                        break;
                                      }
                                    }
                                  }

                                  if (hasEvent) {
                                    return Positioned(
                                      bottom: 1,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: eventType == 'holiday'
                                              ? Colors.red
                                              : Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                              selectedDayPredicate: (day) {
                                final dateString =
                                    DateFormat('yyyy-MM-dd').format(day);

                                if ((dateDetails['PublicHolidays'] ?? [])
                                    .isNotEmpty) {
                                  for (var holiday
                                      in dateDetails['PublicHolidays']) {
                                    if ((holiday['date'] ?? "") == dateString)
                                      return true;
                                  }
                                }

                                if ((dateDetails['ChildBirthdays'] ?? [])
                                    .isNotEmpty) {
                                  for (var birthday
                                      in dateDetails['ChildBirthdays']) {
                                    final dob = (birthday['dob'] ?? "")
                                        .toString()
                                        .split(' ')[0];
                                    if (dob == dateString) return true;
                                  }
                                }

                                return false;
                              },
                              calendarFormat: CalendarFormat.month,
                              availableGestures: AvailableGestures.all,
                              onDaySelected: (selectedDay, focusedDay) {
                                final dateString = DateFormat('yyyy-MM-dd')
                                    .format(selectedDay);
                                final events = <Map<String, dynamic>>[];

                                if ((dateDetails['PublicHolidays'] ?? [])
                                    .isNotEmpty) {
                                  for (var holiday
                                      in dateDetails['PublicHolidays']) {
                                    if ((holiday['date'] ?? "") == dateString) {
                                      events.add({
                                        'type': 'Public Holiday',
                                        'title': holiday['occasion'] ?? "",
                                        'extra': (holiday['state'] ?? "")
                                                .isNotEmpty
                                            ? '${holiday['occasion'] ?? ""} (${holiday['state']})'
                                            : holiday['occasion'] ?? "",
                                      });
                                    }
                                  }
                                }

                                if ((dateDetails['ChildBirthdays'] ?? [])
                                    .isNotEmpty) {
                                  for (var birthday
                                      in dateDetails['ChildBirthdays']) {
                                    final dob = (birthday['dob'] ?? "")
                                        .toString()
                                        .split(' ')[0];
                                    if (dob == dateString) {
                                      events.add({
                                        'type': 'Birthday',
                                        'title':
                                            '${birthday['name'] ?? ""} ${birthday['lastname'] ?? ""}',
                                        'extra':
                                            '${birthday['name'] ?? ""}\'s Birthday',
                                      });
                                    }
                                  }
                                }

                                if (events.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Event Details',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Constants.kBlack,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Event: ',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: events[0]
                                                              ['title'] ??
                                                          "",
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.black
                                                            .withOpacity(.7),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Date: ${DateFormat('MMMM d, y').format(selectedDay)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 24),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                    'Close',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final dynamic count;
  final String imagePath;
  final VoidCallback onTap;

  const CustomCard({
    Key? key,
    required this.title,
    required this.count,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.46,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Card(
            elevation: 0, // Set to 0 to avoid double shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [ 
                      SizedBox(
                        width: MediaQuery.of(context).size.width*.25,
                        child: AutoSizeText(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
