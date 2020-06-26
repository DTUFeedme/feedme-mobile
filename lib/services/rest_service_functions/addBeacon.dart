part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> addBeaconRequest(
  BuildContext context,
  Tuple2<String, String> beacon,
  BuildingModel building,
) {
  final String body = json.encode(
      {'buildingId': building.id, 'name': beacon.item1, 'uuid': beacon.item2});
  return RestService.requestServer<String>(
    context,
    (_) => "Success",
    body: body,
    requestType: RequestType.POST,
    route: '/beacons',
  );
}
