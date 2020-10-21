import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SelectQuestionAnswerOptions extends StatefulWidget {
  final List<TextEditingController> answerOptionControllers;
  final void Function(TextEditingController) removeOption;
  final void Function() addOption;
  final void Function(bool) setFlowComplete;
  final void Function(int, int) swapOptions;
  final List<GlobalKey> answerKeys;

  const SelectQuestionAnswerOptions({
    Key key,
    this.addOption,
    this.answerOptionControllers,
    this.removeOption,
    this.setFlowComplete,
    this.swapOptions,
    this.answerKeys,
  }) : super(key: key);

  @override
  _SelectQuestionAnswerOptionsState createState() =>
      _SelectQuestionAnswerOptionsState();
}

class _SelectQuestionAnswerOptionsState
    extends State<SelectQuestionAnswerOptions> {
  ScrollController _scrollController = ScrollController();

  void _scrollToIndex(ScrollController scrollController, double offset) {
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _checkFlowComplete() {
    if (widget.answerOptionControllers.length >= 2) {
      if (widget.answerOptionControllers.any((c) => c.text.trim().isEmpty)) {
        widget.setFlowComplete(false);
      } else {
        widget.setFlowComplete(true);
      }
    } else {
      widget.setFlowComplete(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double listPadding = MediaQuery.of(context).size.height / 5;
    List<Widget> _listChildren = widget.answerOptionControllers.map(
      (element) {
        int index = widget.answerOptionControllers.indexOf(element);
        GlobalKey key = widget.answerKeys[index];
        double Function() offset = () =>
            key.currentContext.size.height * index -
            ((key.currentContext.size.height / 5) * 3);

        return Dismissible(
          background: Container(
            color: Colors.red.withAlpha(120),
          ),
          key: key,
          onDismissed: (d) {
            widget.removeOption(element);
            _checkFlowComplete();
          },
          child: Container(
            decoration: BoxDecoration(
              border: BorderDirectional(bottom: BorderSide()),
            ),
            child: ListTile(
              leading: Icon(Icons.menu),
              title: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 16,
                ),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) =>
                      widget.answerOptionControllers.length < 2
                          ? 'You need at least 2 answers'
                          : value.trim().isEmpty
                              ? 'Answer option must contain text'
                              : null,
                  textInputAction:
                      index == widget.answerOptionControllers.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                  onTap: () => _scrollToIndex(_scrollController, offset()),
                  onEditingComplete: () {
                    if (index == widget.answerOptionControllers.length - 1) {
                      FocusScope.of(context).unfocus();
                    } else {
                      FocusScope.of(context)
                          .focusInDirection(TraversalDirection.down);
                      _scrollToIndex(_scrollController,
                          offset() + key.currentContext.size.height);
                    }
                  },
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Answer',
                    hintStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  controller: element,
                  onChanged: (value) {
                    _checkFlowComplete();
                  },
                ),
              ),
            ),
          ),
        );
      },
    ).toList();
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Center(
            child: Text(
              'Add answers',
              style: TextStyle(
                fontSize: 32,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 18,
          child: Center(
            child: ReorderableListView(
                padding: EdgeInsets.only(bottom: listPadding),
                children: _listChildren,
                scrollController: _scrollController,
                onReorder: (i1, i2) {
                  widget.swapOptions(i1, i2);
                }),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width / 5) * 3,
              child: RaisedButton(
                onPressed: () {
                  widget.addOption();
                  widget.setFlowComplete(false);
                },
                child: Text("Add option"),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
