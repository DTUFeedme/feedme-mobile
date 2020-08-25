part of 'package:climify/services/rest_service.dart';

Future<APIResponse<bool>> postFeedbackRequest(
  FeedbackQuestion question,
  int choosenOption,
  RoomModel room,
) {
  final String body = json.encode({
    'roomId': room.id,
    'answerId': question.answerOptions[choosenOption].id,
    'questionId': question.id
  });
  return RestService.requestServer(
    fromJson: (json) {
      if (json != null) {
        return true;
      } else {
        return false;
      }
    },
    body: body,
    requestType: RequestType.POST,
    route: '/feedback',
  );
}
