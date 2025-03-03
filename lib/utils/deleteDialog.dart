import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/services/callbacks.dart';

showDeleteDialog(BuildContext context, DeleteCallback delteCallback) {
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  Widget okButton = TextButton(
    child: Text(
      "Ok",
      style: TextStyle(color: Colors.red),
    ),
    onPressed: delteCallback,
  );

  AlertDialog alert = AlertDialog(
    title: Text(
      "Delete",
      style: TextStyle(color: Colors.red),
    ),
    content: Text("Are you sure do you want to delete"),
    actions: [cancelButton, okButton],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
