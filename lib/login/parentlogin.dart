import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/loginapi.dart';
import 'package:mykronicle_mobile/login/forgotpassword.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:crypto/crypto.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show utf8;

class ParentLogin extends StatefulWidget {
  static String Tag = Constants.PARENT_TAG;
  @override
  _ParentLoginState createState() => _ParentLoginState();
}

class _ParentLoginState extends State<ParentLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String errorText = "";
  bool _validate = false;
  TextEditingController nameController = new TextEditingController(),
      passwordController = new TextEditingController();
  bool obscureText = true;
  bool loggingIn = false;
  bool isSignInDisabled = false;
  String loginEmail = '', loginPassword = '';

  String? _validateName(String? val) {
    if (val?.trim().length == 0)
      return "Enter Name";
    else
      return null;
  }

  String? _validatePassword(String? val) {
    if (val?.length == 0) {
      return "Enter password";
    } else {
      //    forgotNewPassword = val;
      return null;
    }
  }

  Future<void> loginNow() async {
    if (_formKey.currentState?.validate() ?? false) {
      // No error in validation
      _formKey.currentState?.save();
      setState(() {
        loggingIn = true;
      });
      String deviceid = await MyApp.getDeviceIdentity();
      loginEmail = nameController.text;
      loginPassword = passwordController.text;
      var bytes1 = utf8.encode(loginPassword); // data being hashed
      var digest1 = md5.convert(bytes1);
      if (loginEmail.trim().isNotEmpty && loginPassword.trim().isNotEmpty) {
        var loginBody = {
          "user_name": "${loginEmail.trim()}",
          "password": "${loginPassword.toString()}",
          "deviceid": "$deviceid",
          "devicetype": "MOBILE",
          "userType": 'Parent'
        };

        LoginAPIHandler login = LoginAPIHandler(loginBody);
        var result = await login.login();

        if (result!=null && !result.containsKey('error')) {
          print(result);
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(Constants.LOGIN_ID, result['userid']);
          sharedPreferences.setString(
              Constants.AUTH_TOKEN, result['AuthToken']);
          sharedPreferences.setString(Constants.IMG_URL, result['imageUrl']);
          sharedPreferences.setString(Constants.NAME, result['name']);
          sharedPreferences.setString(Constants.EMAIL, loginEmail);
          sharedPreferences.setString(Constants.PASSWORD_HASH, digest1.toString());
          String role = "Parent";
          sharedPreferences.setString(Constants.USER_TYPE, role);
          MyApp.LOGIN_ID_VALUE = result['userid'];
          MyApp.AUTH_TOKEN_VALUE = result['AuthToken'];
          MyApp.IMG_URL_VALUE = result['imageUrl'];
          MyApp.NAME_VALUE = result['name'];
          MyApp.USER_TYPE_VALUE = role;
          MyApp.EMAIL_VALUE = loginEmail;
          MyApp.PASSWORD_HASH_VALUE = digest1.toString();
          Navigator.of(context).pushReplacementNamed(Platform.Tag);
        } else {
          isSignInDisabled = false;
          loggingIn = false;
          if(result!=null)
          errorText = result['error'];
          setState(() {});
          print('issue');
        }
      } else {
        setState(() {
          loggingIn = false;
          isSignInDisabled = false;
          errorText = "Both fields are required";
        });
      }
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
    final name = Theme(
      data: new ThemeData(
        primaryColor: Colors.green,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        autofocus: false,
        controller: nameController,
        style: TextStyle(color: Constants.kGrey),
        decoration: InputDecoration(
            labelText: "Username",
            hintStyle: new TextStyle(color: Constants.kGrey.withOpacity(0.8)),
            contentPadding: EdgeInsets.fromLTRB(5.0, 10.0, 20.0, 10.0),
            labelStyle: new TextStyle(color: Constants.kGrey),
            suffixIcon: IconButton(
                icon: Icon(
                  Icons.minimize,
                  color: Colors.transparent,
                ),
                onPressed: null)),
        validator: _validateName,
        onSaved: (String? val) {
          //  loginEmail = val.trim();
        },
      ),
    );

    final password = Theme(
      data: new ThemeData(
        primaryColor: Colors.green,
      ),
      child: TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: obscureText,
        style: TextStyle(color: Constants.kGrey),
        decoration: InputDecoration(
          labelText: "Password",
          hintStyle: new TextStyle(color: Constants.kGrey.withOpacity(0.8)),
          contentPadding: EdgeInsets.fromLTRB(5.0, 10.0, 20.0, 10.0),
          labelStyle: new TextStyle(color: Constants.kGrey),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Constants.kMain,
            ),
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
        ),
        validator: _validatePassword,
        onSaved: (String? val) {
          //    loginPassword = val;
        },
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
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
                  setState(() {
                    isSignInDisabled = true;
                  });
                  loginNow();
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
      style: new TextStyle(color: Colors.red, fontSize: 12.0),
    );

    final label = new Center(
        child: new Text(
      "Parent Login",
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
        name,
        SizedBox(height: 8.0),
        password,
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPassword()));
                },
                child: Text(
                  'Forgot Password ?',
                  style: TextStyle(color: Colors.blue),
                )),
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
