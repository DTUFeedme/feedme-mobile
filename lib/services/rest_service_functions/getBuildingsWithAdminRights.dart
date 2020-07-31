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
        buildingList.add(BuildingModel.fromJson(responseBuilding));
      }
      return buildingList;
    },
    requestType: RequestType.GET,
    route: '/buildings?admin=me',
  );
}

// Future<APIResponse<List<BuildingModel>>> getBuildingsWithAdminRights(
//     String token) {
//   return http
//       .get(api + '/buildings?admin=me', headers: headers(context))
//       .then((data) {
//     if (data.statusCode == 200) {
//       final responseBody = json.decode(data.body);
//       List<BuildingModel> buildings = [];
//       for (int i = 0; i < responseBody.length; i++) {
//         dynamic responseBuilding = responseBody[i];
//         buildings.add(BuildingModel.fromJson(responseBuilding));
//       }
//       return APIResponse<List<BuildingModel>>(data: buildings, statusCode: 200);
//     } else {
//       final errorMessage = "";
//       return APIResponse<List<BuildingModel>>(
//           error: true, errorMessage: errorMessage, statusCode: data.statusCode);
//     }
//   }).catchError((_) => APIResponse<List<BuildingModel>>(
//           error: true, errorMessage: 'Get Buildings failed'));
// }
