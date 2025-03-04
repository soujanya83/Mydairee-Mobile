import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import 'package:mykronicle_mobile/others/floatingButton.dart';


Widget floating(BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FloatingButton()));
    },
    child: Icon(Icons.anchor), // Replaced Feather.anchor with Icons.anchor
  );
}