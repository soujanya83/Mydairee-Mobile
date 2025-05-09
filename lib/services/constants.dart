import 'dart:ui';

import 'package:flutter/material.dart';

class Constants {
  static final String BASE_URL = 'https://mydiaree.com/api/';

  static final String EMAIL = "Email";
  static final String PASSWORD_HASH = "PasswordHash";
  static final String LOGIN_ID = "LoginId";
  static final String AUTH_TOKEN = "AuthToken";
  static final String IMG_URL = "ImgUrl";
  static final String NAME = "Name";
  static final String USER_TYPE = "UserType";
  static final String UID = "UID";
  
  static final String LOGOUT = "LOGOUT";

  static final String ImageBaseUrl = Constants.BASE_URL + "assets/media/";

  // Images
  static final String APP_LOGO = "assets/images/logo.png";

  static final String ROOM_IMG = "assets/images/room.png";
  static final String ANALYTICS_IMG = "assets/images/analytics.png";
  static final String STUDENTS_IMG = "assets/images/students.png";
  static final String ACTIVITIES_IMG = "assets/images/activities.png";

  static final String ADMIN_LOGO = "assets/images/admin.png";
  static final String PARENT_LOGO = "assets/images/parent.png";
  static final String STAFF_LOGO = "assets/images/staff.png";
  static final String NO_LINKS = "assets/images/no_links.png";
  static final String FILE = "assets/images/file.png";
  static final String UPLOAD_IMG = "assets/images/upload.png";
  static final String KID_ICON = "assets/images/kid_icon.png";
  static final String LEAD_ICON = "assets/images/lead_icon.png";

  static final String ACCIDENT_IMG = "assets/images/accident.jpeg";

  //settings tags
  static final String RESET_PASSWORD_TAG = "Reset Password";
  static final String RESET_PIN_TAG = "Reset Pin";
  static final String CHANGE_MAILID_TAG = "Change Mail Id";
  static final String MODULE_SETTINGS_TAG = "Module Settings";
  static final String USER_SETTINGS_TAG = "User Settings";
  static final String CENTER_SETTINGS_TAG = "Center Settings";
  static final String PARENT_SETTINGS_TAG = "Parent Settings";
  static final String CHILD_GROUPS_TAG = "Child Groups";
  static final String ASSESMENT_SETTINGS_TAG = "Assesment";
  static final String HISTORY_TAG = "History";
  static final String MANAGE_PERMISSIONS_TAG = "Manage Permissions";
  static final String MODULES_TAG = "Modules & sub modules";
  static final String ASSESMENTS_TAG = "Assesment Settings";
  static final String SUMMATIVE_ASSESMENTSETTINGS_TAG =
      "Summative Assesment Settings";
  static final String DAILYJOURNAL_SETTINGSTAG = "Daily Journal Settings";
  static final String NOTICEPERIOD_SETTIGSTAG = "Notice Period Settings";

  // Tags
  static final String PLATFORM_TAG = "Platform";
  static final String PROGRAMPLANS_TAG = "PROGRAM PLANS";

  static final String USER_TYPE_TAG = "UserType";
  static final String LOGIN_TAG = "Login";
  static final String ADMIN_TAG = "Admin";
  static final String PARENT_TAG = "Parent";
  static final String STAFF_TAG = "Staff";
  static final String OBSERVATION_MAIN_TAG = "OBSERVATIONS";
  static final String MEDIA_TAG = "MEDIA";
  static final String QIP_TAG = "QIP";

  static final String QIP_FULL_TAG = "QUALITY IMPROVEMENT PLAN";
  static final String SELF_ASSESMENT_TAG = "SELF ASSESMENT";

  static final String ANNOUNCEMENTS_TAG = "ANNOUNCEMENTS";
  static final String RECIPES_TAG = "RECIPES";
  static final String MENU_TAG = "MENU";
  static final String HEALTHY_EATING_TAG = "HEALTHY EATING";
  static final String MONTESSORI_TAG = "PROGRESS AND LESSON PLAN";
  static final String PROGRESSPLAN_TAG = "RECORD MONTESSORI PROGRESS";
  static final String LESSONPLAN_TAG = "PLAN MONTESSORI LESSON";
  static final String LESSPLAN_TAG = "LESSON PLAN";

  static final String SURVEY_TAG = "SURVEY";
  static final String RESOURCE_TAG = "RESOURCES";
  static final String SETTINGS_TAG = "SETTINGS";
  static final String ROOMS_TAG = "ROOMS";
  static final String DASHBOARD_TAG = "DASHBOARD";
  static final String SERVICE_TAG = "SERVICES";
  static final String DAILYDAIRY_TAG = "DAILY DAIRY";
  static final String DAILYJOURNAL_TAG = "DAILY JOURNAL";

  static final String REFLECTION_TAG = "DAILY REFLECTION";

  static final String HEADCHECKS_TAG = "HEADCHECKS";
  static final String ACCIDENT_TAG = "ACCIDENT";
  static final String SLEEPCHECKLIST_TAG = "SLEEP CHECK LIST";

  static final String PROGRESS_TAG = "PROGRESS NOTES"; 

  //text styles
  static final sideHeadingStyle =
      new TextStyle(fontSize: 16.0, color: Colors.white);
  static final cardHeadingStyle =
      new TextStyle(color: Constants.kMain, fontWeight: FontWeight.bold);
  static final settingsHeadingStyle =
      new TextStyle(fontSize: 16.0, color: Colors.black);
  static final mainHeadingStyle = new TextStyle(
      fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold);
  static final hintStyle = new TextStyle(fontSize: 14.0, color: Colors.grey);
  static final containerHeadingStyle =
      new TextStyle(color: Constants.kLabel, fontWeight: FontWeight.bold);
  static final containerNumberHeadingStyle =
      new TextStyle(color: Constants.kLabel, fontSize: 20);

  static final header1 = new TextStyle(
      fontSize: 18.0, color: kHeader1, fontWeight: FontWeight.bold);
  static final header2 = new TextStyle(
      fontSize: 15.0, color: kHeader1, fontWeight: FontWeight.bold);
  static final header3 =
      new TextStyle(fontSize: 16.0, color: kMain, fontWeight: FontWeight.bold);
  static final header4 = new TextStyle(
      fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w600);
  static final header5 =
      new TextStyle(fontSize: 14.0, color: kMain, fontWeight: FontWeight.w600);
  static final header6 = new TextStyle(
      fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w600);
  static final header7 = new TextStyle(
      fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.w600);

  static final head1 =
      TextStyle(color: Constants.kHeader1, fontWeight: FontWeight.bold);

  //colors

  static const Color kGrey = const Color(0xff8e959b);
  static final Color kBlack = const Color(0xff0D1D2D);
  static final Color kGreen = const Color(0xffdcf7c6);
  static final Color kBlue = const Color(0xffc7cdff);

  static const Color kContainer = const Color(0xffC1E9FF);
  static const Color kMain = const Color(0xff297DB6);
  static const Color kHeader1 = const Color(0xff042C5C);
  static final Color kButton = const Color(0xff297DB6);
  static final Color kGradient1 = const Color(0xff001529);
  static final Color kGradient2 = const Color(0xff297DB6);
  static final Color kLabel = const Color(0xff1B2E4B);
  //985C5C
  static final Color kCount = const Color(0xff985C5C);

  static final Color greyColor = Colors.grey[300]!;
  static final Color kprogresscard = const Color(0xffC8DBE5);
}
