import 'dart:convert';
import 'dart:ffi';
import 'package:climify/models/beacon.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/questionModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/signalMap.dart';
import 'package:climify/models/userModel.dart';
import 'package:http/http.dart' as http;

import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';
import 'package:http/http.dart';
import 'package:tuple/tuple.dart';

class RestService {
  static const api = 'http://climify-spe.compute.dtu.dk:8080/api-dev';
  Map<String, String> headers({String token = ""}) =>
      {'Content-Type': 'application/json', 'x-auth-token': token};

  String getErrorMessage(Response response) {
    switch (response.statusCode) {
      case 400:
        return "Bad request";
      case 401:
        return "Not authorized";
      case 403:
        return "Forbidden";
      case 404:
        return "Not found";
      default:
        return "Unknown Error";
    }
  }

  Future<APIResponse<List<FeedbackQuestion>>> getQuestionByRoom(String room) {
    print(room);
    return http
        .get(api + '/question/room/' + room, headers: headers())
        .then((data) async {
      print("Hej");
      if (data.statusCode == 200) {
        print("Hej1");
        List<String> answerOptionsId;
        final jsonData = json.decode(data.body);
        print(jsonData.toString());
        final questionList = <FeedbackQuestion>[];
        print("Hej2");
        for (var e in jsonData) {
          print("HejHej");
          final feedbackQuestion = FeedbackQuestion(
              sId: e['_id'],
              question: e['question'],
              room: e['room'],
              iV: e['__v']);
          print("HejHejHej");
          print(e['answerOptions'].toString());
          answerOptionsId = List.from(e['answerOptions']);
          print("1");
          print(answerOptionsId.toString());
          APIResponse<List<AnswerOption>> temp;
          if (answerOptionsId.length > 0) {
            //temp = await getAnswerOptionsByIdList(answerOptionsId);
          }
          /*
          if (temp.error != true) {
            print("Betta");
            feedbackQuestion.answerOptions = temp.data;
          } else {
            return APIResponse<List<FeedbackQuestion>>(error: true, errorMessage: 'No questions found');
          }*/
          questionList.add(feedbackQuestion);
        }
        print("Hej3");
        return APIResponse<List<FeedbackQuestion>>(data: questionList);
      }
      return APIResponse<List<FeedbackQuestion>>(
          error: true, errorMessage: 'An error occured1');
    }).catchError((_) => APIResponse<List<FeedbackQuestion>>(
            error: true, errorMessage: 'An error occured2'));
  }

  Future<APIResponse<List<AnswerOption>>> getAnswerOptionsByIdList(
      List<String> answerIdList) {
    return http
        .get(api + '/answer/fromQuestion/' + answerIdList.toString(),
            headers: headers())
        .then((data) {
      if (data.statusCode == 200) {
        //returns json object
        final jsonData = json.decode(data.body);
        final answerOptionList = <AnswerOption>[];
        for (var e in jsonData) {
          final answerOption = AnswerOption(
              timesAnswered: e['timesAnswered'],
              sId: e['_id'],
              answer: e['answer'],
              iV: e['__v']);
          answerOptionList.add(answerOption);
        }
        if (answerOptionList != null) {
          return APIResponse<List<AnswerOption>>(data: answerOptionList);
        } else {
          return APIResponse<List<AnswerOption>>(
              error: true, errorMessage: 'No answers were found');
        }
      }
      return APIResponse<List<AnswerOption>>(
          error: true, errorMessage: 'An error occured3');
    }).catchError((_) => APIResponse<List<AnswerOption>>(
            error: true, errorMessage: 'An error occured4'));
  }

