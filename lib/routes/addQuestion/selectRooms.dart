import 'package:climify/models/roomModel.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SelectQuestionRooms extends StatelessWidget {
  final List<RoomModel> rooms;
  final Map<String, bool> roomSelection;
  final void Function(String) toggleRoom;
  final void Function(bool) setFlowComplete;

  const SelectQuestionRooms({
    Key key,
    this.rooms,
    this.roomSelection,
    this.toggleRoom,
    this.setFlowComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Center(
            child: Text(
              'Select rooms',
              style: TextStyle(
                fontSize: 32,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 16,
          child: Center(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) => Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 16,
                    ),
                    child: ListButton(
                      color: roomSelection[rooms[index].id] ?? false
                          ? Colors.lightBlue.withAlpha(180)
                          : Colors.transparent,
                      onTap: () {
                        toggleRoom(rooms[index].id);
                        if (roomSelection.containsValue(true)) {
                          setFlowComplete(true);
                        } else {
                          setFlowComplete(false);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        child: Text(
                          rooms[index].name,
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
