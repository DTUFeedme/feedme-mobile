import 'dart:convert';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/models/userModel.dart';
import 'package:http/http.dart' as http;

import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';
import 'package:http/http.dart';

class RestService {
  static const api = 'http://climify-spe.compute.dtu.dk:8080/api-dev';
  static const headers = {'Content-Type': 'application/json'};

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
        .get(api + '/question/room/' + room, headers: headers)
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
            headers: headers)
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
        .get(api + '/answer/fromQuestion/' + questionId, headers: headers)
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
        .put(api + '/answer/up/' + answerId, headers: headers)
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
    final String body = json.encode({'email': email, 'password': password});
    return http.post(api + '/users', headers: headers, body: body).then((data) {
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
        print(data.statusCode);
        final errorMessage = getErrorMessage(data);
        return APIResponse<UserModel>(
          error: true,
          errorMessage: errorMessage,
        );
      }
    }).catchError(
      (_) => APIResponse<UserModel>(
          error: true, errorMessage: 'Create User failed'),
    );
  }

  Future<APIResponse<UserModel>> loginUser(String email, String password) {
    final String body = json.encode({'email': email, 'password': password});
    return http.post(api + '/auth', headers: headers, body: body).then((data) {
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
        final errorMessage = getErrorMessage(data);
        return APIResponse<UserModel>(
            error: true,
            errorMessage: errorMessage,
            statusCode: data.statusCode);
      }
    }).catchError((_) =>
        APIResponse<UserModel>(error: true, errorMessage: 'Login failed'));
  }

  Future<APIResponse<List<BuildingModel>>> getBuildingsWithAdminRights(
      String token) {
    Map<String, String> newHeaders = {};
    newHeaders.addAll(headers);
    newHeaders.addAll({'x-auth-token': token});
    return http
        .get(api + '/buildings?admin=me', headers: newHeaders)
        .then((data) {
      if (data.statusCode == 200) {
        final responseBody = json.decode(data.body);
        List<BuildingModel> buildings = [];
        for (int i = 0; i < responseBody.length; i++) {
          dynamic responseBuilding = responseBody[i];
          String buildingName = responseBuilding['name'];
          String buildingId = responseBuilding['_id'];
          List<RoomModel> rooms = [];
          for (int j = 0; j < responseBuilding['rooms'].length; j++) {
            dynamic responseRoom = responseBuilding['rooms'][j];
            String roomName = responseRoom['name'];
            String roomId = responseRoom['_id'];
            rooms.add(RoomModel(roomId, roomName));
          }
          buildings.add(BuildingModel(buildingId, buildingName, rooms));
        }
        return APIResponse<List<BuildingModel>>(data: buildings, statusCode: 200);
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
}
