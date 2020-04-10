class AnswerOption {
  int timesAnswered;
  String sId;
  String answer;
  int iV;

  AnswerOption({this.timesAnswered, this.sId, this.answer, this.iV});

  AnswerOption.fromJson(Map<String, dynamic> json) {
    timesAnswered = json['timesAnswered'];
    sId = json['_id'];
    answer = json['answer'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timesAnswered'] = this.timesAnswered;
    data['_id'] = this.sId;
    data['answer'] = this.answer;
    data['__v'] = this.iV;
    return data;
  }
}