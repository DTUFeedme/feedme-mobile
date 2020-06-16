import 'package:json_annotation/json_annotation.dart';

part 'answerOption.g.dart';

@JsonSerializable()
class AnswerOption {
  @JsonKey(name: "_id")
  String id;
  String value;
  int v;

  AnswerOption(
    this.id,
    this.value,
    this.v,
  );

  factory AnswerOption.fromJson(json) => _$AnswerOptionFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerOptionToJson(this);
}
