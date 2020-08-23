part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> postBeaconRequest(
  BuildContext context,
  String beaconName,
  BuildingModel building,
) {
  final String body = json.encode({
    'buildingId': building.id,
    'name': beaconName,
  });
  return RestService.requestServer<String>(
    context,
    fromJson: (_) => "Success",
    body: body,
    requestType: RequestType.POST,
    route: '/beacons',
  );
}
