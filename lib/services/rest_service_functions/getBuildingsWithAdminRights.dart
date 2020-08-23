part of 'package:climify/services/rest_service.dart';

Future<APIResponse<List<BuildingModel>>> getBuildingsWithAdminRightsRequest(
  BuildContext context,
) {
  return RestService.requestServer(
    context,
    fromJson: (json) {
      List<BuildingModel> buildingList = [];
      for (int i = 0; i < json.length; i++) {
        dynamic responseBuilding = json[i];
        print("responseBuldiigni");
        print(responseBuilding);

        buildingList.add(BuildingModel.fromJson(responseBuilding));
        print(responseBuilding.toString());
      }
      return buildingList;
    },
    requestType: RequestType.GET,
    route: '/buildings?admin=me',
  );
}