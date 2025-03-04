import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/loginapi.dart';
import 'package:mykronicle_mobile/services/constants.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loggingIn = false;
  bool isSignInDisabled = false;
  String? loginEmail, loginPassword;
  String errorText = "";
  TextEditingController nameController = new TextEditingController();
  bool back = false;

  String? _validateName(String? val) {
    if (val?.trim().length == 0)
      return "Enter Name";
    else
      return null;
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

    final backButton = Padding(
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "Back",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
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
  onPressed: () async {
    loginEmail = nameController.text;
    var loginBody = {
      "email": "${loginEmail?.trim()}",
    };

    LoginAPIHandler login = LoginAPIHandler(loginBody);
    var result = await login.forgotpwd();

    if (!result.containsKey('error')) {
      errorText = 'Reset link has been sent to your mail';
      back = true;
      setState(() {});
      //Navigator.pop(context);
    } else {
      isSignInDisabled = false;
      errorText = result['error'];
      setState(() {});
      print('issue');
    }
  },
  child: Text(
    "Update",
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
      "Forgot Password",
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
        SizedBox(height: 24.0),
        Center(child: errorLabel),
        back ? backButton : loginButton,
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
