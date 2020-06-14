import 'package:json_annotation/json_annotation.dart';
import 'package:climify/models/answerOption.dart';

part 'feedbackQuestion.g.dart';

@JsonSerializable(explicitToJson: true)
class FeedbackQuestion {
  @JsonKey(name: '_id')
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

  factory FeedbackQuestion.fromJson(json) => _$FeedbackQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackQuestionToJson(this);
}
