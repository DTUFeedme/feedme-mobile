part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> deleteBuildingRequest(
  BuildContext context,
  BuildingModel building,
) {
  return RestService.requestServer(
    context,
    fromJson: (_) {
      return "Deleted building ${building.name}";
    },
    requestType: RequestType.DELETE,
    route: '/buildings/' + building.id,
  );
}
