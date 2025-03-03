import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/assesment/assesments_list.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/centersettings.dart';
import 'package:mykronicle_mobile/settings/changemail.dart';
import 'package:mykronicle_mobile/settings/childgroups.dart';
import 'package:mykronicle_mobile/settings/dailyjournalsettings.dart';
import 'package:mykronicle_mobile/settings/modulesettings.dart';
import 'package:mykronicle_mobile/settings/noticeperiosettings.dart';
import 'package:mykronicle_mobile/settings/parentsettings.dart';
import 'package:mykronicle_mobile/settings/permissions.dart';
import 'package:mykronicle_mobile/settings/resetpassword.dart';
import 'package:mykronicle_mobile/settings/resetpin.dart';
import 'package:mykronicle_mobile/settings/usersettings.dart';
import 'package:mykronicle_mobile/utils/floatingButton.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class SettingsList extends StatefulWidget {
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Text(
                        ' Settings',
                        style: Constants.header1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        child: Container(
                          child: Column(
                            children: [
                              if (MyApp.USER_TYPE_VALUE != 'Staff')
                                ListTile(
                                  title: Text(
                                    Constants.RESET_PASSWORD_TAG,
                                    style: Constants.settingsHeadingStyle,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ResetPassword()));
                                  },
                                ),
                              if (MyApp.USER_TYPE_VALUE != 'Staff') Divider(),
                              if (MyApp.USER_TYPE_VALUE == 'Staff')
                                ListTile(
                                  title: Text(
                                    Constants.RESET_PIN_TAG,
                                    style: Constants.settingsHeadingStyle,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => ResetPin()));
                                  },
                                ),
                              if (MyApp.USER_TYPE_VALUE == 'Staff') Divider(),
                              ListTile(
                                title: Text(
                                  Constants.CHANGE_MAILID_TAG,
                                  style: Constants.settingsHeadingStyle,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ChangeMail()));
                                },
                              ),
                              Divider(),
                              if (MyApp.USER_TYPE_VALUE != 'Parent')
                                ListTile(
                                  title: Text(
                                    Constants.MODULE_SETTINGS_TAG,
                                    style: Constants.settingsHeadingStyle,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ModuleSettings()));
                                  },
                                ),
                              if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              if (MyApp.USER_TYPE_VALUE != 'Parent')
                                ListTile(
                                  title: Text(
                                    Constants.USER_SETTINGS_TAG,
                                    style: Constants.settingsHeadingStyle,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserSettings()));
                                  },
                                ),
                              if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              if (MyApp.USER_TYPE_VALUE != 'Parent')
                                ListTile(
                                  title: Text(
                                    Constants.CENTER_SETTINGS_TAG,
                                    style: Constants.settingsHeadingStyle,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CenterSettings()));
                                  },
                                ),
                              if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              if (MyApp.USER_TYPE_VALUE != 'Parent')
                                ListTile(
                                  title: Text(
                                    Constants.PARENT_SETTINGS_TAG,
                                    style: Constants.settingsHeadingStyle,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ParentSettings()));
                                  },
                                ),
                              if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              if (MyApp.USER_TYPE_VALUE != 'Parent')
                                ListTile(
                                  title: Text(
                                    Constants.CHILD_GROUPS_TAG,
                                    style: Constants.settingsHeadingStyle,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChildGroups()));
                                  },
                                ),
                              if (MyApp.USER_TYPE_VALUE != 'Parent')
                              Divider(),
                              if (MyApp.USER_TYPE_VALUE != 'Parent')
                              ListTile(
                                title: Text(
                                  Constants.ASSESMENTS_TAG,
                                  style: Constants.settingsHeadingStyle,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AssesmentsList()));
                                },
                              ),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent')
                              //   ListTile(
                              //     title: Text(
                              //       Constants.HISTORY_TAG,
                              //       style: Constants.settingsHeadingStyle,
                              //     ),
                              //     onTap: () {
                              //       // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResetPassword()));
                              //     },
                              //   ),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent')
                              //   ListTile(
                              //     title: Text(
                              //       Constants.MANAGE_PERMISSIONS_TAG,
                              //       style: Constants.settingsHeadingStyle,
                              //     ),
                              //     onTap: () {
                              //       Navigator.of(context).push(
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   Permissions()));
                              //     },
                              //   ),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent')
                              //   ListTile(
                              //     title: Text(
                              //       Constants.MODULES_TAG,
                              //       style: Constants.settingsHeadingStyle,
                              //     ),
                              //     onTap: () {
                              //       Navigator.of(context).push(
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   ResetPassword()));
                              //     },
                              //   ),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent')
                              //   ListTile(
                              //     title: Text(
                              //       Constants.ASSESMENT_SETTINGS_TAG,
                              //       style: Constants.settingsHeadingStyle,
                              //     ),
                              //     onTap: () {
                              //       // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResetPassword()));
                              //     },
                              //   ),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent')
                              //   ListTile(
                              //     title: Text(
                              //       Constants.SUMMATIVE_ASSESMENTSETTINGS_TAG,
                              //       style: Constants.settingsHeadingStyle,
                              //     ),
                              //     onTap: () {
                              //       Navigator.of(context).push(
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   ResetPassword()));
                              //     },
                              //   ),
                              // if (MyApp.USER_TYPE_VALUE != 'Parent') Divider(),
                              // if (MyApp.USER_TYPE_VALUE == 'Superadmin')
                              //   ListTile(
                              //     title: Text(
                              //       Constants.DAILYJOURNAL_SETTINGSTAG,
                              //       style: Constants.settingsHeadingStyle,
                              //     ),
                              //     onTap: () {
                              //       Navigator.of(context).push(
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   DailyJournalSettings()));
                              //     },
                              //   ),
                              // if (MyApp.USER_TYPE_VALUE == 'Superadmin')
                              //   Divider(),
                              // if (MyApp.USER_TYPE_VALUE == 'Superadmin')
                              //   ListTile(
                              //     title: Text(
                              //       Constants.NOTICEPERIOD_SETTIGSTAG,
                              //       style: Constants.settingsHeadingStyle,
                              //     ),
                              //     onTap: () {
                              //       Navigator.of(context).push(
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   NoticePeriodSettings()));
                              //     },
                              //   ),
                              // if (MyApp.USER_TYPE_VALUE == 'Superadmin')
                              //   Divider(),
                            ],
                          ),
                        ),
                      )
                    ])))));
  }
}
