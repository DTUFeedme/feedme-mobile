part of 'package:climify/services/rest_service.dart';

Future<APIResponse<List<Beacon>>> getBeaconsOfBuildingRequest(
  BuildContext context,
  BuildingModel building,
) {
  return RestService.requestServer(
    context,
    fromJson: (json) {
      List<Beacon> beacons = [];
      for (int i = 0; i < json.length; i++) {
        Map<String, dynamic> jsonData = json[i];
        Beacon beacon = Beacon.fromJson(jsonData);
        beacons.add(beacon);
      }
      return beacons;
    },
    requestType: RequestType.GET,
    route: '/beacons?building=' + building.id,
  );
}