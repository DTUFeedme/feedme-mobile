part of 'package:climify/services/rest_service.dart';

Future<APIResponse<bool>> patchUserAdminRequest(
  String userId,
  BuildingModel building,
) {
  final String body =
      json.encode({'userId': userId, 'buildingId': building.id});
  return RestService.requestServer(
    body: body,
    fromJson: (_) => true,
    requestType: RequestType.PATCH,
    route: '/users/makeBuildingAdmin',
  );
}
