import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/loginapi.dart';
import 'package:mykronicle_mobile/login/forgotpassword.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show utf8;

class StaffLogin extends StatefulWidget {
  static String Tag = Constants.STAFF_TAG;
  @override
  _StaffLoginState createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String errorText = "";
  bool _validate = false;
  TextEditingController nameController = new TextEditingController();
  bool obscureText = true;
  bool isSignInDisabled = false;
  String loginEmail = '', loginPassword = '';
  bool loggingIn = false;
  String pin = '';
  String pinErr = '', empCodeErr = '';

  Future<void> loginNow() async {
    setState(() {
      loggingIn = true;
    });
    String deviceid = await MyApp.getDeviceIdentity();
    loginEmail = nameController.text;
    loginPassword = pin;
    var bytes1 = utf8.encode(loginPassword); // data being hashed
    var digest1 = md5.convert(bytes1);
    if (loginEmail.trim().isNotEmpty && loginPassword.trim().isNotEmpty) {
      var loginBody = {
        "user_name": "${loginEmail.trim()}",
        "password": "${loginPassword.toString()}",
        "deviceid": "$deviceid",
        "devicetype": "MOBILE",
        "userType": 'Staff'
      };
      print(loginBody);
      LoginAPIHandler login = LoginAPIHandler(loginBody);
      var result = await login.login();

      if (result != null && !result.containsKey('error')) {
        print(result);
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString(Constants.LOGIN_ID, result['userid']);
        sharedPreferences.setString(Constants.AUTH_TOKEN, result['AuthToken']);
        sharedPreferences.setString(Constants.IMG_URL, result['imageUrl']);
        sharedPreferences.setString(Constants.NAME, result['name']);
        sharedPreferences.setString(Constants.EMAIL, loginEmail);
        sharedPreferences.setString(
            Constants.PASSWORD_HASH, digest1.toString());
        sharedPreferences.setString(Constants.USER_TYPE, result['role']);
        MyApp.LOGIN_ID_VALUE = result['userid'];
        MyApp.AUTH_TOKEN_VALUE = result['AuthToken'];
        MyApp.IMG_URL_VALUE = result['imageUrl'];
        MyApp.NAME_VALUE = result['name'];
        MyApp.USER_TYPE_VALUE = result['role'];
        MyApp.EMAIL_VALUE = loginEmail;
        MyApp.PASSWORD_HASH_VALUE = digest1.toString();
        Navigator.of(context).pushReplacementNamed(Platform.Tag);
      } else {
        isSignInDisabled = false;
        loggingIn = false;
        if (result != null) errorText = result['error'];
        setState(() {});
        print('issue');
      }
      print(loginEmail.toString());
      print(loginPassword.toString());
    } else {
      // validation error
      setState(() {
        loggingIn = false;
        isSignInDisabled = false;
        _validate = true;
      });
    }
  }

  Widget loginBuild() {
    final employeeCode = Theme(
      data: new ThemeData(
        primaryColor: Colors.green,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        autofocus: false,
        controller: nameController,
        style: TextStyle(color: Constants.kGrey),
        decoration: InputDecoration(
          labelText: "Employee Code",
          hintStyle: new TextStyle(color: Constants.kGrey.withOpacity(0.8)),
          contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 3.0),
          labelStyle: new TextStyle(color: Constants.kGrey),
          suffixIcon: IconButton(
              icon: Icon(
                Icons.minimize,
                color: Colors.transparent,
              ),
              onPressed: null),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constants.kButton,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Constants.kButton,
              width: 1.5,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
          ),
        ),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
      child: ButtonTheme(
        height: 42.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.kButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
          onPressed: isSignInDisabled
              ? null
              : () {
                  if (pin == null || pin.isEmpty) {
                    pinErr = 'Enter Pin';
                    setState(() {});
                  } else {
                    pinErr = '';
                    setState(() {});
                  }

                  if (nameController.text.isEmpty) {
                    empCodeErr = 'Enter Employee Code';
                    setState(() {});
                  } else {
                    empCodeErr = '';
                    setState(() {});
                  }

                  if (nameController.text.isNotEmpty &&
                      pin != null &&
                      pin.isNotEmpty) {
                    setState(() {
                      isSignInDisabled = true;
                    });
                    loginNow();
                  }
                },
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    final errorLabel = Text(
      errorText,
      style: new TextStyle(color: Colors.red, fontSize: 14.0),
    );

    final label = new Center(
        child: new Text(
      "Staff Login",
      style: new TextStyle(
          fontSize: 24.0, fontWeight: FontWeight.bold, color: Constants.kLabel),
    ));

    final paddingValue = MediaQuery.of(context).size.width > 600 ? 105.0 : 18.0;

    return new ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: paddingValue, right: paddingValue),
      children: <Widget>[
        Center(
            child: SizedBox(
                height: 120.0, child: Image.asset(Constants.APP_LOGO))),
        label,
        SizedBox(height: 32.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: employeeCode,
        ),
        empCodeErr != ''
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  empCodeErr,
                  style: TextStyle(color: Colors.red),
                ),
              )
            : SizedBox(),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 0, 20),
          child: Text(
            'PIN',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Pinput(
          length: 4,
          defaultPinTheme: PinTheme(
            
            width: 50,
            height: 50,
            textStyle: const TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Constants.kButton),
              borderRadius: BorderRadius.circular(12), // Rounded borders
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 50,
            height: 50,
            textStyle: const TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Constants.kButton, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          submittedPinTheme: PinTheme(
            width: 50,
            height: 50,
            textStyle: const TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Constants.kButton),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onCompleted: (pin) {
            print("Completed: $pin");
            setState(() {
              this.pin = pin;
            });
          },
        ),
        pinErr != null && pinErr.isNotEmpty && pinErr.length > 0
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  pinErr,
                  style: TextStyle(color: Colors.red),
                ),
              )
            : SizedBox(),
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: InkWell(
                  onTap:(){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPassword()));
                  },
                  child: Text(
                    'Forgot Password ?',
                    style: TextStyle(color: Colors.blue),
                  )),
            ),
          ],
        ),
        SizedBox(height: 24.0),
        Center(child: errorLabel),
        loginButton,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: new Form(key: _formKey, child: loginBuild()),
            ),
            loggingIn
                ? Center(child: new CircularProgressIndicator())
                : new Container(),
          ],
        ));
  }
}
