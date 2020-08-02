part of 'package:climify/services/rest_service.dart';

Future<APIResponse<RoomModel>> getRoomFromSignalMapRequest(
  BuildContext context,
  SignalMap signalMap,
) {
  final String body = json.encode({
    'beacons': signalMap.beacons,
    'buildingId': signalMap.buildingId,
  });
  return RestService.requestServer(
    context,
    body: body,
    fromJson: (json) => RoomModel.fromJson(json['room']),
    // This functions as a post request, but the intent is to GET the room matching the signal map
    requestType: RequestType.POST,
    route: '/signalMaps/',
  );
}