import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

void showAwesomeDialog(BuildContext context, String title, String message) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.scale,
    title: title,
    desc: message,
    btnOkIcon: Icons.info_outline,
    btnOkColor: Colors.blueGrey,
    btnCancelText: "Close",
    btnCancelColor: Colors.red,
    btnCancelOnPress: () {},
  ).show();
}
