part of 'package:climify/services/rest_service.dart';

Future<APIResponse<UserModel>> postUnauthorizedUserRequest(
  BuildContext context,
) {
  return RestService.requestServer(
    context,
    // fromJsonAndHeader: (_, header) => UserModel("", header['x-auth-token']),
    fromJsonAndHeader: (_, header) {
      print(header['x-auth-token']);
      return UserModel("", header['x-auth-token']);
    },
    requestType: RequestType.POST,
    route: '/users',
  );
}
