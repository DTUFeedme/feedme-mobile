part of 'package:climify/services/rest_service.dart';

Future<APIResponse<BuildingModel>> getBuildingRequest(
  BuildContext context,
  String buildingId,
) {
  return RestService.requestServer(
    context,
    fromJson: (json) => BuildingModel.fromJson(json),
    requestType: RequestType.GET,
    route: '/buildings/' + buildingId,
  );
}
