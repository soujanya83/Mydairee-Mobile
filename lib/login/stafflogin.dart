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
  TextEditingController nameController = TextEditingController();
  bool obscureText = true;
  bool isSignInDisabled = false;
  String loginEmail = '', loginPassword = '';
  bool loggingIn = false;
  String pin = '';
  String pinErr = '', empCodeErr = '';
  bool _isEmployeeCodeValid = true;
  bool _isPinValid = true;

  Future<void> loginNow() async {
    setState(() {
      loggingIn = true;
      errorText = ""; // Clear previous errors
    });
    
    String deviceid = await MyApp.getDeviceIdentity();
    loginEmail = nameController.text;
    loginPassword = pin;
    var bytes1 = utf8.encode(loginPassword);
    var digest1 = md5.convert(bytes1);
    
    if (loginEmail.trim().isNotEmpty && loginPassword.trim().isNotEmpty) {
      var loginBody = {
        "user_name": "${loginEmail.trim()}",
        "password": "${loginPassword.toString()}",
        "deviceid": "$deviceid",
        "devicetype": "MOBILE",
        "userType": 'Staff'
      };
      
      LoginAPIHandler login = LoginAPIHandler(loginBody);
      var result = await login.login();

      if (result != null && !result.containsKey('error')) {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString(Constants.LOGIN_ID, result['userid']);
        sharedPreferences.setString(Constants.AUTH_TOKEN, result['AuthToken']);
        sharedPreferences.setString(Constants.IMG_URL, result['imageUrl']);
        sharedPreferences.setString(Constants.NAME, result['name']);
        sharedPreferences.setString(Constants.EMAIL, loginEmail);
        sharedPreferences.setString(Constants.PASSWORD_HASH, digest1.toString());
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
        setState(() {
          isSignInDisabled = false;
          loggingIn = false;
          errorText = result?['error'] ?? "Login failed. Please try again.";
        });
      }
    } else {
      setState(() {
        loggingIn = false;
        isSignInDisabled = false;
        _validate = true;
      });
    }
  }

  void _validateForm() {
    setState(() {
      // Employee Code validation
      if (nameController.text.isEmpty) {
        empCodeErr = 'Please enter employee code';
        _isEmployeeCodeValid = false;
      } else {
        empCodeErr = '';
        _isEmployeeCodeValid = true;
      }

      // PIN validation
      if (pin.isEmpty || pin.length != 4) {
        pinErr = 'Please enter a 4-digit PIN';
        _isPinValid = false;
      } else {
        pinErr = '';
        _isPinValid = true;
      }

      // Only proceed if all validations pass
      if (_isEmployeeCodeValid && _isPinValid) {
        isSignInDisabled = true;
        loginNow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Constants.kButton),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 100 : 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        height: 100,
                        child: Image.asset(Constants.APP_LOGO),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Staff Login",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Constants.kLabel,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    
                    // Employee Code Field
                    Text(
                      "Employee Code",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(color: Constants.kGrey),
                      decoration: InputDecoration(
                        hintText: "Enter your employee code",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isEmployeeCodeValid
                                ? Constants.kButton
                                : Constants.errorColor,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isEmployeeCodeValid
                                ? Constants.kButton
                                : Constants.errorColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isEmployeeCodeValid
                                ? Constants.kButton
                                : Constants.errorColor,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Constants.errorColor,
                            width: 2.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Constants.errorColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null; // We handle validation in _validateForm
                        }
                        return null;
                      },
                    ),
                    if (empCodeErr.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          empCodeErr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Constants.errorColor,
                          ),
                        ),
                      ),
                    SizedBox(height: 24),
                    
                    // PIN Field
                    Text(
                      "PIN",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Pinput(
                        length: 4,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            pin = value;
                            if (value.length == 4) {
                              _isPinValid = true;
                              pinErr = '';
                            }
                          });
                        },
                        defaultPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isPinValid
                                  ? Constants.kButton
                                  : Constants.errorColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isPinValid
                                  ? Constants.kButton
                                  : Constants.errorColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(
                              color: _isPinValid
                                  ? Constants.kButton
                                  : Constants.errorColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        errorPinTheme: PinTheme(
                          width: 56,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Constants.errorColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (pinErr.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          pinErr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Constants.errorColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: 16),
                    
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPassword(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Error Message
                    if (errorText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          errorText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Constants.errorColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Login Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.kButton,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isSignInDisabled ? null : _validateForm,
                        child: loggingIn
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                "LOGIN",
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (loggingIn)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}