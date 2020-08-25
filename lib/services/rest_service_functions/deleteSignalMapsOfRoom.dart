part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> deleteSignalMapsOfRoomRequest(
  String roomId,
) {
  print("deleting scans");
  return RestService.requestServer(
    fromJson: (_) {
      return "Deleted signal maps of room";
    },
    requestType: RequestType.DELETE,
    route: '/signalMaps/room/' + roomId,
  );
}