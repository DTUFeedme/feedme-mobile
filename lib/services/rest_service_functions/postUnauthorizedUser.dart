part of 'package:climify/services/rest_service.dart';

Future<APIResponse<Tuple2<String, String>>> postUnauthorizedUserRequest() {
  return RestService.requestServer(
    // fromJsonAndHeader: (_, header) => UserModel("", header['x-auth-token']),
    fromJsonAndHeader: (json, header) {
      print(header['x-auth-token']);
      return Tuple2(header['x-auth-token'], json["refreshToken"]);
    },
    requestType: RequestType.POST,
    route: '/users',
    skipRefreshValidation: true,
  );
}
