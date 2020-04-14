import 'package:climify/models/answerOption.dart';

class FeedbackQuestion {
  //List<String> answerOptions;
  List<AnswerOption> answerOptions;
  String sId;
  String question;
  String room;
  int iV;

  FeedbackQuestion(
      {this.answerOptions, this.sId, this.question, this.room, this.iV});

  FeedbackQuestion.fromJson(Map<String, dynamic> json) {
    //answerOptions = json['answerOptions'].cast<String>();
    sId = json['_id'];
    question = json['question'];
    room = json['room'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['answerOptions'] = this.answerOptions;
    data['_id'] = this.sId;
    data['question'] = this.question;
    data['room'] = this.room;
    data['__v'] = this.iV;
    return data;
  }
}