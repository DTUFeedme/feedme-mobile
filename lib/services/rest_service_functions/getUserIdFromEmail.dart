part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> getUserIdFromEmailRequest(
  String email,
) {
  return RestService.requestServer(
    fromJson: (json) => json,
    requestType: RequestType.GET,
    route: '/users/getUserIdFromEmail/' + email,
  );
}