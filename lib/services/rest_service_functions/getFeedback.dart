part of 'package:climify/services/rest_service.dart';

Future<APIResponse<List<QuestionAndFeedback>>> getFeedbackRequest(
  String user,
  String t,
) {
  return RestService.requestServer(
    fromJson: (json) {
      List<QuestionAndFeedback> feedbackList = [];
      if (json == null || json.length < 1) {
        return [];
      }
      for (var e in json) {
        if (e['answer'] != null && e['question'] != null) {
          QuestionAndFeedback qF = QuestionAndFeedback.fromJson(e);
          feedbackList.add(qF);
        }
      }
      return feedbackList;
    },
    requestType: RequestType.GET,
    route: '/feedback?user=' + user + '&t=' + t,
  );
}