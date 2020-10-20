import 'dart:async';
import 'dart:convert';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/questionAndFeedback.dart';
import 'package:climify/models/questionModel.dart';
import 'package:climify/models/questionStatistics.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/api_response.dart';
import 'package:http/http.dart';
import 'package:tuple/tuple.dart';

import 'jwtDecoder.dart';

part 'package:climify/services/rest_service_functions/deleteBuilding.dart';

part 'package:climify/services/rest_service_functions/deleteRoom.dart';

part 'package:climify/services/rest_service_functions/deleteSignalMapsOfRoom.dart';

part 'package:climify/services/rest_service_functions/getActiveQuestionsByRoom.dart';

part 'package:climify/services/rest_service_functions/getAllQuestionsByRoom.dart';

part 'package:climify/services/rest_service_functions/getBeaconBlacklist.dart';

part 'package:climify/services/rest_service_functions/getBuilding.dart';

part 'package:climify/services/rest_service_functions/getBuildingsWithAdminRights.dart';

part 'package:climify/services/rest_service_functions/getFeedback.dart';

part 'package:climify/services/rest_service_functions/getRoomFromSignalMap.dart';

part 'package:climify/services/rest_service_functions/getUserIdFromEmail.dart';

part 'package:climify/services/rest_service_functions/getQuestionStatistics.dart';

part 'package:climify/services/rest_service_functions/patchAddBlacklistBeacon.dart';

part 'package:climify/services/rest_service_functions/patchQuestionInactive.dart';

part 'package:climify/services/rest_service_functions/patchRemoveBlacklistBeacon.dart';

part 'package:climify/services/rest_service_functions/patchUserAdmin.dart';

part 'package:climify/services/rest_service_functions/postBuilding.dart';

part 'package:climify/services/rest_service_functions/postFeedback.dart';

part 'package:climify/services/rest_service_functions/postQuestion.dart';

part 'package:climify/services/rest_service_functions/postRoom.dart';

part 'package:climify/services/rest_service_functions/postSignalMap.dart';

part 'package:climify/services/rest_service_functions/postUnauthorizedUser.dart';

part 'package:climify/services/rest_service_functions/postUser.dart';

part 'package:climify/services/rest_service_functions/postUserLogin.dart';

part 'package:climify/services/rest_service_functions/refreshToken.dart';

enum RequestType {
  GET,
  DELETE,
  PATCH,
  POST,
}

class RestService {
  static const api = kReleaseMode
      ? 'http://feedme.compute.dtu.dk/api'
      : 'http://feedme.compute.dtu.dk/api-dev';
  static Future<Null> mLock;

  static Future<Map<String, String>> headers({
    Map<String, String> additionalParameters = const {},
  }) async {
    String authToken = "";
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    try {
      SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
      authToken = await sharedPrefsHelper.getUserAuthToken();
      headers['x-auth-token'] = authToken;
    } catch (e) {
      print(e);
    }
    additionalParameters.forEach((key, value) {
      headers[key] = value;
    });
    return (headers);
  }

