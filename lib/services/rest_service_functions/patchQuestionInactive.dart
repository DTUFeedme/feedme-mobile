part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> patchQuestionInactiveRequest(
  String questionId,
  bool isActive,
) {
  final String body = json.encode({'isActive': isActive});
  return RestService.requestServer(
    body: body,
    fromJson: (_) => "Question active status set",
    requestType: RequestType.PATCH,
    route: '/questions/setActive/' + questionId,
  );
}