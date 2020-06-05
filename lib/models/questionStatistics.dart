import 'package:climify/models/feedbackAnswer.dart';
import 'package:climify/models/feedbackQuestion.dart';

class QuestionStatisticsModel {
  FeedbackQuestion question;
  List<FeedbackAnswer> answers;

  QuestionStatisticsModel(
    this.question,
    this.answers,
  );

  factory QuestionStatisticsModel.fromJson(FeedbackQuestion question, json) {
    List<FeedbackAnswer> answerOptions = [];
    json.forEach((element) {
      answerOptions.add(FeedbackAnswer.fromJson(element));
    });
    return QuestionStatisticsModel(
      question,
      answerOptions,
    );
  }
}
