import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/announcements/announcementslist.dart';
import 'package:mykronicle_mobile/daily_dairy/accidents/accidents_reports.dart';
import 'package:mykronicle_mobile/daily_dairy/dailydairy_main.dart';
import 'package:mykronicle_mobile/daily_dairy/headchecks.dart';
import 'package:mykronicle_mobile/daily_dairy/sleep_check_list/sleep_check_list.dart';
import 'package:mykronicle_mobile/dashboard/dashboard.dart';
import 'package:mykronicle_mobile/login/usertype.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/media/mediaMenu.dart';
import 'package:mykronicle_mobile/menu/menulist.dart';
import 'package:mykronicle_mobile/montessori/lessonplan.dart';
import 'package:mykronicle_mobile/montessori/progressplan.dart';
import 'package:mykronicle_mobile/observation/observationmain.dart';
import 'package:mykronicle_mobile/programplans/planslist.dart';
import 'package:mykronicle_mobile/progress_notes/progressote.dart';
import 'package:mykronicle_mobile/qip/qiplist.dart';
import 'package:mykronicle_mobile/qip/selfAssesment/selfAssesmentList.dart';
import 'package:mykronicle_mobile/recipes/recipelist.dart';
import 'package:mykronicle_mobile/reflection/reflection_list.dart';
import 'package:mykronicle_mobile/resources/resourcelist.dart';
import 'package:mykronicle_mobile/rooms/roomslist.dart';
import 'package:mykronicle_mobile/servicedetails/saveservice.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/settingslist.dart';
import 'package:mykronicle_mobile/surveys/surveylist.dart';

enum PAGE_INDEX {
  DASHBOARD,
}

class Platform extends StatefulWidget {
  static final String Tag = Constants.PLATFORM_TAG;
  @override
  PlatformState createState() => PlatformState();
}

class PlatformState extends State<Platform> {
  PAGE_INDEX currentPage = PAGE_INDEX.DASHBOARD;

  @override
  Widget build(BuildContext context) {
    return Dashboard();
  }
}

class GetDrawer extends StatefulWidget {
  @override
  _GetDrawerState createState() => _GetDrawerState();
}

