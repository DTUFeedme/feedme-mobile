import 'package:climify/models/answerOption.dart';

class FeedbackQuestion {
  String id;
  String value;
  List<String> roomIds;
  bool isActive;
  List<AnswerOption> answerOptions;
  List<String> usersAnswered;

  FeedbackQuestion(
    this.id,
    this.value,
    this.roomIds,
    this.isActive,
    this.answerOptions,
    this.usersAnswered,
  );

  factory FeedbackQuestion.fromJson(json) {
    var answerOptionsJson = json['answerOptions'];
    List<AnswerOption> answerOptions = [];
    answerOptionsJson.forEach((element) {
      answerOptions.add(AnswerOption.fromJson(element));
    });
    return FeedbackQuestion(
      json['_id'],
      json['value'],
      json['rooms'].cast<String>().toList(),
      json['isActive'],
      answerOptions,
      json['usersAnswered'].cast<String>().toList(),
    );
  }
}
