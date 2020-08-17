part of 'package:climify/services/rest_service.dart';

Future<APIResponse<Tuple2<String,String>>> updateTokensRequest(
    String authToken, String refreshToken) async {
  final String body = json.encode({
    'refreshToken': refreshToken,
  });

  http.Response response = await http.post(
    RestService.api + "/auth/refresh",
    headers: {
      "x-auth-token": authToken,
      'Content-Type': 'application/json',
    },
    body: body,
  );

  if (response.statusCode == 200) {
    dynamic responseBody = json.decode(response.body);
    print(responseBody);
    String newRefreshToken = responseBody["refreshToken"];
    String newAuthToken = response.headers["x-auth-token"];
    return APIResponse<Tuple2<String,String>>(data: new Tuple2(newAuthToken, newRefreshToken));
  } else {
    print("reason");
    print(response.reasonPhrase);
    return APIResponse<Tuple2<String,String>>(error: true, errorMessage: response.body ?? response.reasonPhrase);
  }


}
