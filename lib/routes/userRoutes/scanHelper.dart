import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:flutter/material.dart';

class ScanHelper {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String token;

  ScanHelper(
    this.scaffoldKey,
    this.token,
  );

  BluetoothServices _bluetooth = BluetoothServices();
  RestService _restService = RestService();
  BuildingModel _building;
  RoomModel _room;
  List<FeedbackQuestion> _questions;

  Future<_Result> scanBuildingAndRoom() async {
    if (_building == null) await _getBuildingScan();
    if (_building != null) await _getAndSetRoom();
    print(_questions);
    return _Result(
      _building,
      _room,
      _questions,
    );
  }

  Future<void> _getBuildingScan() async {
    APIResponse<String> idResponse =
        await _bluetooth.getBuildingIdFromScan(token);
    if (!idResponse.error) {
      APIResponse<BuildingModel> buildingResponse =
          await _restService.getBuilding(token, idResponse.data);
      if (!buildingResponse.error) {
        _building = buildingResponse.data;
      } else {
        SnackBarError.showErrorSnackBar("Failed getting building", scaffoldKey);
      }
    } else {
      SnackBarError.showErrorSnackBar(idResponse.errorMessage, scaffoldKey);
    }
    return;
  }

  Future<void> _getAndSetRoom() async {
    APIResponse<RoomModel> apiResponse =
        await _bluetooth.getRoomFromBuilding(_building, token);
    if (!apiResponse.error) {
      _room = apiResponse.data;
      await getActiveQuestions();
    } else {
      SnackBarError.showErrorSnackBar(apiResponse.errorMessage, scaffoldKey);
    }
    return;
  }

  Future<List<FeedbackQuestion>> getActiveQuestions() async {
    APIResponse<List<FeedbackQuestion>> apiResponseQuestions =
        await _restService.getActiveQuestionsByRoom(_room.id, token);
    if (apiResponseQuestions.error) {
      SnackBarError.showErrorSnackBar(
        apiResponseQuestions.errorMessage,
        scaffoldKey,
      );
      return [];
    }
    _questions = apiResponseQuestions.data;
    return _questions;
  }
}

class _Result {
  final BuildingModel building;
  final RoomModel room;
  final List<FeedbackQuestion> questions;

  _Result(
    this.building,
    this.room,
    this.questions,
  );
}
