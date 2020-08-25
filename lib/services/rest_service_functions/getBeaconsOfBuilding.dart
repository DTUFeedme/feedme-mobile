part of 'package:climify/services/rest_service.dart';

Future<APIResponse<List<Beacon>>> getBeaconsOfBuildingRequest(
  BuildingModel building,
) {
  return RestService.requestServer(
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