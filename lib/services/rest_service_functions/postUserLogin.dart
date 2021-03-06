part of 'package:climify/services/rest_service.dart';

Future<APIResponse<UserModel>> loginUserRequest(
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
        email,
        header['x-auth-token'],
        refreshToken: json["refreshToken"],
      );
    },
    body: body,
    requestType: RequestType.POST,
    route: '/auth',
    skipRefreshValidation: true,
  );
}
