part of 'package:climify/services/rest_service.dart';

Future<APIResponse<List<BuildingModel>>> getBuildingsWithAdminRightsRequest(
) {
  return RestService.requestServer(
    fromJson: (json) {
      List<BuildingModel> buildingList = [];
      for (int i = 0; i < json.length; i++) {
        dynamic responseBuilding = json[i];
        buildingList.add(BuildingModel.fromJson(responseBuilding));
      }
      return buildingList;
    },
    requestType: RequestType.GET,
    route: '/buildings?admin=me',
  );
}
