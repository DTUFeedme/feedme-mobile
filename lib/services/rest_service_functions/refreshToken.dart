part of 'package:climify/services/rest_service.dart';

Future<APIResponse<UserModel>> refreshTokenRequest(
    BuildContext context, String refreshToken) {
  final String body = json.encode({
    'refreshToken': refreshToken,
  });

  return RestService.requestServer(
    context,
    // fromJsonAndHeader: (_, header) => UserModel("", header['x-auth-token']),
    fromJsonAndHeader: (json, header) {
      print(header['x-auth-token']);
      return UserModel("", header['x-auth-token'],
          refreshToken: json["refreshToken"]);
    },
    body: body,
    requestType: RequestType.POST,
    route: '/auth/refresh',
  );
}
