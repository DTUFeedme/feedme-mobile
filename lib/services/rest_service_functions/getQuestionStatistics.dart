part of 'package:climify/services/rest_service.dart';

Future<APIResponse<QuestionStatisticsModel>> getQuestionStatisticsRequest(
  BuildContext context,
  FeedbackQuestion question,
  String t,
) {
  return RestService.requestServer(
    context,
    fromJson: (json) => QuestionStatisticsModel.fromJson(question, json),
    requestType: RequestType.GET,
    route: '/feedback/questionStatistics/' +
        question.id +
        (t == null ? '' : '?t=' + t),
  );
}