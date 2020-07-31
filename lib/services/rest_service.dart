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
// import 'package:climify/services/rest_service_functions/addBeacon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart';
import 'package:http/http.dart' as http;

import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

part 'package:climify/services/rest_service_functions/addBeacon.dart';
part 'package:climify/services/rest_service_functions/getActiveQuestionsByRoom.dart';
part 'package:climify/services/rest_service_functions/getAllQuestionsByRoom.dart';
part 'package:climify/services/rest_service_functions/postFeedback.dart';
part 'package:climify/services/rest_service_functions/postUser.dart';
part 'package:climify/services/rest_service_functions/postUserLogin.dart';
part 'package:climify/services/rest_service_functions/getBuildingsWithAdminRights.dart';

enum RequestType {
  GET,
  DELETE,
  PATCH,
  POST,
}

class RestService {
  final BuildContext context;
  BluetoothServices bluetooth;

  RestService(
    this.context,
  ) {
    bluetooth = BluetoothServices(context);

    addBeacon =
        (beacon, building) => addBeaconRequest(context, beacon, building);

    getActiveQuestionsByRoom =
        (roomId, t) => getActiveQuestionsByRoomRequest(context, roomId, t: t);

    getAllQuestionsByRoom =
        (roomId) => getAllQuestionsByRoomRequest(context, roomId);

    postFeedback = (question, choosenOption, room) =>
        postFeedbackRequest(context, question, choosenOption, room);

    postUser = (email, password) => postUserRequest(context, email, password);

    loginUser = (email, password) => loginUserRequest(context, email, password);

    getBuildingsWithAdminRights = () => getBuildingsWithAdminRightsRequest(context);
  }

  static Map<String, String> headers(
    BuildContext context, {
    bool noToken = false,
    Map<String, String> additionalParameters = const {},
  }) {
    String token = "";
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (!noToken) {
      try {
        token = Provider.of<GlobalState>(context).globalState['token'];
        headers['x-auth-token'] = token;
      } catch (_) {}
    }
    additionalParameters.forEach((key, value) {
      headers[key] = value;
    });
    return (headers);
  }

  static Future<APIResponse<T>> requestServer<T>(
    BuildContext context, {
    T Function(dynamic) fromJson,
    T Function(dynamic, Map<String, String>) fromJsonAndHeader,
    String body,
    @required RequestType requestType,
    @required String route,
    Map<String, String> additionalHeaderParameters = const {},
  }) async {
    Future<Response> responseData;
    switch (requestType) {
      case RequestType.GET:
        responseData = http.get(
          api + route,
          headers: headers(
            context,
            additionalParameters: additionalHeaderParameters,
          ),
        );
        break;
      case RequestType.POST:
        responseData = http.post(
          api + route,
          headers: headers(
            context,
            additionalParameters: additionalHeaderParameters,
          ),
          body: body,
        );
        break;
      case RequestType.DELETE:
        responseData = http.delete(
          api + route,
          headers: headers(
            context,
            additionalParameters: additionalHeaderParameters,
          ),
        );
        break;
      case RequestType.PATCH:
        responseData = http.patch(
          api + route,
          headers: headers(
            context,
            additionalParameters: additionalHeaderParameters,
          ),
          body: body,
        );
        break;
      default:
    }
    return responseData.then((data) {
      if (data.statusCode == 200) {
        dynamic bodyJson = {};
        try {
          bodyJson = json.decode(data.body);
        } catch (_) {
          print("Could not convert body to json");
        }
        Map<String, String> headerData = data.headers;
        T responseObject;
        print(bodyJson);
        if (fromJson != null) {
          responseObject = fromJson(bodyJson);
        } else if (fromJsonAndHeader != null) {
          responseObject = fromJsonAndHeader(bodyJson, headerData);
        }
        return APIResponse<T>(data: responseObject);
      } else {
        return APIResponse<T>(
            error: true, errorMessage: data.body ?? getErrorMessage(data));
      }
    }).catchError((e) {
      print(e);
      return APIResponse<T>(error: true, errorMessage: "Request failed");
    });
  }