  Future<APIResponse<List<AnswerOption>>> getAnswerOptionsByRoom(
      String questionId) {
    return http
        .get(api + '/answer/fromQuestion/' + questionId, headers: headers())
        .then((data) {
      if (data.statusCode == 200) {
        //returns json object
        final jsonData = json.decode(data.body);
        final answerOptionList = <AnswerOption>[];
        for (var e in jsonData) {
          final answerOption = AnswerOption(
              timesAnswered: e['timesAnswered'],
              sId: e['_id'],
              answer: e['answer'],
              iV: e['__v']);
          answerOptionList.add(answerOption);
        }
        if (answerOptionList != null) {
          return APIResponse<List<AnswerOption>>(data: answerOptionList);
        } else {
          return APIResponse<List<AnswerOption>>(
              error: true, errorMessage: 'No answers were found');
        }
      }
      return APIResponse<List<AnswerOption>>(
          error: true, errorMessage: 'An error occured');
    }).catchError((_) => APIResponse<List<AnswerOption>>(
            error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<bool>> putFeedback(String answerId) {
    return http
        .put(api + '/answer/up/' + answerId, headers: headers())
        .then((data) {
      if (data.statusCode == 200) {
        //returns json object
        final jsonData = json.decode(data.body);
        final jsonN = jsonData['n'];
        final jsonNModified = jsonData['nModified'];
        final jsonOk = jsonData['ok'];
        if (jsonOk == 1) {
          return APIResponse<bool>(data: true);
        } else if (jsonNModified < 1) {
          return APIResponse<bool>(
              error: true, errorMessage: '0 answers has been modified');
        } else if (jsonN < 1) {
          return APIResponse<bool>(
              error: true, errorMessage: 'No answer was a match');
        }
        return APIResponse<bool>(error: true, errorMessage: 'An error occured');
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    }).catchError((_) =>
            APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<UserModel>> postUser(String email, String password) {
    print("creating user");
    final String body = json.encode({'email': email, 'password': password});
    return http
        .post(api + '/users', headers: headers(), body: body)
        .then((data) {
      if (data.statusCode == 200) {
        final responseBody = json.decode(data.body);
        final responseEmail = responseBody['email'];
        final responseHeaders = data.headers;
        final token = responseHeaders['x-auth-token'];
        return APIResponse<UserModel>(
          data: UserModel(
            responseEmail,
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
          error: true, errorMessage: 'Create User failed'),
    );
  }

  Future<APIResponse<UserModel>> loginUser(String email, String password) {
    final String body = json.encode({'email': email, 'password': password});
    return http
        .post(api + '/auth', headers: headers(), body: body)
        .then((data) {
      if (data.statusCode == 200) {
        final responseHeaders = data.headers;
        final token = responseHeaders['x-auth-token'];
        return APIResponse<UserModel>(
          data: UserModel(
            email,
            token,
          ),
          statusCode: data.statusCode,
        );
      } else {
        return APIResponse<UserModel>(
          error: true,
          errorMessage: data.body,
          statusCode: data.statusCode,
        );
      }
    }).catchError((_) =>
            APIResponse<UserModel>(error: true, errorMessage: 'Login failed'));
  }

  List<RoomModel> _extractRooms(dynamic responseBuilding) {
    List<RoomModel> rooms = [];
    for (int j = 0; j < responseBuilding['rooms'].length; j++) {
      dynamic responseRoom = responseBuilding['rooms'][j];
      String roomName = responseRoom['name'];
      String roomId = responseRoom['_id'];
      rooms.add(RoomModel(roomId, roomName));
    }
    return rooms;
  }

  Future<APIResponse<List<BuildingModel>>> getBuildingsWithAdminRights(
      String token) {
    return http
        .get(api + '/buildings?admin=me', headers: headers(token: token))
        .then((data) {
      if (data.statusCode == 200) {
        final responseBody = json.decode(data.body);
        List<BuildingModel> buildings = [];
        for (int i = 0; i < responseBody.length; i++) {
          dynamic responseBuilding = responseBody[i];
          String buildingName = responseBuilding['name'];
          String buildingId = responseBuilding['_id'];
          List<RoomModel> rooms = _extractRooms(responseBuilding);
          buildings.add(BuildingModel(buildingId, buildingName, rooms));
        }
        return APIResponse<List<BuildingModel>>(
            data: buildings, statusCode: 200);
      } else {
        final errorMessage = getErrorMessage(data);
        return APIResponse<List<BuildingModel>>(
            error: true,
            errorMessage: errorMessage,
            statusCode: data.statusCode);
      }
    }).catchError((_) => APIResponse<List<BuildingModel>>(
            error: true, errorMessage: 'Get Buildings failed'));
  }

  Future<APIResponse<List<Beacon>>> getBeaconsOfBuilding(
    String token,
    BuildingModel building,
  ) {
    return http
        .get(api + '/beacons?building=' + building.id,
            headers: headers(token: token))
        .then((data) {
      if (data.statusCode == 200) {
        List<Beacon> beacons = [];
        final responseBody = json.decode(data.body);
        for (int i = 0; i < responseBody.length; i++) {
          String id = responseBody[i]['_id'];
          String name = responseBody[i]['name'];
          String uuid = responseBody[i]['uuid'];
          Beacon beacon = Beacon(id, name, building, uuid);
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

  Future<APIResponse<BuildingModel>> getBuilding(
    String token,
    String buildingId,
  ) {
    return http
        .get(api + '/buildings/' + buildingId, headers: headers(token: token))
        .then((data) {
      if (data.statusCode == 200) {
        dynamic resultBody = json.decode(data.body);
        List<RoomModel> rooms = _extractRooms(resultBody);
        BuildingModel building = BuildingModel(
          resultBody['_id'],
          resultBody['name'],
          rooms,
        );
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

  Future<APIResponse<RoomModel>> addRoom(
    String token,
    String roomName,
    BuildingModel building,
  ) {
    final String body =
        json.encode({'name': roomName, 'buildingId': building.id});
    return http
        .post(api + '/rooms', headers: headers(token: token), body: body)
        .then((roomData) {
      if (roomData.statusCode == 200) {
        dynamic resultBody = json.decode(roomData.body);
        RoomModel room = RoomModel(
          resultBody['_id'],
          resultBody['name'],
        );
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
        .post(api + '/signalMaps',
            headers: headers(token: token), body: signalBody)
        .then((signalMapData) {
      if (signalMapData.statusCode == 200) {
        return APIResponse<String>(data: "Add room complete");
      } else {
        return APIResponse<String>(
            error: true, errorMessage: signalMapData.body ?? "");
      }
    }).catchError((e) {
      return APIResponse<String>(
          error: true, errorMessage: "Add signal map failed");
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
        .post(api + '/signalMaps',
            headers: headers(token: token), body: signalBody)
        .then((data) {
      if (data.statusCode == 200) {
        dynamic responseBody = json.decode(data.body);
        RoomModel room = RoomModel(
          responseBody['room']['_id'] ?? "error",
          responseBody['room']['name'] ?? "error",
        );
        return APIResponse<RoomModel>(data: room);
      } else {
        return APIResponse<RoomModel>(
            error: true, errorMessage: data.body ?? "");
      }
    }).catchError((e) => APIResponse<RoomModel>(
            error: true, errorMessage: e.toString()));
  }

  Future<APIResponse<bool>> addBeacon(
    String token,
    Tuple2<String,String> beacon,
    BuildingModel building,
  ) {
    final String body =
        json.encode({'buildingId': building.id, 'name': beacon.item1, 'uuid': beacon.item2});
    return http
        .post(api + '/beacons', headers: headers(token: token), body: body)
        .then((data) {
      if (data.statusCode == 200) {
        dynamic responseBody = json.decode(data.body);
        String answer = responseBody['name'];
        if (answer == beacon.item1) {
          return APIResponse<bool>(data: true);
        }
        return APIResponse<bool>(
            error: true, errorMessage: "Adding beacon failed");
      } else {
        return APIResponse<bool>(
            error: true, errorMessage: "Adding beacon failed");
      }
    }).catchError((e) {
      return APIResponse<bool>(
          error: true, errorMessage: "Adding beacon failed");
    });
  }

  Future<APIResponse<Question>> addQuestion(
    String token,
    List<RoomModel> rooms,
    String value,
    List<AnswerOption> answerOptions,
  ) {
    final String body =
        json.encode({'rooms': rooms, 'value': value, 'answerOptions': answerOptions});
    return http
        .post(api + '/questions', headers: headers(token: token), body: body)
        .then((questionData) {
      if (questionData.statusCode == 200) {
        dynamic resultBody = json.decode(questionData.body);
        Question question = Question(
          resultBody['_id'],
          resultBody['rooms'],
          resultBody['value'],
          resultBody['isActive'],
          resultBody['answerOptions'],
        );
        return APIResponse<Question>(data: question);
      } else {
        return APIResponse<Question>(
            error: true, errorMessage: questionData.body ?? "");
      }
    }).catchError((e) {
      return APIResponse<Question>(
          error: true, errorMessage: "Adding question failed");
    });
  }

/*   Future<APIResponse<BuildingModel>> makeUserAdmin(
    String token,
    String userId,
    BuildingModel building,
  ) {
    final String body =
        json.encode({'userId': userId, 'buildingId': building.id});
    return http
        .patch(api + '/users/makeBuildingAdmin', headers: headers(token: token), body: body)
        .then((adminData) {
      if (adminData.statusCode == 200) {
        dynamic resultBody = json.decode(adminData.body);
        UserModel userModel = UserModel(
          resultBody['userId'],
          resultBody['bulding'],
        );
        return APIResponse<Void>(data: userModel);
      } else {
        return APIResponse<Void>(
            error: true, errorMessage: adminData.body ?? "");
      }
    }).catchError((e) {
      return APIResponse<Void>(
          error: true, errorMessage: "Making user admin failed");
    });
  }  */
}
