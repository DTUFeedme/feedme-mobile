import 'dart:collection';

import 'package:climify/models/api_response.dart';
import 'package:climify/main.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UpdateLocation extends ChangeNotifier {
  bool _scanningLocation = false;
  bool _error = false;
  RoomModel _room = RoomModel('', '');
  String _message = '';
  final List<FeedbackQuestion> _questions = [];
  DateTime _dateTime = DateTime.now();

  RestService _restService = RestService();

  bool get scanning => _scanningLocation;
  bool get error => _error;
  RoomModel get room => _room;
  String get message => _message;
  UnmodifiableListView get questions => UnmodifiableListView(_questions);

  Future<void> sendReceiveLocation({bool fromAuto = false}) async {
    // If the background trigger attempts to scan within two minutes of a manual one, dont run it
    // This prevents interrupting a user who could actively be looking at the question list
    if (fromAuto &&
        DateTime.now().isBefore(_dateTime.add(Duration(minutes: 2)))) {
      return;
    }

    _dateTime = DateTime.now();

    String notificationTitle = "Scanning room";

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Periodic Scan Notification',
      'Periodic Scan Notification',
      'Notification showing the last room estimation result. The notification can be tapped to update your current position. This allows the system to perform personalized updates on the indoor climate',
      enableVibration: false,
      playSound: false,
      autoCancel: false,
      color: const Color.fromARGB(255, 25, 155, 255),
      channelAction: AndroidNotificationChannelAction.CreateIfNotExists,
      category: 'alarm',
      channelShowBadge: false,
      timeoutAfter: 10 * 60 * 1000, // 10 minutes
      importance: Importance.Default,
      priority: Priority.Max,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    LocalNotifications.flutterLocalNotificationsPlugin.show(
      0,
      notificationTitle,
      "",
      platformChannelSpecifics,
    );

    BluetoothServices _bluetoothServices = BluetoothServices();

    _questions.clear();
    _scanningLocation = true;
    _message = "Scanning room...";
    notifyListeners();

    APIResponse<RoomModel> apiResponse =
        await _bluetoothServices.getRoomFromScan();

    notificationTitle = _room?.name != null
        ? "Current room: ${_room.name}"
        : "Couldn't scan room";

    LocalNotifications.preventSelectNotification = false;
    if (apiResponse.error) {
      _error = true;
      _message = "Error scanning room, tap to retry";
      notificationTitle = "Couldn't scan room";
    } else {
      _error = false;
      _room = apiResponse.data;
      _message = "Current room: ${_room.name}";
      notificationTitle = _message;
    }
    _scanningLocation = false;
    notifyListeners();

    LocalNotifications.flutterLocalNotificationsPlugin.show(
      0,
      notificationTitle,
      "Tap to rescan room",
      platformChannelSpecifics,
      payload: "scan",
    );
    updateQuestions();
  }

  Future<void> updateQuestions() async {
    if (_room == null) {
      return;
    }
    APIResponse<List<FeedbackQuestion>> apiResponseQuestions =
        await _restService.getActiveQuestionsByRoom(_room.id, "week");
    if (!apiResponseQuestions.error) {
      _questions.clear();
      _questions.addAll(apiResponseQuestions.data);
      notifyListeners();
    } else {
      _questions.clear();
      _error = true;
      _message = apiResponseQuestions.errorMessage;
      notifyListeners();
    }
  }
}
