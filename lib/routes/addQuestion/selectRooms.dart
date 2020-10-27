import 'package:climify/models/roomModel.dart';
import 'package:climify/widgets/listButton.dart';
import 'package:flutter/material.dart';

class SelectQuestionRooms extends StatelessWidget {
  final List<RoomModel> rooms;
  final Map<String, bool> roomSelection;
  final void Function(String) toggleRoom;
  final void Function() toggleAllRooms;
  final void Function(bool) setFlowComplete;

  const SelectQuestionRooms({
    Key key,
    this.rooms,
    this.roomSelection,
    this.toggleRoom,
    this.toggleAllRooms,
    this.setFlowComplete,
  }) : super(key: key);

  _setFlowComplete() {
    if (roomSelection.containsValue(true)) {
      setFlowComplete(true);
    } else {
      setFlowComplete(false);
    }
  }

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
              itemCount: rooms.length + 1,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  child: index == 0
                      ? ListButton(
                          color: Colors.transparent,
                          onTap: () {
                            toggleAllRooms();
                            _setFlowComplete();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            child: Text(
                              "Select all",
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        )
                      : ListButton(
                          color: roomSelection[rooms[index - 1].id] ?? false
                              ? Colors.lightBlue.withAlpha(180)
                              : Colors.transparent,
                          onTap: () {
                            toggleRoom(rooms[index - 1].id);
                            _setFlowComplete();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            child: Text(
                              rooms[index - 1].name,
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
