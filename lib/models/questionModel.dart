import 'package:climify/models/answerOption.dart';
import 'package:climify/models/roomModel.dart';

class Question {
  List<RoomModel> rooms;
  String value;
  List<AnswerOption> answerOptions;

  Question(
    this.rooms,
    this.value,
    this.answerOptions,
  );
}
