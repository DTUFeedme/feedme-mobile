part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> deleteBeaconRequest(
  BuildContext context,
  String beaconId,
) {
  print("deleting beacon");
  return RestService.requestServer(
    context,
    fromJson: (_) {
      return "Deleted beacon with id ${beaconId}";
    },
    requestType: RequestType.DELETE,
    route: '/beacons/' + beaconId,
  );
}
