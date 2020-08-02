part of 'package:climify/services/rest_service.dart';

Future<APIResponse<UserModel>> postUserRequest(
  BuildContext context,
  String email,
  String password,
) {
  final String body = json.encode({
    'email': email,
    'password': password,
  });
  return RestService.requestServer(
    context,
    fromJsonAndHeader: (json, header) {
      return UserModel(
        json['email'],
        header['x-auth-token'],
      );
    },
    body: body,
    requestType: RequestType.POST,
    route: '/users',
  );
}