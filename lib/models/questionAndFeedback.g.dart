// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionAndFeedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionAndFeedback _$QuestionAndFeedbackFromJson(Map<String, dynamic> json) {
  return QuestionAndFeedback(
    json['_id'] as String,
    json['user'] as String,
    json['room'] as String,
    json['answer'] == null ? null : AnswerOption.fromJson(json['answer']),
    json['question'] == null
        ? null
        : FeedbackQuestion.fromJson(json['question']),
    json['createdAt'] as String,
    json['updatedAt'] as String,
    json['__v'] as int,
  );
}

Map<String, dynamic> _$QuestionAndFeedbackToJson(
        QuestionAndFeedback instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'room': instance.room,
      'answer': instance.answer?.toJson(),
      'question': instance.question?.toJson(),
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
    };
