part of 'package:climify/services/rest_service.dart';

Future<APIResponse<List<FeedbackQuestion>>> getAllQuestionsByRoomRequest(
  String roomId, {
  String t,
}) {
  return RestService.requestServer(
    fromJson: (json) {
      List<FeedbackQuestion> feedbackList = [];
      List<dynamic> jsonData = json;
      jsonData.forEach(
          (element) => feedbackList.add(FeedbackQuestion.fromJson(element)));
      return feedbackList;
    },
    additionalHeaderParameters: {'roomId': roomId},
    requestType: RequestType.GET,
    route: '/questions',
  );
}