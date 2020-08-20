import 'dart:convert';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/questionAndFeedback.dart';
import 'package:climify/models/questionModel.dart';
import 'package:climify/models/questionStatistics.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/sharedPreferences.dart';
// import 'package:climify/services/rest_service_functions/addBeacon.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

part 'package:climify/services/rest_service_functions/deleteBeacon.dart';
part 'package:climify/services/rest_service_functions/deleteBuilding.dart';
part 'package:climify/services/rest_service_functions/deleteRoom.dart';
part 'package:climify/services/rest_service_functions/deleteSignalMapsOfRoom.dart';

part 'package:climify/services/rest_service_functions/getActiveQuestionsByRoom.dart';
part 'package:climify/services/rest_service_functions/getAllBeacons.dart';
part 'package:climify/services/rest_service_functions/getAllQuestionsByRoom.dart';
part 'package:climify/services/rest_service_functions/getBeaconsOfBuilding.dart';
part 'package:climify/services/rest_service_functions/getBuilding.dart';
part 'package:climify/services/rest_service_functions/getBuildingsWithAdminRights.dart';
part 'package:climify/services/rest_service_functions/getFeedback.dart';
part 'package:climify/services/rest_service_functions/getRoomFromSignalMap.dart';
part 'package:climify/services/rest_service_functions/getUserIdFromEmail.dart';
part 'package:climify/services/rest_service_functions/getQuestionStatistics.dart';

part 'package:climify/services/rest_service_functions/patchQuestionInactive.dart';
part 'package:climify/services/rest_service_functions/patchUserAdmin.dart';

part 'package:climify/services/rest_service_functions/postBeacon.dart';
part 'package:climify/services/rest_service_functions/postBuilding.dart';
part 'package:climify/services/rest_service_functions/postFeedback.dart';
part 'package:climify/services/rest_service_functions/postQuestion.dart';
part 'package:climify/services/rest_service_functions/postRoom.dart';
part 'package:climify/services/rest_service_functions/postSignalMap.dart';
part 'package:climify/services/rest_service_functions/postUnauthorizedUser.dart';
part 'package:climify/services/rest_service_functions/postUser.dart';
part 'package:climify/services/rest_service_functions/postUserLogin.dart';

enum RequestType {
  GET,
  DELETE,
  PATCH,
  POST,
}

class RestService {
  static const api = 'http://climify-spe.compute.dtu.dk:8080/api-dev';

  static Future<Map<String, String>> headers(
    BuildContext context, {
    Map<String, String> additionalParameters = const {},
  }) async {
    String token = "";
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    try {
      token = Provider.of<GlobalState>(context).globalState['token'];
      headers['x-auth-token'] = token;
    } catch (e) {
      print(e);
      try {
        SharedPreferences _sharedPreferences =
            await SharedPreferences.getInstance();
        token = _sharedPreferences.getString("testToken");
        headers['x-auth-token'] = token;
      } catch (e) {
        print(e);
      }
    }
    additionalParameters.forEach((key, value) {
      headers[key] = value;
    });
    return (headers);
  }

  static Future<APIResponse<T>> requestServer<T>(
    BuildContext context, {
    T Function(dynamic json) fromJson,
    T Function(dynamic json, Map<String, String> header) fromJsonAndHeader,
    String body,
    @required RequestType requestType,
    @required String route,
    String errorMessage = "Could not connect to the internet",
    Map<String, String> additionalHeaderParameters = const {},
  }) async {
    Response responseData;
    try {
      Map<String, String> requestHeaders = await headers(
        context,
        additionalParameters: additionalHeaderParameters,
      );
      switch (requestType) {
        case RequestType.GET:
          responseData = await http.get(
            api + route,
            headers: requestHeaders,
          );
          break;
        case RequestType.POST:
          responseData = await http.post(
            api + route,
            headers: requestHeaders,
            body: body,
          );
          break;
        case RequestType.DELETE:
          responseData = await http.delete(
            api + route,
            headers: requestHeaders,
          );
          break;
        case RequestType.PATCH:
          responseData = await http.patch(
            api + route,
            headers: requestHeaders,
            body: body,
          );
          break;
        default:
      }
    } catch (e) {
      return APIResponse<T>(
          data: null, error: true, errorMessage: errorMessage);
    }

    if (responseData.statusCode == 200) {
      dynamic bodyJson = {};
      try {
        bodyJson = json.decode(responseData.body);
      } catch (_) {
        print("Could not convert body to json");
        bodyJson = responseData.body;
      }
      Map<String, String> headerData = responseData.headers;
      T responseObject;
      if (fromJson != null) {
        responseObject = fromJson(bodyJson);
      } else if (fromJsonAndHeader != null) {
        responseObject = fromJsonAndHeader(bodyJson, headerData);
      }
      return APIResponse<T>(data: responseObject);
    } else {
      return APIResponse<T>(
          error: true,
          errorMessage: responseData?.body ?? getErrorMessage(responseData));
    }
  }

