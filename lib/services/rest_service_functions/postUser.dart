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

// Future<APIResponse<UserModel>> postUser(String email, String password) {
//   final String body = json.encode({'email': email, 'password': password});
//   return http
//       .post(api + '/users',
//           headers: headers(context, noToken: true), body: body)
//       .then((data) {
//     if (data.statusCode == 200) {
//       final responseBody = json.decode(data.body);
//       final responseEmail = responseBody['email'];
//       final responseHeaders = data.headers;
//       final token = responseHeaders['x-auth-token'];
//       return APIResponse<UserModel>(
//         data: UserModel(
//           responseEmail,
//           token,
//         ),
//       );
//     } else {
//       return APIResponse<UserModel>(
//         error: true,
//         errorMessage: data.body,
//       );
//     }
//   }).catchError(
//     (_) =>
//         APIResponse<UserModel>(error: true, errorMessage: 'Create User failed'),
//   );
// }
