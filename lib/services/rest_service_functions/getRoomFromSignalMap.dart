part of 'package:climify/services/rest_service.dart';

Future<APIResponse<RoomModel>> getRoomFromSignalMapRequest(
  BuildContext context,
  SignalMap signalMap,
) {
  String body;
  if (signalMap.buildingId != null && signalMap.buildingId.isNotEmpty) {
    body = json.encode({
      'beacons': signalMap.beacons,
      'buildingId': signalMap.buildingId,
    });
  } else {
    body = json.encode({
      'beacons': signalMap.beacons,
    });
  }
  return RestService.requestServer(
    context,
    body: body,
    fromJson: (json) => RoomModel.fromJson(json['room']),
    // This functions as a post request, but the intent is to GET the room matching the signal map
    requestType: RequestType.POST,
    route: '/signalMaps/',
  );
}