class _GetDrawerState extends State<GetDrawer> {
  bool show = false;
  bool showDailyDairy = false;
  bool showMontessori = false;
  bool showProgPlan = false;
  bool showQip = false;
  bool showAnnouncements = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child:
            // permissionFetched ?
            Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Constants.kGradient1, Constants.kGradient2],
        ),
      ),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.white,
            ),
            title: Text(
              Constants.DASHBOARD_TAG,
              style: Constants.sideHeadingStyle,
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Dashboard()));
            },
          ),
          Divider(
            color: Colors.white.withOpacity(0.8),
          ),
          ListTile(
            leading: Icon(
              Entypo.sound_mix,
              color: Colors.white,
            ),
            title: Text(
              Constants.OBSERVATION_MAIN_TAG,
              style: Constants.sideHeadingStyle,
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ObservationMain()));
            },
          ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            Divider(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.8),
            ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            ListTile(
              title: Text(
                Constants.QIP_TAG,
                style: Constants.sideHeadingStyle,
              ),
              leading: Icon(
                SimpleLineIcons.book_open,
                color: Colors.white,
              ),
              onTap: () {
                if (showQip == false) {
                  showQip = true;
                  setState(() {});
                } else {
                  showQip = false;
                  setState(() {});
                }
              },
            ),
          Visibility(
            visible: showQip,
            child: Column(
              children: [
                Divider(color: Colors.transparent),
                ListTile(
                  title: Text(
                    Constants.SELF_ASSESMENT_TAG,
                    style: Constants.sideHeadingStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SelfAssesment()));
                  },
                ),
                Divider(color: Colors.transparent),
                ListTile(
                  title: Text(
                    Constants.QIP_FULL_TAG,
                    style: Constants.sideHeadingStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => QipList()));
                  },
                ),
              ],
            ),
          ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            Divider(
              color: Colors.white.withOpacity(0.8),
            ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            ListTile(
              leading: Icon(
                FontAwesome.building,
                color: Colors.white,
              ),
              title: Text(
                Constants.ROOMS_TAG,
                style: Constants.sideHeadingStyle,
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => RoomsList()));
              },
            ),
          // if (MyApp.USER_TYPE_VALUE != 'Parent')
          Divider(
            color: Colors.white.withOpacity(0.8),
          ),
          // if (MyApp.USER_TYPE_VALUE != 'Parent')
          ListTile(
            leading: Icon(
              FontAwesome.newspaper_o,
              color: Colors.white,
            ),
            title: Text(
              Constants.PROGRAMPLANS_TAG,
              style: Constants.sideHeadingStyle,
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => PlansList()));
              // if (showProgPlan == false) {
              //   showProgPlan = true;
              //   setState(() {});
              // } else {
              //   showProgPlan = false;
              //   setState(() {});
              // }
            },
          ),
          // Visibility(
          //   visible: showProgPlan,
          //   child: Column(
          //     children: [
          //       Divider(color: Colors.transparent),
          //       ListTile(
          //         title: Text(
          //           Constants.PROGRAMPLANS_TAG,
          //           style: Constants.sideHeadingStyle,
          //         ),
          //         onTap: () {
          //           Navigator.of(context).push(
          //               MaterialPageRoute(builder: (context) => PlansList()));
          //         },
          //       ),
          //       Divider(color: Colors.transparent),
          //       ListTile(
          //         title: Text(
          //           Constants.LESSPLAN_TAG,
          //           style: Constants.sideHeadingStyle,
          //         ),
          //         onTap: () {},
          //       ),
          //     ],
          //   ),
          // ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            Divider(
              color: Colors.white.withOpacity(0.8),
            ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            ListTile(
              leading: Icon(
                Ionicons.md_image,
                color: Colors.white,
              ),
              title: Text(
                Constants.MEDIA_TAG,
                style: Constants.sideHeadingStyle,
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => MediaMenu()));
              },
            ),

          //

          Divider(
            color: Colors.white.withOpacity(0.8),
          ),

          ListTile(
            leading: Icon(
              AntDesign.sound,
              color: Colors.white,
            ),
            title: Text(
              Constants.ANNOUNCEMENTS_TAG,
              style: Constants.sideHeadingStyle,
            ),
            onTap: () {
              if (showAnnouncements == false) {
                showAnnouncements = true;
                setState(() {});
              } else {
                showAnnouncements = false;
                setState(() {});
              }
            },
          ),
          Visibility(
            visible: showAnnouncements,
            child: Column(
              children: [
                Divider(color: Colors.transparent),
                ListTile(
                  title: Text(
                    Constants.ANNOUNCEMENTS_TAG,
                    style: Constants.sideHeadingStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AnnouncementsList()));
                  },
                ),
                Divider(color: Colors.transparent),
                ListTile(
                  title: Text(
                    Constants.SURVEY_TAG,
                    style: Constants.sideHeadingStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SurveyList()));
                  },
                ),
              ],
            ),
          ),

          Divider(
            color: Colors.white.withOpacity(0.8),
          ),
          ListTile(
            title: Text(
              Constants.HEALTHY_EATING_TAG,
              style: Constants.sideHeadingStyle,
            ),
            leading: Icon(
              MaterialCommunityIcons.hamburger,
              color: Colors.white,
            ),
            onTap: () {
              if (show == false) {
                show = true;
                setState(() {});
              } else {
                show = false;
                setState(() {});
              }
            },
          ),
          Visibility(
            visible: show,
            child: Column(
              children: [
                Divider(color: Colors.transparent),
                ListTile(
                  title: Text(
                    Constants.MENU_TAG,
                    style: Constants.sideHeadingStyle,
                  ),
                  //   leading: Icon(Icons.food_bank_outlined,color: Colors.white,),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MenuList()));
                  },
                ),
                if (MyApp.USER_TYPE_VALUE != 'Parent')
                  Divider(color: Colors.transparent),
                if (MyApp.USER_TYPE_VALUE != 'Parent')
                  ListTile(
                    title: Text(
                      Constants.RECIPES_TAG,
                      style: Constants.sideHeadingStyle,
                    ),
                    //   leading: Icon(Icons.food_bank_outlined,color: Colors.white,),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RecipeList()));
                    },
                  ),
              ],
            ),
          ),

          if (MyApp.USER_TYPE_VALUE != 'Parent')
            Divider(
              color: Colors.white.withOpacity(0.8),
            ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            ListTile(
              leading: Icon(
                MaterialCommunityIcons.flower,
                color: Colors.white,
              ),
              title: Text(
                Constants.RESOURCE_TAG,
                style: Constants.sideHeadingStyle,
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ResourceList()));
              },
            ),

          Divider(
            color: Colors.white.withOpacity(0.8),
          ),
          ListTile(
            leading: Icon(
              AntDesign.wallet,
              color: Colors.white,
            ),
            title: Text(
              Constants.DAILYJOURNAL_TAG,
              style: Constants.sideHeadingStyle,
            ),
            onTap: () {
              if (showDailyDairy == false) {
                showDailyDairy = true;
                setState(() {});
              } else {
                showDailyDairy = false;
                setState(() {});
              }
            },
          ),
          Visibility(
            visible: showDailyDairy,
            child: Column(
              children: [
                Divider(color: Colors.transparent),
                ListTile(
                  title: Text(
                    Constants.DAILYDAIRY_TAG,
                    style: Constants.sideHeadingStyle,
                  ),
                  //   leading: Icon(Icons.food_bank_outlined,color: Colors.white,),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DailyDairyMain()));
                  },
                ),
                if (MyApp.USER_TYPE_VALUE != 'Parent')
                  Divider(color: Colors.transparent),
                if (MyApp.USER_TYPE_VALUE != 'Parent')
                  ListTile(
                    title: Text(
                      Constants.HEADCHECKS_TAG,
                      style: Constants.sideHeadingStyle,
                    ),
                    //   leading: Icon(Icons.food_bank_outlined,color: Colors.white,),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HeadChecks()));
                    },
                  ),
                if (MyApp.USER_TYPE_VALUE != 'Parent')
                  Divider(color: Colors.transparent),
                if (MyApp.USER_TYPE_VALUE != 'Parent')
                  ListTile(
                    title: Text(
                      Constants.SLEEPCHECKLIST_TAG,
                      style: Constants.sideHeadingStyle,
                    ),
                    //   leading: Icon(Icons.food_bank_outlined,color: Colors.white,),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SleepCheckList()));
                    },
                  ),
                Divider(color: Colors.transparent),
                ListTile(
                  title: Text(
                    Constants.ACCIDENT_TAG,
                    style: Constants.sideHeadingStyle,
                  ),
                  //   leading: Icon(Icons.food_bank_outlined,color: Colors.white,),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AccidentsReports()));
                  },
                ),
              ],
            ),
          ),
          // if (MyApp.USER_TYPE_VALUE != 'Parent')
          Divider(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.8),
          ),
