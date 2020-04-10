import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:climify/models/feedbackQuestion2.dart';
import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';

class RestService {
  static const API = 'http://climify-spe.compute.dtu.dk:8080/api-dev';
  static const headers = {
    'Content-Type': 'application/json'
  };

      Future<APIResponse<FeedbackQuestion>> getQuestionByRoom(String room) {
      return http.get(API + '/question/room/' + room, headers: headers).then((data) {
      if (data.statusCode == 200) {
        //returns json object
        //Kan man være sikker på at denne liste altid er en lang?
        final jsonData = json.decode(data.body);
        final FeedbackQuestion feedbackQuestion = null;
        for (var e in jsonData) {
          feedbackQuestion.answerOptions = e['answerOptions'];
          feedbackQuestion.sId = e['_id'];
          feedbackQuestion.question = e['question'];
          feedbackQuestion.room = e['room'];
          feedbackQuestion.iV = int.parse(e['__v']);
        }
        if (feedbackQuestion != null) {
          return APIResponse<FeedbackQuestion>(data: feedbackQuestion);
        } else {
          return APIResponse<FeedbackQuestion>(error: true, errorMessage: 'No questions found');
        }
      }
      return APIResponse<FeedbackQuestion>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<FeedbackQuestion>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<List<AnswerOption>>> getAnswerOptionsByRoom(String room) {
      return http.get(API + '/answer/fromQuestion/' + room, headers: headers).then((data) {
      if (data.statusCode == 200) {
        //returns json object
        final jsonData = json.decode(data.body);
        final answerOptionList = <AnswerOption>[];
        for (var e in jsonData) {
          final answerOption = AnswerOption(
            timesAnswered: e['timesAnswered'],
            sId: e['_id'],
            answer: e['answer'],
            iV: e['__v']
          );
          answerOptionList.add(answerOption);
        }
        if (answerOptionList != null) {
          return APIResponse<List<AnswerOption>>(data: answerOptionList);
        } else {
          return APIResponse<List<AnswerOption>>(error: true, errorMessage: 'No answers were found');
        }
      }
      return APIResponse<List<AnswerOption>>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<List<AnswerOption>>(error: true, errorMessage: 'An error occured'));
  }

    Future<APIResponse<bool>> putFeedback(String answerId) {
    return http.put(API + '/answer/up/' + answerId, headers: headers).then((data) {
      if (data.statusCode == 200) {
        //returns json object
        final jsonData = json.decode(data.body);
        final jsonN = jsonData['n'];
        final jsonNModified = jsonData['nModified'];
        final jsonOk = jsonData['ok'];
        if (jsonOk == 1) {
          return APIResponse<bool>(data: true);
        } else if (jsonNModified < 1) {
          return APIResponse<bool>(error: true, errorMessage: '0 answers has been modified');
        } else if (jsonN < 1) {
          return APIResponse<bool>(error: true, errorMessage: 'No answer was a match');
        }
        return APIResponse<bool>(error: true, errorMessage: 'An error occured');
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    })
    .catchError((_) => APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }
}