import 'package:climify/models/answerOption.dart';
import 'package:climify/models/feedbackQuestion.dart';

class QuestionAndFeedback {
  String id;
  String user;
  String room;
  AnswerOption answer;
  FeedbackQuestion question;
  String createdAt;
  String updatedAt;
  int v;

  QuestionAndFeedback(
    this.id,
    this.user,
    this.room,
    this.answer,
    this.question,
    this.createdAt,
    this.updatedAt,
    this.v,
  );

}