//  if (MyApp.USER_TYPE_VALUE != 'Parent')
          ListTile(
            leading: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            title: Text(
              Constants.REFLECTION_TAG,
              style: Constants.sideHeadingStyle,
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReflectionList()));
            },
          ),

          // Divider(
          //   color: Colors.white.withOpacity(0.8),
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.bar_chart_sharp,
          //     color: Colors.white,
          //   ),
          //   title: Text(
          //     Constants.PROGRESS_TAG,
          //     style: Constants.sideHeadingStyle,
          //   ),
          //   onTap: () {
          //     // Navigator.push(
          //     //     context,
          //     //     MaterialPageRoute(
          //     //         builder: (context) => ProgressNotesActivity()));
          //   },
          // ),

          Divider(
            color: Colors.white.withOpacity(0.8),
          ),
          ListTile(
            title: Text(
              Constants.MONTESSORI_TAG,
              style: Constants.sideHeadingStyle,
            ),
            leading: Icon(
              Octicons.graph,
              color: Colors.white,
            ),
            onTap: () {
              if (showMontessori == false) {
                showMontessori = true;
                setState(() {});
              } else {
                showMontessori = false;
                setState(() {});
              }
            },
          ),
          Visibility(
            visible: showMontessori,
            child: Column(
              children: [
                Divider(color: Colors.transparent),
                ListTile(
                  title: Text(
                    Constants.PROGRESSPLAN_TAG,
                    style: Constants.sideHeadingStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProgressPlan()));
                  },
                ),
                Divider(color: Colors.transparent),
                if (MyApp.USER_TYPE_VALUE != 'Parent')
                  ListTile(
                    title: Text(
                      Constants.LESSONPLAN_TAG,
                      style: Constants.sideHeadingStyle,
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LessonPlan()));
                    },
                  ),
              ],
            ),
          ),

          Divider(
            color: Colors.white.withOpacity(0.8),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            title: Text(
              Constants.SETTINGS_TAG,
              style: Constants.sideHeadingStyle,
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsList()));
            },
          ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            Divider(
              color: Colors.white.withOpacity(0.8),
            ),
          if (MyApp.USER_TYPE_VALUE != 'Parent')
            ListTile(
              title: Text(
                Constants.SERVICE_TAG,
                style: Constants.sideHeadingStyle,
              ),
              leading: Icon(
                Icons.security_rounded,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SaveService()));
              },
            ),

          Divider(
            color: Colors.white.withOpacity(0.8),
          ),
          ListTile(
            leading: Icon(
              Icons.settings_power,
              color: Colors.white,
            ),
            title: Text(
              Constants.LOGOUT,
              style: Constants.sideHeadingStyle,
            ),
            onTap: () {
              showLogoutDialog(context, onLogout: () {
                MyApp.logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    UserType.Tag, (Route<dynamic> route) => false);
              });
            },
          ),

          //  if(MyApp.permissionModel.isQrReaderYN == "Y")
        ],
      ),
    )
        //: Center(child: CircularProgressIndicator(),),
        );
  }
}


void showLogoutDialog(BuildContext context, {required VoidCallback onLogout}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(
            top: 24.0,
            bottom: 24.0,
            left: 24.0,
            right: 24.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Icon with circular background
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Constants.kButton.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 36.0,
                  color: Constants.kButton,
                ),
              ),
              SizedBox(height: 20.0),
              
              // Title
              Text(
                "Logout Confirmation",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12.0),
              
              // Message
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.0),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  
                  // Logout Button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onLogout();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Constants.kButton,
                    ),
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
