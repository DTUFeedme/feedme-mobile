part of 'package:climify/services/rest_service.dart';

Future<APIResponse<UserModel>> loginUserRequest(
  BuildContext context,
  String email,
  String password,
) {
  final String body = json.encode({
    'email': email,
    'password': password,
  });
  print("logging in new");
  return RestService.requestServer(
    context,
    fromJsonAndHeader: (json, header) {
      return UserModel(
        email,
        header['x-auth-token'],
      );
    },
    body: body,
    requestType: RequestType.POST,
    route: '/auth',
  );
}
