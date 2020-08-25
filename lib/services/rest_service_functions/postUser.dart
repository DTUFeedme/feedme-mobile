part of 'package:climify/services/rest_service.dart';

Future<APIResponse<UserModel>> postUserRequest(
  String email,
  String password,
) {
  final String body = json.encode({
    'email': email,
    'password': password,
  });
  return RestService.requestServer(
    fromJsonAndHeader: (json, header) {
      return UserModel(
        json['email'],
        header['x-auth-token'],
        refreshToken: json["refreshToken"]
      );
    },
    body: body,
    requestType: RequestType.POST,
    route: '/users',
    skipRefreshValidation: true,
  );
}