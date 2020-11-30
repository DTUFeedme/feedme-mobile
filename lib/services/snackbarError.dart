import 'package:flutter/material.dart';

class SnackBarError {
  static void showErrorSnackBar(
    String error,
    GlobalKey<ScaffoldState> scaffoldKey, {
    Duration duration = const Duration(seconds: 4),
  }) {
    SnackBar snackBar = SnackBar(
      content: Text(error),
      duration: duration,
    );
    if (!(scaffoldKey?.currentState?.mounted ?? false)) return;
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  static void hideSnackBar(GlobalKey<ScaffoldState> scaffoldKey) {
    if (!(scaffoldKey?.currentState?.mounted ?? false)) return;
    scaffoldKey.currentState.hideCurrentSnackBar();
  }
}