  static APIResponse<T> getErrorMessage<T>(Response response) {
    switch (response.statusCode) {
      case 400:
        return APIResponse<T>(error: true, errorMessage: "Bad request");
      case 401:
        return APIResponse<T>(error: true, errorMessage: "Not authorized");
      case 403:
        return APIResponse<T>(error: true, errorMessage: "Forbidden");
      case 404:
        return APIResponse<T>(error: true, errorMessage: "Not Found");
      default:
        return APIResponse<T>(error: true, errorMessage: "Unknown Error");
    }
  }

  final BuildContext context;

  BluetoothServices bluetooth;

  Future<APIResponse<List<FeedbackQuestion>>> Function(String, String)
      getActiveQuestionsByRoom;

  Future<APIResponse<List<FeedbackQuestion>>> Function(String)
      getAllQuestionsByRoom;

  Future<APIResponse<bool>> Function(FeedbackQuestion, int, RoomModel)
      postFeedback;

  Future<APIResponse<UserModel>> Function(String, String) postUser;

  Future<APIResponse<UserModel>> Function(String, String) loginUser;

  Future<APIResponse<List<BuildingModel>>> Function()
      getBuildingsWithAdminRights;

  Future<APIResponse<String>> Function(BuildingModel) deleteBuilding;

  Future<APIResponse<List<Beacon>>> Function(BuildingModel)
      getBeaconsOfBuilding;

  Future<APIResponse<List<Beacon>>> Function() getAllBeacons;

  Future<APIResponse<BuildingModel>> Function(String) getBuilding;

  Future<APIResponse<BuildingModel>> Function(String) postBuilding;

  Future<APIResponse<RoomModel>> Function(String, BuildingModel) postRoom;

  Future<APIResponse<String>> Function(String) deleteRoom;

  Future<APIResponse<String>> Function(String) deleteBeacon;

  Future<APIResponse<String>> Function(SignalMap, String) postSignalMap;

  Future<APIResponse<String>> Function(String) deleteSignalMapsOfRoom;

  Future<APIResponse<RoomModel>> Function(SignalMap) getRoomFromSignalMap;

  Future<APIResponse<String>> Function(Tuple2<String, String>, BuildingModel)
      postBeacon;

  Future<APIResponse<Question>> Function(List<String>, String, List<String>)
      postQuestion;

  Future<APIResponse<UserModel>> Function() postUnauthorizedUser;

  Future<APIResponse<List<QuestionAndFeedback>>> Function(String, String)
      getFeedback;

  Future<APIResponse<QuestionStatisticsModel>> Function(
      FeedbackQuestion, String) getQuestionStatistics;

  Future<APIResponse<bool>> Function(String, BuildingModel) patchUserAdmin;

  Future<APIResponse<String>> Function(String) getUserIdFromEmail;

  Future<APIResponse<String>> Function(String, bool) patchQuestionInactive;

  RestService(
    this.context,
  ) {
    bluetooth = BluetoothServices(context);

    getActiveQuestionsByRoom =
        (roomId, t) => getActiveQuestionsByRoomRequest(context, roomId, t: t);

    getAllQuestionsByRoom =
        (roomId) => getAllQuestionsByRoomRequest(context, roomId);

    postFeedback = (question, choosenOption, room) =>
        postFeedbackRequest(context, question, choosenOption, room);

    postUser = (email, password) => postUserRequest(context, email, password);

    loginUser = (email, password) => loginUserRequest(context, email, password);

    getBuildingsWithAdminRights =
        () => getBuildingsWithAdminRightsRequest(context);

    deleteBuilding = (building) => deleteBuildingRequest(context, building);

    getBeaconsOfBuilding =
        (building) => getBeaconsOfBuildingRequest(context, building);

    getAllBeacons = () => getAllBeaconsRequest(context);

    getBuilding = (buildingId) => getBuildingRequest(context, buildingId);

    postBuilding = (buildingName) => postBuildingRequest(context, buildingName);

    postRoom =
        (roomName, building) => postRoomRequest(context, roomName, building);

    deleteRoom = (roomId) => deleteRoomRequest(context, roomId);

    deleteBeacon = (beaconId) => deleteBeaconRequest(context, beaconId);

    postSignalMap =
        (signalMap, roomId) => postSignalMapRequest(context, signalMap, roomId);

    deleteSignalMapsOfRoom =
        (roomId) => deleteSignalMapsOfRoomRequest(context, roomId);

    getRoomFromSignalMap =
        (signalMap) => getRoomFromSignalMapRequest(context, signalMap);

    postBeacon =
        (beacon, building) => postBeaconRequest(context, beacon, building);

    postQuestion = (rooms, value, answerOptions) =>
        postQuestionRequest(context, rooms, value, answerOptions);

    postUnauthorizedUser = () => postUnauthorizedUserRequest(context);

    getFeedback = (user, t) => getFeedbackRequest(context, user, t);

    getQuestionStatistics =
        (question, t) => getQuestionStatisticsRequest(context, question, t);

    patchUserAdmin =
        (userId, building) => patchUserAdminRequest(context, userId, building);

    getUserIdFromEmail = (email) => getUserIdFromEmailRequest(context, email);

    patchQuestionInactive = (questionId, isActive) =>
        patchQuestionInactiveRequest(context, questionId, isActive);
  }
}
