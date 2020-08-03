import 'package:climify/models/answerOption.dart';
import 'package:climify/models/feedbackQuestion.dart';
import 'package:json_annotation/json_annotation.dart';

part 'questionAndFeedback.g.dart';

@JsonSerializable(explicitToJson: true)
class QuestionAndFeedback {
  @JsonKey(name: '_id')
  String id;
  String user;
  String room;
  AnswerOption answer;
  FeedbackQuestion question;
  String createdAt;
  String updatedAt;
  @JsonKey(name: '__v')
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

  factory QuestionAndFeedback.fromJson(json) =>
      _$QuestionAndFeedbackFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionAndFeedbackToJson(this);
}
