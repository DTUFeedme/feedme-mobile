part of 'package:climify/services/rest_service.dart';

Future<APIResponse<bool>> patchAddBlacklistBeaconRequest(
  String buildingId,
  String beaconName,
) {
  final String body = json.encode({'deviceName': beaconName});
  return RestService.requestServer(
    body: body,
    fromJson: (_) => true,
    requestType: RequestType.PATCH,
    route: '/buildings/' + buildingId + '/addBlacklistedDevice',
  );
}
