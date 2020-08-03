part of 'package:climify/services/rest_service.dart';

Future<APIResponse<Question>> postQuestionRequest(
  BuildContext context,
  List<String> rooms,
  String value,
  List<String> answerOptions,
) {
  final String body = json.encode({
    'rooms': rooms,
    'value': value,
    'answerOptions': answerOptions,
  });
  return RestService.requestServer(
    context,
    fromJson: (json) => Question.fromJson(json),
    body: body,
    requestType: RequestType.POST,
    route: '/questions',
  );
}