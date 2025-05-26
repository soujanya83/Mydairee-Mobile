// import 'package:device_info/device_info.dart';
import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:mykronicle_mobile/dashboard/dashboard.dart';
import 'package:mykronicle_mobile/login/adminlogin.dart';
import 'package:mykronicle_mobile/login/parentlogin.dart';
import 'package:mykronicle_mobile/login/stafflogin.dart';
import 'package:mykronicle_mobile/login/usertype.dart';
import 'package:mykronicle_mobile/observation/observationmain.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:mykronicle_mobile/utils/platform.dart' as platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter UI Error: ${details.exception}');
      debugPrint('Flutter UI Stacktrace: ${details.stack.toString()}');
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.white,
        // Uncomment and customize if needed:
        // child: Center(
        //   child: Text('Oops! Something went wrong.'),
        // ),
      );
    };

    runApp(RestartWidget(child: MyApp()));
  }, (error, stackTrace) {
    debugPrint('Async Error: $error');
    debugPrint('Stacktrace: $stackTrace');
  });
}

class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}

class MyApp extends StatelessWidget {
  static String EMAIL_VALUE = '';
  static String PASSWORD_HASH_VALUE = '';
  static String LOGIN_ID_VALUE = '';
  static String AUTH_TOKEN_VALUE = '';
  static String IMG_URL_VALUE = '';
  static String NAME_VALUE = '';
  static String USER_TYPE_VALUE = '';

  static ShowToast(String msg, BuildContext context) {
    ToastContext().init(context);
    Toast.show(msg, duration: Toast.lengthLong, gravity: Toast.bottom);
  }

  static Future<String> getDeviceIdentity() async {
    DeviceInfoPlugin _deviceInfoPlugin = new DeviceInfoPlugin();
    String _deviceIdentity;
    try {
      //    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await _deviceInfoPlugin.androidInfo;
      // _deviceIdentity = info.androidId;
      _deviceIdentity = info.id;
      //  }
      //  else if (Platform.isIOS) {
      //   IosDeviceInfo info = await _deviceInfoPlugin.iosInfo;
      //   _deviceIdentity = info.identifierForVendor;
      // }
    } on PlatformException {
      _deviceIdentity = "unknown";
    }

    return _deviceIdentity;
  }

  static void Show401Dialog(BuildContext mContext) {
    showDialog(
        context: mContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Logged Out",
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            content: new Text(
                "You have been logged out. Please login again to continue."),
            actions: <Widget>[
              new TextButton(
                child: Text("Okay"),
                onPressed: () {
                  MyApp.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      UserType.Tag, (Route<dynamic> route) => false);
                },
              ),
            ],
          );
        });
  }

  static logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    //   platform.PlatformState.firebaseMessaging.unsubscribeFromTopic(MyApp.LOGIN_ID_VALUE);
  }

  Future<String> isLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    LOGIN_ID_VALUE = preferences.getString(Constants.LOGIN_ID) ?? "";
    AUTH_TOKEN_VALUE = preferences.getString(Constants.AUTH_TOKEN) ?? "";
    IMG_URL_VALUE = preferences.getString(Constants.IMG_URL) ?? "";
    NAME_VALUE = preferences.getString(Constants.NAME) ?? "";
    USER_TYPE_VALUE = preferences.getString(Constants.USER_TYPE) ?? "";
    EMAIL_VALUE = preferences.getString(Constants.EMAIL) ?? "";
    PASSWORD_HASH_VALUE = preferences.getString(Constants.PASSWORD_HASH) ?? "";
    return LOGIN_ID_VALUE;
  }

  final routes = <String, WidgetBuilder>{
    Platform.Tag: (BuildContext context) => Platform(),
    ObservationMain.Tag: (BuildContext context) => ObservationMain(),
    StaffLogin.Tag: (BuildContext context) => StaffLogin(),
    AdminLogin.Tag: (BuildContext context) => AdminLogin(),
    ParentLogin.Tag: (BuildContext context) => ParentLogin(),
    UserType.Tag: (BuildContext context) => UserType(),
    Dashboard.Tag: (BuildContext context) => Dashboard(),
  };
  @override
  Widget build(BuildContext context) {
    return Portal(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Constants.kMain, hintColor: Color(0xfff2f4f5)),
        home: SplashScreen(
          isLoggedIn: isLoggedIn(),
        ),
        routes: routes,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Future<String> isLoggedIn;
  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 3 seconds then navigate
    // if(false)
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => FutureBuilder<String>(
                  future: widget.isLoggedIn,
                  builder:(BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError) {
                          return Text('Error : ${snapshot.error}');
                        } else if (snapshot.data == null ||
                            snapshot.data!.isEmpty) {
                          return UserType();
                        } else {
                          return platform.Platform();
                        }
                    }
                  },
                )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height.toString());
    print(MediaQuery.of(context).size.width.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Image.asset(
        errorBuilder: (context, error, stackTrace) {
          return SizedBox();
        },
        'assets/images/splash.png',
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.fill,
      ),
    );
  }
}

class DecideScreen extends StatelessWidget {
  const DecideScreen({super.key});
  Future<String> isLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    MyApp.LOGIN_ID_VALUE = preferences.getString(Constants.LOGIN_ID) ?? "";
    preferences.getString(Constants.AUTH_TOKEN) ?? "";
    MyApp.IMG_URL_VALUE = preferences.getString(Constants.IMG_URL) ?? "";
    MyApp.NAME_VALUE = preferences.getString(Constants.NAME) ?? "";
    MyApp.USER_TYPE_VALUE = preferences.getString(Constants.USER_TYPE) ?? "";
    MyApp.EMAIL_VALUE = preferences.getString(Constants.EMAIL) ?? "";
    MyApp.PASSWORD_HASH_VALUE =
        preferences.getString(Constants.PASSWORD_HASH) ?? "";
    return MyApp.LOGIN_ID_VALUE;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Text('Error : ${snapshot.error}');
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return UserType();
            } else {
              return platform.Platform();
            }
        }
      },
    );
  }
}
