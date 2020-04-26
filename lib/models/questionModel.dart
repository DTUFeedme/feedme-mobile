import 'package:climify/models/answerOption.dart';
import 'package:climify/models/roomModel.dart';

class Question {
  String id;
  RoomModel rooms;
  String value;
  bool isActive;
  List<AnswerOption> answerOptions;

  Question(
    this.id,
    this.rooms,
    this.value,
    this.isActive,
    this.answerOptions,
  );
}
