import 'package:climify/models/api_response.dart';
import 'package:climify/main.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<APIResponse<RoomModel>> sendReceiveLocation() async {
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();

  if (await sharedPrefsHelper.getOnLoginScreen()) {
    return null;
  }

  String notificationTitle = "Scanning room";
  Future.delayed(Duration(milliseconds: 200)).then(
    (_) => LocalNotifications.flutterLocalNotificationsPlugin.cancel(0),
  );

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'Periodic Scan Notification',
    'Periodic Scan Notification',
    'Notification showing the last room estimation result. The notification can be tapped to update your current position. This allows the system to perform personalized updates on the indoor climate',
    enableVibration: false,
    playSound: false,
    color: const Color.fromARGB(255, 25, 155, 255),
    channelAction: AndroidNotificationChannelAction.CreateIfNotExists,
    category: 'alarm',
    channelShowBadge: false,
    timeoutAfter: 10*60*1000, // 10 minutes
    importance: Importance.Default,
    priority: Priority.Max,
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  Future.delayed(Duration(milliseconds: 450)).then(
    (_) => LocalNotifications.flutterLocalNotificationsPlugin.show(
      0,
      notificationTitle,
      "",
      platformChannelSpecifics,
    ),
  );

  BluetoothServices _bluetoothServices = BluetoothServices();

  APIResponse<RoomModel> apiResponse =
      await _bluetoothServices.getRoomFromScan();
  LocalNotifications.flutterLocalNotificationsPlugin.cancel(0);
  RoomModel _room = apiResponse?.data;

  notificationTitle = _room?.name != null
      ? "Current room: ${_room.name}"
      : "Couldn't scan room";
  await Future.delayed(Duration(milliseconds: 250)).then(
    (_) => LocalNotifications.flutterLocalNotificationsPlugin.show(
      0,
      notificationTitle,
      "Tap to rescan room",
      platformChannelSpecifics,
      payload: "scan",
    ),
  );

  return apiResponse;
}