  static Future<APIResponse<T>> requestServer<T>({
    T Function(dynamic json) fromJson,
    T Function(dynamic json, Map<String, String> header) fromJsonAndHeader,
    String body,
    @required RequestType requestType,
    @required String route,
    String errorMessage = "Could not connect to the internet",
    Map<String, String> additionalHeaderParameters = const {},
    bool skipRefreshValidation = false,
  }) async {
    if (mLock != null) {
      await mLock;
      return requestServer(
        fromJson: fromJson,
        fromJsonAndHeader: fromJsonAndHeader,
        body: body,
        requestType: requestType,
        route: route,
        errorMessage: errorMessage,
        additionalHeaderParameters: additionalHeaderParameters,
      );
    }
    //lock
    Completer completer = Completer<Null>();
    mLock = completer.future;

    Map<String, String> reqHeaders;
    String authToken;
    String refreshToken;
    SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();

    try {
      reqHeaders =
          await headers(additionalParameters: additionalHeaderParameters);
      refreshToken = await sharedPrefsHelper.getUserRefreshToken();
      authToken = reqHeaders["x-auth-token"];
    } catch (e) {
      print(e);
      return APIResponse<T>(error: true, errorMessage: "");
    }

    // Make sure authToken hasn't expired
    if (authToken != null && authToken.isNotEmpty && !skipRefreshValidation) {
      int exp = JwtDecoder.parseJwtPayLoad(authToken)["exp"];

      // check if jwt has expired
      if (DateTime.now().millisecondsSinceEpoch / 1000 > exp - 30) {
        // print("refresh token expired");
        APIResponse<Tuple2<String, String>> updatedTokensResponse =
            await updateTokensRequest(authToken, refreshToken);

        if (!updatedTokensResponse.error) {
          try {
            await sharedPrefsHelper.setUserTokens(updatedTokensResponse.data);
          } catch (e) {
            print(e);
          }
          // Update the auth token for the current request
          reqHeaders["x-auth-token"] = updatedTokensResponse.data.item1;
        } else {
          //unlock
          completer.complete();
          mLock = null;
          return APIResponse<T>(
              data: null,
              error: true,
              errorMessage: updatedTokensResponse.errorMessage);
        }
      }
    }

    Response responseData;
    try {
      Map<String, String> requestHeaders = await headers(
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
      //unlock
      completer.complete();
      mLock = null;
      print(e);
      return APIResponse<T>(
          data: null, error: true, errorMessage: errorMessage);
    }

    //unlock
    completer.complete();
    mLock = null;

    if (responseData.statusCode == 200) {
      dynamic bodyJson = {};
      // print("body: ${responseData.body}");
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

  Future<APIResponse<List<FeedbackQuestion>>> Function(String roomId, String t)
      getActiveQuestionsByRoom =
      (roomId, t) => getActiveQuestionsByRoomRequest(roomId, t: t);

  Future<APIResponse<List<FeedbackQuestion>>> Function(String roomId)
      getAllQuestionsByRoom = (roomId) => getAllQuestionsByRoomRequest(roomId);

  Future<APIResponse<bool>> Function(
          FeedbackQuestion question, int chosenOption, RoomModel room)
      postFeedback = (question, choosenOption, room) =>
          postFeedbackRequest(question, choosenOption, room);

  Future<APIResponse<UserModel>> Function(String email, String password)
      postUser = (email, password) => postUserRequest(email, password);

  Future<APIResponse<UserModel>> Function(String email, String password)
      loginUser = (email, password) => loginUserRequest(email, password);

  Future<APIResponse<List<BuildingModel>>> Function()
      getBuildingsWithAdminRights = () => getBuildingsWithAdminRightsRequest();

  Future<APIResponse<String>> Function(BuildingModel building) deleteBuilding =
      (building) => deleteBuildingRequest(building);

  Future<APIResponse<BuildingModel>> Function(String buildingId) getBuilding =
      (buildingId) => getBuildingRequest(buildingId);

  Future<APIResponse<BuildingModel>> Function(String buildingName)
      postBuilding = (buildingName) => postBuildingRequest(buildingName);

  Future<APIResponse<RoomModel>> Function(
          String roomName, BuildingModel building) postRoom =
      (roomName, building) => postRoomRequest(roomName, building);

  Future<APIResponse<String>> Function(String roomId) deleteRoom =
      (roomId) => deleteRoomRequest(roomId);

  Future<APIResponse<String>> Function(SignalMap signalMap, String roomId)
      postSignalMap =
      (signalMap, roomId) => postSignalMapRequest(signalMap, roomId);

  Future<APIResponse<String>> Function(String roomId) deleteSignalMapsOfRoom =
      (roomId) => deleteSignalMapsOfRoomRequest(roomId);

  Future<APIResponse<RoomModel>> Function(SignalMap signalMap)
      getRoomFromSignalMap =
      (signalMap) => getRoomFromSignalMapRequest(signalMap);

  Future<APIResponse<Question>> Function(
          List<String> rooms, String value, List<String> answerOptions)
      postQuestion = (rooms, value, answerOptions) =>
          postQuestionRequest(rooms, value, answerOptions);

  Future<APIResponse<Tuple2<String, String>>> Function() postUnauthorizedUser =
      () => postUnauthorizedUserRequest();

  Future<APIResponse<Tuple2<String, String>>> Function(
          String authToken, String refreshToken) updateTokens =
      (authToken, refreshToken) => updateTokensRequest(authToken, refreshToken);

  Future<APIResponse<List<QuestionAndFeedback>>> Function(String user, String t)
      getFeedback = (user, t) => getFeedbackRequest(user, t);

  Future<APIResponse<QuestionStatisticsModel>> Function(
          FeedbackQuestion question, String t) getQuestionStatistics =
      (question, t) => getQuestionStatisticsRequest(question, t);

  Future<APIResponse<bool>> Function(String email, BuildingModel building)
      patchUserAdmin =
      (email, building) => patchUserAdminRequest(email, building);

  Future<APIResponse<String>> Function(String email) getUserIdFromEmail =
      (email) => getUserIdFromEmailRequest(email);

  Future<APIResponse<String>> Function(String questionId, bool isActive)
      patchQuestionInactive = (questionId, isActive) =>
          patchQuestionInactiveRequest(questionId, isActive);

  Future<APIResponse<List<String>>> Function(String buildingId)
      getBeaconBlacklist =
      (buildingId) => getBeaconBlacklistRequest(buildingId);

  Future<APIResponse<bool>> Function(String buildingId, String beaconName)
      patchAddBlacklistBeacon = (buildingId, beaconName) =>
          patchAddBlacklistBeaconRequest(buildingId, beaconName);

  Future<APIResponse<bool>> Function(String buildingId, String beaconName)
      patchRemoveBlacklistBeacon = (buildingId, beaconName) =>
          patchRemoveBlacklistBeaconRequest(buildingId, beaconName);
}
