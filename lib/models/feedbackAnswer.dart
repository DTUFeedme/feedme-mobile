class FeedbackAnswer {
  String id;
  String value;
  int timesAnswered;

  FeedbackAnswer(
    this.id,
    this.value,
    this.timesAnswered,
  );

  factory FeedbackAnswer.fromJson(json) {
    return FeedbackAnswer(
      json['answer']['_id'],
      json['answer']['value'],
      json['timesAnswered'],
    );
  }

  Map<String, dynamic> toJson() => {
        'answer': {
          '_id': this.id,
          'value': this.value,
        },
        'timesAnswered': this.timesAnswered,
      };
}
