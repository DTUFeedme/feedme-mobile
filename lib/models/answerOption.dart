class AnswerOption {
  String id;
  String value;
  int v;

  AnswerOption(
    this.id,
    this.value,
    this.v,
  );

  factory AnswerOption.fromJson(json) {
    return AnswerOption(
      json['_id'],
      json['value'],
      json['__v'],
    );
  }
}
