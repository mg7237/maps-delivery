import 'package:flutter/material.dart';

/// Class providing alert dialog feature.
/// To be used consistently across application

enum ConfirmAction { CANCEL, OK }

class AlertDialogs {
  final String title;
  final String message;
  AlertDialogs({this.title, this.message});

  ///  asyncConfirmDialog used where user has option of OK / Cancel.
  ///  For example Do you wish to continue? Yes/No

  Future<String> asyncConfirmDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop('CANCEL');
              },
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop('OK');
              },
            )
          ],
        );
      },
    );
  }

  ///  asyncAckAlert used where user can acknowledge the message.
  ///  For example Save was successful

  Future<void> asyncAckAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(this.title),
          content: Text(this.message),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
