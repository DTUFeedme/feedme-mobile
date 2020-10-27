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
  RoomModel _room;
  String _message = '';
  String _subMessage = '';
  String _errorMessageRoom = '';
  String _errorMessageQuestion = '';
  final List<FeedbackQuestion> _questions = [];
  // DateTime _dateTime = DateTime.now();

  RestService _restService = RestService();

  bool get scanning => _scanningLocation;
  bool get error => _error;
  RoomModel get room => _room;
  String get message => _message;
  String get subMessage => _subMessage;
  String get errorMessageRoom => _errorMessageRoom;
  String get errorMessageQuestion => _errorMessageQuestion;
  UnmodifiableListView get questions => UnmodifiableListView(_questions);

  Future<void> sendReceiveLocation({bool fromAuto = false}) async {
    // If the background trigger attempts to scan within two minutes of a manual one, dont run it
    // This prevents interrupting a user who could actively be looking at the question list

    //This has been disabled to enable rescanning
    // if (fromAuto &&
    //     DateTime.now().isBefore(_dateTime.add(Duration(minutes: 2)))) {
    //   return;
    // }

    // _dateTime = DateTime.now();

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

    _error = false;
    _room = null;
    _errorMessageRoom = '';
    _errorMessageQuestion = '';
    // _questions.clear();
    _scanningLocation = true;
    _message = "Scanning room...";
    notifyListeners();

    APIResponse<RoomModel> apiResponse =
        await _bluetoothServices.getRoomFromScan();

    LocalNotifications.preventSelectNotification = false;
    bool _rescan = false;
    _error = apiResponse.error;
    if (_error) {
      _errorMessageRoom = apiResponse.errorMessage;
      _rescan = (_errorMessageRoom == "no_scans");
      if (_rescan) {
        _message = "Phone was locked during scan";
        _subMessage = "Retrying scan...";
      } else {
        _message = "Couldn't scan room";
        _subMessage = "Tap to rescan room";
      }
    } else {
      _room = apiResponse.data;
      _message = "Current room: ${_room.name}";
      _subMessage = "Tap to rescan room";
    }
    notificationTitle = _message;
    notifyListeners();
    _scanningLocation = false;

    LocalNotifications.flutterLocalNotificationsPlugin.show(
      0,
      notificationTitle,
      _subMessage,
      platformChannelSpecifics,
      payload: _rescan ? "rescanning" : "scan",
    );

    if (_rescan) {
      print("retrying in 10 sec");
      await Future.delayed(Duration(seconds: 10));
      print(_room);
      if (_room == null) {
        await sendReceiveLocation();
      }
    }
    return;
  }

  Future<void> updateQuestions() async {
    _questions.clear();
    notifyListeners();
    if (_room == null) {
      return;
    }
    APIResponse<List<FeedbackQuestion>> apiResponseQuestions =
        await _restService.getActiveQuestionsByRoom(_room.id, "week");
    _error = apiResponseQuestions.error;
    if (_error) {
      _errorMessageQuestion = apiResponseQuestions.errorMessage;
      notifyListeners();
    } else {
      _questions.clear();
      _questions.addAll(apiResponseQuestions.data);
      notifyListeners();
    }
  }
}
