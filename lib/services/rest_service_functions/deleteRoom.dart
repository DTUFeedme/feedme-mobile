part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> deleteRoomRequest(
  String roomId,
) {
  return RestService.requestServer(
    fromJson: (_) {
      return "Deleted room";
    },
    requestType: RequestType.DELETE,
    route: '/rooms/' + roomId,
  );
}