import 'package:flutter/material.dart';

class SnackBarError {
  static void showErrorSnackBar(
      String error, GlobalKey<ScaffoldState> scaffoldKey) {
    SnackBar snackBar = SnackBar(
      content: Text(error),
    );
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
