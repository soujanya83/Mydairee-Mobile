import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import 'package:mykronicle_mobile/others/floatingButton.dart';
import 'package:mykronicle_mobile/services/constants.dart';


Widget floating(BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FloatingButton()),
      );
    },
    elevation: 6,
    backgroundColor: Constants.kButton,
    foregroundColor: Colors.white,
    splashColor: Colors.white24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Icon(
      Icons.anchor_rounded,
      size: 28,
    ),
  );
}