  static const api = 'http://climify-spe.compute.dtu.dk:8080/api-dev';

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

  Future<APIResponse<List<FeedbackQuestion>>> Function(String, String)
      getActiveQuestionsByRoom;

  Future<APIResponse<List<FeedbackQuestion>>> Function(String)
      getAllQuestionsByRoom;

  Future<APIResponse<bool>> Function(FeedbackQuestion, int, RoomModel)
      postFeedback;

  Future<APIResponse<UserModel>> Function(String, String) postUser;

  Future<APIResponse<UserModel>> Function(String, String) loginUser;

  Future<APIResponse<List<BuildingModel>>> Function() getBuildingsWithAdminRights;

  // Future<APIResponse<List<BuildingModel>>> getBuildingsWithAdminRights(
  //     String token) {
  //   return http
  //       .get(api + '/buildings?admin=me', headers: headers(context))
  //       .then((data) {
  //     if (data.statusCode == 200) {
  //       final responseBody = json.decode(data.body);
  //       List<BuildingModel> buildings = [];
  //       for (int i = 0; i < responseBody.length; i++) {
  //         dynamic responseBuilding = responseBody[i];
  //         buildings.add(BuildingModel.fromJson(responseBuilding));
  //       }
  //       return APIResponse<List<BuildingModel>>(
  //           data: buildings, statusCode: 200);
  //     } else {
  //       final errorMessage = "";
  //       return APIResponse<List<BuildingModel>>(
  //           error: true,
  //           errorMessage: errorMessage,
  //           statusCode: data.statusCode);
  //     }
  //   }).catchError((_) => APIResponse<List<BuildingModel>>(
  //           error: true, errorMessage: 'Get Buildings failed'));
  // }

  Future<APIResponse<String>> deleteBuilding(
    String token,
    BuildingModel building,
  ) {
    return http
        .delete(api + '/buildings/' + building.id, headers: headers(context))
        .then((data) {
      if (data.statusCode == 200) {
        return APIResponse<String>(data: "Deleted building ${building.name}");
      } else {
        return APIResponse<String>(error: true, errorMessage: data.body ?? "");
      }
    }).catchError((e) {
      print(e);
      return APIResponse<String>(
          error: true, errorMessage: "Deleting building failed");
    });
  }

  Future<APIResponse<List<Beacon>>> getBeaconsOfBuilding(
    String token,
    BuildingModel building,
  ) {
    return http
        .get(api + '/beacons?building=' + building.id,
            headers: headers(context))
        .then((data) {
      if (data.statusCode == 200) {
        List<Beacon> beacons = [];
        final responseBody = json.decode(data.body);
        for (int i = 0; i < responseBody.length; i++) {
          Map<String, dynamic> jsonData = responseBody[i];
          Beacon beacon = Beacon.fromJson(jsonData);
          beacons.add(beacon);
        }
        return APIResponse<List<Beacon>>(data: beacons);
      } else {
        return APIResponse<List<Beacon>>(
            error: true, errorMessage: data.body ?? "");
      }
    }).catchError((e) {
      print(e);
      return APIResponse<List<Beacon>>(
          error: true, errorMessage: "Getting beacons failed");
    });
  }

  Future<APIResponse<List<Beacon>>> getAllBeacons(
    String token,
  ) {
    return http.get(api + '/beacons', headers: headers(context)).then((data) {
      if (data.statusCode == 200) {
        List<Beacon> beacons = [];
        final responseBody = json.decode(data.body);
        for (int i = 0; i < responseBody.length; i++) {
          Beacon beacon = Beacon.fromJson(responseBody[i]);
          beacons.add(beacon);
        }
        return APIResponse<List<Beacon>>(data: beacons);
      } else {
        return APIResponse<List<Beacon>>(
            error: true, errorMessage: data.body ?? "");
      }
    }).catchError((e) {
      print(e);
      return APIResponse<List<Beacon>>(
          error: true, errorMessage: "Getting all beacons failed");
    });
  }

