part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> deleteBuildingRequest(
  BuildingModel building,
) {
  return RestService.requestServer(
    fromJson: (_) {
      return "Deleted building ${building.name}";
    },
    requestType: RequestType.DELETE,
    route: '/buildings/' + building.id,
  );
}
