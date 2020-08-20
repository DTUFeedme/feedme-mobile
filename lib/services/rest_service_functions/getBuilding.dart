part of 'package:climify/services/rest_service.dart';

Future<APIResponse<BuildingModel>> getBuildingRequest(
  String buildingId,
) {
  return RestService.requestServer(
    fromJson: (json) => BuildingModel.fromJson(json),
    requestType: RequestType.GET,
    route: '/buildings/' + buildingId,
  );
}
