part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> getUserIdFromEmailRequest(
  BuildContext context,
  String email,
) {
  print("getting email");
  return RestService.requestServer(
    context,
    fromJson: (json) => json,
    requestType: RequestType.GET,
    route: '/users/getUserIdFromEmail/' + email,
  );
}