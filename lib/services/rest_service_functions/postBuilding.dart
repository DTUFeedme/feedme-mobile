part of 'package:climify/services/rest_service.dart';

Future<APIResponse<BuildingModel>> postBuildingRequest(
  BuildContext context,
  String buildingName,
) {
  final String body = json.encode({
    'name': buildingName,
  });
  return RestService.requestServer<BuildingModel>(
    context,
    fromJson: (json) => BuildingModel.fromJson(json),
    body: body,
    requestType: RequestType.POST,
    route: '/buildings',
  );
}
