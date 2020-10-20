part of 'package:climify/services/rest_service.dart';

Future<APIResponse<bool>> patchUserAdminRequest(
  String email,
  BuildingModel building,
) {
  final String body =
      json.encode({'email': email, 'buildingId': building.id});
  return RestService.requestServer(
    body: body,
    fromJson: (_) => true,
    requestType: RequestType.PATCH,
    route: '/users/makeBuildingAdmin',
  );
}
