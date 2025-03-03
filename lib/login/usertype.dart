import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/login/adminlogin.dart';
import 'package:mykronicle_mobile/login/parentlogin.dart';
import 'package:mykronicle_mobile/login/stafflogin.dart';
import 'package:mykronicle_mobile/services/constants.dart';

class UserType extends StatefulWidget {
  
  static String Tag = Constants.USER_TYPE_TAG;

  @override
  _UserTypeState createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  @override
  Widget build(BuildContext context) {

    final label = new Center(child : new Text(
      "Select User type",
      style: new TextStyle(fontSize: 24.0,fontWeight: FontWeight.bold,color: Constants.kLabel),
    ));


     final paddingValue = MediaQuery.of(context).size.width > 600 ? 105.0 : 18.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: paddingValue, right: paddingValue),
      children: <Widget>[
        SizedBox(height: 32.0,),
        Center(
          child : SizedBox(
              height : 120.0,
              child: Image.asset(Constants.APP_LOGO))
        ),
        label,
        SizedBox(height: 32.0,),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: <Widget>[
            GestureDetector(
               onTap: (){
                 Navigator.of(context).pushReplacementNamed(AdminLogin.Tag);
               },
              child: Card(
                child: Container(
                  height: MediaQuery.of(context).size.height*0.26,
                  width: MediaQuery.of(context).size.width*0.26,
                   child: Column(
                     children:<Widget>[
                        Expanded(child: Container(
                           child: Image.asset(Constants.ADMIN_LOGO),
                        ),),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Admin',style: TextStyle(color: Colors.blue),),
                        )

                     ]
                   ),
                  ),
              ),
            ),
            GestureDetector(
              onTap: (){
                 Navigator.of(context).pushReplacementNamed(StaffLogin.Tag);
               },
                child: Card(
                child: Container(
                  height: MediaQuery.of(context).size.height*0.26,
                  width: MediaQuery.of(context).size.width*0.26,
                   child: Column(
                     children:<Widget>[
                        Expanded(child: Container(
                           child: Image.asset(Constants.STAFF_LOGO),
                        ),),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Staff',style: TextStyle(color: Colors.blue),),
                        )

                     ]
                   ),
                  ),
              ),
            ),
            GestureDetector(
               onTap: (){
                 Navigator.of(context).pushReplacementNamed(ParentLogin.Tag);
               },
              child: Card(
                child: Container(
                  height: MediaQuery.of(context).size.height*0.26,
                  width: MediaQuery.of(context).size.width*0.26,
                   child: Column(
                     children:<Widget>[
                        Expanded(child: Container(
                            child: Image.asset(Constants.PARENT_LOGO),
                        ),),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Parent',style: TextStyle(color: Colors.blue),),
                        )

                     ]
                   ),
                  ),
              ),
            ),
           ],
         )
        // email,
        // SizedBox(height: 8.0),
        // password,
        // SizedBox(height: 24.0),
        // Center(child: errorLabel),
        // loginButton,
      ],
     )
    );
  }
}