  Future<APIResponse<BuildingModel>> getBuilding(
    String token,
    String buildingId,
  ) {
    return http
        .get(api + '/buildings/' + buildingId, headers: headers(context))
        .then((data) {
      if (data.statusCode == 200) {
        dynamic resultBody = json.decode(data.body);
        BuildingModel building = BuildingModel.fromJson(resultBody);
        return APIResponse<BuildingModel>(data: building);
      } else {
        return APIResponse<BuildingModel>(
            error: true, errorMessage: data.body ?? "");
      }
    }).catchError((e) => APIResponse<BuildingModel>(
              error: true,
              errorMessage: "Get Building Failed",
            ));
  }

  Future<APIResponse<BuildingModel>> addBuilding(
    String token,
    String buildingName,
  ) {
    final String body = json.encode({
      'name': buildingName,
    });
    return http
        .post(api + '/buildings', headers: headers(context), body: body)
        .then((buildingData) {
      if (buildingData.statusCode == 200) {
        dynamic resultBody = json.decode(buildingData.body);
        BuildingModel building = BuildingModel(
          resultBody['_id'],
          resultBody['name'],
          [],
        );
        return APIResponse<BuildingModel>(data: building);
      } else {
        return APIResponse<BuildingModel>(
            error: true, errorMessage: buildingData.body ?? "");
      }
    }).catchError((e) {
      return APIResponse<BuildingModel>(
          error: true, errorMessage: "Add building failed");
    });
  }

  Future<APIResponse<RoomModel>> addRoom(
    String token,
    String roomName,
    BuildingModel building,
  ) {
    final String body = json.encode({
      'name': roomName,
      'buildingId': building.id,
    });
    return http
        .post(api + '/rooms', headers: headers(context), body: body)
        .then((roomData) {
      if (roomData.statusCode == 200) {
        dynamic resultBody = json.decode(roomData.body);
        RoomModel room = RoomModel.fromJson(resultBody);
        return APIResponse<RoomModel>(data: room);
      } else {
        return APIResponse<RoomModel>(
            error: true, errorMessage: roomData.body ?? "");
      }
    }).catchError((e) {
      return APIResponse<RoomModel>(
          error: true, errorMessage: "Add room failed");
    });
  }

  Future<APIResponse<String>> deleteRoom(
    String token,
    String roomId,
  ) {
    return http
        .delete(api + '/rooms/$roomId', headers: headers(context))
        .then((deleteRoomData) {
      if (deleteRoomData.statusCode == 200) {
        return APIResponse<String>(data: "Room deleted");
      } else {
        return APIResponse<String>(
            error: true, errorMessage: deleteRoomData.body);
      }
    }).catchError((e) {
      return APIResponse<String>(
          error: true, errorMessage: "Failed to delete room");
    });
  }

  Future<APIResponse<String>> deleteBeacon(
    String token,
    String beaconId,
    BuildingModel building,
  ) {
    return http
        .delete(api + '/beacons/' + beaconId, headers: headers(context))
        .then((deleteBeaconData) {
      if (deleteBeaconData.statusCode == 200) {
        return APIResponse<String>(data: "Beacon deleted");
      } else {
        return APIResponse<String>(
            error: true, errorMessage: deleteBeaconData.body);
      }
    }).catchError((e) {
      return APIResponse<String>(
          error: true, errorMessage: "Failed to delete beacon");
    });
  }

