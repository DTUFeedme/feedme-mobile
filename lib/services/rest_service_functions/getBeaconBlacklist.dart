part of 'package:climify/services/rest_service.dart';

Future<APIResponse<List<String>>> getBeaconBlacklistRequest(
  String buildingId,
) {
  return RestService.requestServer(
    fromJson: (json) {
      List<String> blacklist = [];
      List<dynamic> jsonData = json;
      jsonData.forEach((element) {
        blacklist.add(element.toString());
      });
      return blacklist;
    },
    requestType: RequestType.GET,
    route: '/buildings/' + buildingId + '/blacklistedDevices',
  );
}
