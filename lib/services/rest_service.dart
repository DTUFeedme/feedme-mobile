import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';

class RestService {
  static const API = 'http://climify-spe.compute.dtu.dk:8080/api-dev';
  static const headers = {
    'Content-Type': 'application/json'
  };

      Future<APIResponse<List<FeedbackQuestion>>> getQuestionByRoom(String room) {
      print(room);
      return http.get(API + '/question/room/' + room, headers: headers).then((data) async {
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
            iV: e['__v']
          );
          print("HejHejHej");
          print(e['answerOptions'].toString());
          answerOptionsId = List.from(e['answerOptions']);
          print("1");
          print(answerOptionsId.toString());
          APIResponse<List<AnswerOption>> temp;
          if (answerOptionsId.length > 0) {
            //temp = await getAnswerOptionsByIdList(answerOptionsId);
          }/*
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
      return APIResponse<List<FeedbackQuestion>>(error: true, errorMessage: 'An error occured1');
    })
    .catchError((_) => APIResponse<List<FeedbackQuestion>>(error: true, errorMessage: 'An error occured2'));
  }

   Future<APIResponse<List<AnswerOption>>> getAnswerOptionsByIdList(List<String> answerIdList) {
      return http.get(API + '/answer/fromQuestion/' + answerIdList.toString(), headers: headers).then((data) {
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
      return APIResponse<List<AnswerOption>>(error: true, errorMessage: 'An error occured3');
    })
    .catchError((_) => APIResponse<List<AnswerOption>>(error: true, errorMessage: 'An error occured4'));
  }


  Future<APIResponse<List<AnswerOption>>> getAnswerOptionsByRoom(String questionId) {
      return http.get(API + '/answer/fromQuestion/' + questionId, headers: headers).then((data) {
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