  Future<APIResponse<String>> addSignalMap(
    String token,
    SignalMap signalMap,
    String roomId,
  ) {
    final String signalBody = json.encode({
      "beacons": signalMap.beacons,
      "roomId": roomId,
      "buildingId": signalMap.buildingId
    });
    return http
        .post(api + '/signalMaps', headers: headers(context), body: signalBody)
        .then((signalMapData) {
      if (signalMapData.statusCode == 200) {
        return APIResponse<String>(data: "Scan added");
      } else {
        return APIResponse<String>(
            error: true, errorMessage: signalMapData.body ?? "");
      }
    }).catchError((e) {
      return APIResponse<String>(
          error: true, errorMessage: "Add signal map failed");
    });
  }

  Future<APIResponse<String>> deleteSignalMapsOfRoom(
    String token,
    String roomId,
  ) {
    return http
        .delete(api + '/signalMaps/room/$roomId', headers: headers(context))
        .then((signalMapDeleteData) {
      if (signalMapDeleteData.statusCode == 200) {
        return APIResponse<String>(data: "Scans Deleted");
      } else {
        return APIResponse<String>(
            error: true, errorMessage: signalMapDeleteData.body ?? "");
      }
    }).catchError((e) {
      return APIResponse<String>(
          error: true, errorMessage: "Delete signal maps of room failed");
    });
  }

  Future<APIResponse<RoomModel>> getRoomFromSignalMap(
    String token,
    SignalMap signalMap,
  ) {
    final String signalBody = json.encode({
      "beacons": signalMap.beacons,
      "buildingId": signalMap.buildingId,
    });
    print(signalBody);
    return http
        .post(api + '/signalMaps', headers: headers(context), body: signalBody)
        .then((data) {
      if (data.statusCode == 200) {
        dynamic responseBody = json.decode(data.body);
        RoomModel room = RoomModel(
          "error",
          "error",
        );
        try {
          responseBody = responseBody['room'];
          room = RoomModel.fromJson(responseBody);
        } catch (e) {}
        return APIResponse<RoomModel>(data: room);
      } else {
        return APIResponse<RoomModel>(
            error: true, errorMessage: data.body ?? "");
      }
    }).catchError((e) =>
            APIResponse<RoomModel>(error: true, errorMessage: e.toString()));
  }

  Future<APIResponse<String>> Function(Tuple2<String, String>, BuildingModel)
      addBeacon;

  Future<APIResponse<Question>> addQuestion(
    String token,
    List<String> rooms,
    String value,
    List<String> answerOptions,
  ) {
    final String body = json.encode({
      'rooms': rooms,
      'value': value,
      'answerOptions': answerOptions,
    });
    return http
        .post(api + '/questions', headers: headers(context), body: body)
        .then((questionData) {
      if (questionData.statusCode == 200) {
        dynamic resultBody = json.decode(questionData.body);
        print(resultBody);
        Question question = Question.fromJson(resultBody);
        return APIResponse<Question>(data: question);
      } else {
        return APIResponse<Question>(
            error: true, errorMessage: questionData.body ?? "");
      }
    }).catchError((e) {
      print(e);
      return APIResponse<Question>(
          error: true, errorMessage: "Adding question failed");
    });
  }

  Future<APIResponse<UserModel>> createUnauthorizedUser() {
    return http
        .post(api + '/users', headers: headers(context, noToken: true))
        .then((data) {
      if (data.statusCode == 200) {
        final responseHeaders = data.headers;
        final token = responseHeaders['x-auth-token'];
        return APIResponse<UserModel>(
          data: UserModel(
            "",
            token,
          ),
        );
      } else {
        return APIResponse<UserModel>(
          error: true,
          errorMessage: data.body,
        );
      }
    }).catchError(
      (_) => APIResponse<UserModel>(
          error: true, errorMessage: 'Check your internet connection'),
    );
  }

