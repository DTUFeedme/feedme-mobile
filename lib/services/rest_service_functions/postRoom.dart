part of 'package:climify/services/rest_service.dart';

Future<APIResponse<RoomModel>> postRoomRequest(
  String roomName,
  BuildingModel building,
) {
  final String body = json.encode({
    'name': roomName,
    'buildingId': building.id,
  });
  return RestService.requestServer(
    fromJson: (json) => RoomModel.fromJson(json),
    body: body,
    requestType: RequestType.POST,
    route: '/rooms',
  );
}