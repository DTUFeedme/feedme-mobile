class AnswerOption {
  String id;
  String value;

  AnswerOption(
    this.id,
    this.value,
  );

  factory AnswerOption.fromJson(json) {
    return AnswerOption(
      json['_id'],
      json['value'],
    );
  }
}
