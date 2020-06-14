import 'package:json_annotation/json_annotation.dart';

part 'answerOption.g.dart';

@JsonSerializable()
class AnswerOption {
  @JsonKey(name: "_id")
  String id;
  String value;

  AnswerOption(
    this.id,
    this.value,
  );

  factory AnswerOption.fromJson(json) => _$AnswerOptionFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerOptionToJson(this);
}
