// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:gradient_app_bar/gradient_app_bar.dart';
// import 'package:mykronicle_mobile/services/constants.dart';

// class Header {
//   static Widget appBar([icon]) {
//     return GradientAppBar(
//       actions: <Widget>[icon ?? Container()],
//       gradient:
//           LinearGradient(colors: [Constants.kGradient1, Constants.kGradient2]),
//     );
//   }
// }


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/services/constants.dart';

class Header {
  static PreferredSizeWidget appBar([Widget? icon]) {
    return AppBar(
      actions: <Widget>[icon ?? Container()],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Constants.kGradient1, Constants.kGradient2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