  Future<APIResponse<List<QuestionAndFeedback>>> getFeedback(
      String token, String user, String t) {
    return http
        .get(api + '/feedback?user=' + user + '&t=' + t,
            headers: headers(context))
        .then((data) {
      if (data.statusCode == 200) {
        List<QuestionAndFeedback> feedbackList = <QuestionAndFeedback>[];
        dynamic resultBody = json.decode(data.body);
        if (resultBody == null || resultBody.length < 1) {
          return APIResponse<List<QuestionAndFeedback>>(
            error: true,
            errorMessage: "List of answered questions were empty",
          );
        }
        for (var e in resultBody) {
          if (e['answer'] != null && e['question'] != null) {
            QuestionAndFeedback qF = QuestionAndFeedback(
              e["_id"],
              e["user"],
              e["room"],
              AnswerOption.fromJson(e["answer"]),
              FeedbackQuestion.fromJson(e["question"]),
              e["createdAt"],
              e["updatedAt"],
              e["__v"],
            );
            feedbackList.add(qF);
          }
        }
        return APIResponse<List<QuestionAndFeedback>>(
          data: feedbackList,
        );
      } else {
        return APIResponse<List<QuestionAndFeedback>>(
            error: true, errorMessage: "Getting answered questions failed");
      }
    }).catchError((e) {
      return APIResponse<List<QuestionAndFeedback>>(
          error: true, errorMessage: "Getting answered questions failed");
    });
  }

  Future<APIResponse<QuestionStatisticsModel>> getQuestionStatistics(
    String token,
    FeedbackQuestion question, {
    String t,
  }) {
    FeedbackQuestion q = question;
    String url;
    if (t == null) {
      url = api + '/feedback/questionStatistics/' + q.id;
    } else {
      url = api + '/feedback/questionStatistics/' + q.id + '?t=' + t;
    }
    return http.get(url, headers: headers(context)).then((data) {
      if (data.statusCode == 200) {
        return APIResponse<QuestionStatisticsModel>(
          data: QuestionStatisticsModel.fromJson(
            q,
            json.decode(data.body),
          ),
        );
      } else {
        return APIResponse<QuestionStatisticsModel>(
          error: true,
          errorMessage: "Check your internet connection",
        );
      }
    });
  }

  Future<APIResponse<UserModel>> makeUserAdmin(
    String token,
    String userId,
    BuildingModel building,
  ) {
    final String body =
        json.encode({'userId': userId, 'buildingId': building.id});
    return http
        .patch(api + '/users/makeBuildingAdmin',
            headers: headers(context), body: body)
        .then((adminData) {
      if (adminData.statusCode == 200) {
        dynamic resultBody = json.decode(adminData.body);
        UserModel userModel = UserModel(
          resultBody['userId'],
          resultBody['bulding'],
        );
        return APIResponse<UserModel>(data: userModel);
      } else {
        return APIResponse<UserModel>(
            error: true, errorMessage: adminData.body ?? "");
      }
    }).catchError((e) {
      return APIResponse<UserModel>(
          error: true, errorMessage: "Making user admin failed");
    });
  }

  Future<APIResponse<String>> getUserIdFromEmail(
    String token,
    String email,
  ) {
    return http
        .get(api + '/users/getUserIdFromEmail/' + email,
            headers: headers(context))
        .then((userData) {
      if (userData.statusCode == 200) {
        return APIResponse<String>(data: userData.body);
      } else {
        return APIResponse<String>(
            error: true, errorMessage: userData.body ?? "");
      }
    }).catchError((e) => APIResponse<String>(
              error: true,
              errorMessage: "Get userId Failed",
            ));
  }

  Future<APIResponse<String>> makeQuestionInactive(
    String token,
    String questionId,
    bool isActive,
  ) {
    final String body = json.encode({'isActive': isActive});
    return http
        .patch(api + '/questions/setActive/' + questionId,
            headers: headers(context), body: body)
        .then((questionData) {
      if (questionData.statusCode == 200) {
        return APIResponse<String>(data: "Question set inactive");
      } else {
        return APIResponse<String>(
            error: true, errorMessage: questionData.body);
      }
    });
  }
}
