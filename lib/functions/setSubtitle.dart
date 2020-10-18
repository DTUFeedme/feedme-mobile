import 'package:climify/models/roomModel.dart';
import 'package:climify/services/updateLocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String getSubtitle(
  BuildContext context,
) {
  UpdateLocation updateLocation = Provider.of<UpdateLocation>(context);
  bool gettingRoom = updateLocation.scanning;
  RoomModel room = updateLocation.room;
  return gettingRoom
      ? "Room: scanning..."
      : room == null
          ? "Failed scanning room, tap to retry"
          : "Room: ${room.name} " +
              (room.certainty != null ? "(${room.certainty}%)" : "");
}
