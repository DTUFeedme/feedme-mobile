import 'package:climify/models/roomModel.dart';

String getSubtitle(
  bool gettingRoom,
  RoomModel room,
) {
  return gettingRoom
      ? "Room: scanning..."
      : room == null
          ? "Failed scanning room, tap to retry"
          : "Room: ${room.name} " +
              (room.certainty != null ? "(${room.certainty}%)" : "");
}
