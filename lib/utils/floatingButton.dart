import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mykronicle_mobile/others/floatingButton.dart';

Widget floating(var context) {
  return FloatingActionButton(
    onPressed: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FloatingButton()));
    },
    child: Icon(Feather.anchor),
  );
}
