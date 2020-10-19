import 'package:climify/models/answerOption.dart';
import 'package:climify/models/api_response.dart';
import 'package:climify/models/questionModel.dart';
import 'package:climify/models/roomModel.dart';
import 'package:climify/routes/addQuestion/selectAnswerOptions.dart';
import 'package:climify/routes/addQuestion/selectRooms.dart';
import 'package:climify/routes/addQuestion/selectTitle.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/widgets/submitButton.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class OldStateQuestionFlow {
  final String title;
  final List<String> answerOptions;
  final List<bool> flowComplete;

  const OldStateQuestionFlow({
    this.answerOptions,
    this.flowComplete,
    this.title,
  });
}

class AddQuestionFlow extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const AddQuestionFlow({
    this.arguments = const {},
    Key key,
  }) : super(key: key);

  @override
  _AddQuestionFlowState createState() => _AddQuestionFlowState();
}

class _AddQuestionFlowState extends State<AddQuestionFlow> {
  ItemScrollController _itemScrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  int _index = 0;
  RestService _restService;
  TextEditingController _titleController = TextEditingController();
  List<TextEditingController> _answerOptionsControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  List<GlobalKey> _answerKeys = [
    GlobalKey(),
    GlobalKey(),
  ];
  Map<String, bool> _roomSelection = {};
  List<bool> _flowComplete = [false, false, false];
  bool _moving = false;
  List<RoomModel> _rooms;
  OldStateQuestionFlow _oldState;

  @override
  void initState() {
    super.initState();
    _restService = RestService();
    _oldState = widget.arguments['oldState'];
    _rooms = widget.arguments['rooms'];
    _rooms.sort(
        (r1, r2) => r1.name.toLowerCase().compareTo(r2.name.toLowerCase()));
    _itemPositionsListener.itemPositions.addListener(() {
      List<ItemPosition> positions =
          _itemPositionsListener.itemPositions.value.toList();
      int newIndex = positions
          .firstWhere(
            (element) => element.itemLeadingEdge.abs() <= 0.5,
            orElse: () => positions[0],
          )
          .index;
      if (_index != newIndex && !_moving) {
        setState(() {
          _index = newIndex;
        });
        FocusScope.of(context).unfocus();
      }
    });
    if (_oldState != null) {
      setState(() {
        _answerOptionsControllers = [];
        _oldState.answerOptions.forEach((element) {
          _answerOptionsControllers.add(
            TextEditingController(
              text: element,
            ),
          );
          _answerKeys.add(GlobalKey());
        });
        _flowComplete[0] = _oldState.flowComplete[0];
        _flowComplete[1] = _oldState.flowComplete[1];
        _titleController.text = _oldState.title;
      });
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(() {});
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    List<String> selectedRooms = [];
    List<String> answerOptions = [];
    _answerOptionsControllers.forEach((element) {
      answerOptions.add(element.text);
    });
    _roomSelection.forEach((key, value) {
      if (value) {
        selectedRooms.add(key);
      }
    });
    APIResponse<Question> apiResponse = await _restService.postQuestion(
      selectedRooms,
      _titleController.text.trim().toString(),
      answerOptions,
    );
    Navigator.of(context).pop({'apiResponse': apiResponse});
    return;
  }

  void _next() {
    if (_index < 2) {
      _moveToIndex(_index + 1);
    }
  }

  void _moveToIndex(int index) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _moving = true;
      _index = index;
    });
    await _itemScrollController.scrollTo(
      index: _index,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() {
      _moving = false;
    });
  }

  void _flagFlowComplete(int index, bool b) {
    setState(() {
      _flowComplete[index] = b;
    });
  }

  Widget _topBarSegment({
    String text,
    int index,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      child: InkWell(
        onTap: () => _moveToIndex(index),
        child: Container(
          decoration: BoxDecoration(
            color: _index >= index
                ? _flowComplete[index] ? Colors.lightBlueAccent : Colors.grey
                : _flowComplete[index]
                    ? Colors.lightBlueAccent
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 1,
              color: Colors.black,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight:
                    _index == index ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addAnswerOption() {
    FocusScope.of(context).unfocus();
    setState(() {
      _answerOptionsControllers.add(TextEditingController());
    });
    _answerKeys.add(GlobalKey());
  }

  void _removeAnswerOption(TextEditingController element) {
    FocusScope.of(context).unfocus();
    setState(() {
      _answerKeys.removeAt(_answerOptionsControllers.indexOf(element));
      _answerOptionsControllers.remove(element);
    });
  }

  void _swapAnswerOptions(int i1, int i2) {
    FocusScope.of(context).unfocus();
    setState(() {
      if (i2 > i1) {
        i2 = i2 - 1;
      }
      final GlobalKey key = _answerKeys.removeAt(i1);
      final TextEditingController item = _answerOptionsControllers.removeAt(i1);
      _answerKeys.insert(i2, key);
      _answerOptionsControllers.insert(i2, item);
    });
  }

  void _toggleRoom(String id) {
    setState(() {
      _roomSelection[id] = !(_roomSelection[id] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _flowWidgets = [
      SelectQuestionTitle(
        setFlowComplete: (b) => _flagFlowComplete(0, b),
        next: _next,
        textEditingController: _titleController,
      ),
      SelectQuestionAnswerOptions(
        answerOptionControllers: _answerOptionsControllers,
        addOption: _addAnswerOption,
        setFlowComplete: (b) => _flagFlowComplete(1, b),
        removeOption: _removeAnswerOption,
        swapOptions: _swapAnswerOptions,
        answerKeys: _answerKeys,
      ),
      SelectQuestionRooms(
        roomSelection: _roomSelection,
        rooms: _rooms,
        setFlowComplete: (b) => _flagFlowComplete(2, b),
        toggleRoom: _toggleRoom,
      ),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Add Question')),
      body: WillPopScope(
        onWillPop: () async {
          List<bool> flowComplete = [];
          flowComplete.addAll(_flowComplete);
          flowComplete.removeLast();
          List<String> answerOptions = [];
          _answerOptionsControllers.forEach((element) {
            answerOptions.add(element.text);
          });
          Navigator.of(context).pop(
            {
              'oldState': OldStateQuestionFlow(
                answerOptions: answerOptions,
                flowComplete: flowComplete,
                title: _titleController.text,
              ),
            },
          );
          return true;
        },
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Row(
                  children: <Widget>[
                    _topBarSegment(
                      text: 'Title',
                      index: 0,
                    ),
                    _topBarSegment(
                      text: 'Answer Options',
                      index: 1,
                    ),
                    _topBarSegment(
                      text: 'Rooms',
                      index: 2,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 20,
                child: ScrollablePositionedList.builder(
                  physics: PageScrollPhysics(),
                  itemScrollController: _itemScrollController,
                  itemCount: _flowWidgets.length,
                  itemPositionsListener: _itemPositionsListener,
                  itemBuilder: (context, index) => SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _flowWidgets[index],
                  ),
                  scrollDirection: Axis.horizontal,
                ),
              ),
              Expanded(
                flex: 2,
                child: SubmitButton(
                  onPressed: _submitQuestion,
                  enabled: !_flowComplete.any((b) => b == false),
                  text: "Submit Question",
                  textSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
