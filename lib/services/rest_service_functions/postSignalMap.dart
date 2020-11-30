part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> postSignalMapRequest(
  SignalMap signalMap,
  String roomId,
) {
  final String body = json.encode({
    'beacons': signalMap.avgBeaconSignals,
    'roomId': roomId,
  });
  return RestService.requestServer(
    fromJson: (_) {
      return "Scan added";
    },
    body: body,
    requestType: RequestType.POST,
    route: '/signalMaps',
  );
}