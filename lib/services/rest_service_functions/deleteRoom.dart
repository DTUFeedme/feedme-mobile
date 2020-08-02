part of 'package:climify/services/rest_service.dart';

Future<APIResponse<String>> deleteRoomRequest(
  BuildContext context,
  String roomId,
) {
  return RestService.requestServer(
    context,
    fromJson: (_) {
      return "Deleted room";
    },
    requestType: RequestType.DELETE,
    route: '/rooms/' + roomId,
  );
}