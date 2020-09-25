part of 'package:climify/services/rest_service.dart';

Future<APIResponse<bool>> patchRemoveBlacklistBeaconRequest(
  String buildingId,
  String beaconName,
) {
  return RestService.requestServer(
    fromJson: (_) => true,
    requestType: RequestType.PATCH,
    route: '/buildings/' + buildingId + '/removeBlacklistedDevice/' + beaconName,
  );
}
