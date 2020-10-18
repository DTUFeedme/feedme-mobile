import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SelectQuestionAnswerOptions extends StatefulWidget {
  final List<TextEditingController> answerOptionControllers;
  final void Function(int) removeOption;
  final void Function() addOption;
  final void Function(bool) setFlowComplete;

  const SelectQuestionAnswerOptions({
    Key key,
    this.addOption,
    this.answerOptionControllers,
    this.removeOption,
    this.setFlowComplete,
  }) : super(key: key);

  @override
  _SelectQuestionAnswerOptionsState createState() =>
      _SelectQuestionAnswerOptionsState();
}

class _SelectQuestionAnswerOptionsState
    extends State<SelectQuestionAnswerOptions> {
  ItemScrollController _itemScrollController = ItemScrollController();

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
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemCount: widget.answerOptionControllers.length,
              itemBuilder: (context, index) => Column(
                children: <Widget>[
                  Dismissible(
                    background: Container(
                      color: Colors.red.withAlpha(120),
                    ),
                    key: Key(widget.answerOptionControllers[index].hashCode
                        .toString()),
                    onDismissed: (d) {
                      widget.removeOption(index);
                      if (widget.answerOptionControllers.length < 2) {
                        widget.setFlowComplete(false);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 16,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          style: TextStyle(
                            fontSize: 24,
                          ),
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Answer (swipe to delete)',
                          ),
                          controller: widget.answerOptionControllers[index],
                          onTap: () => _itemScrollController.scrollTo(
                            index: index,
                            duration: Duration(
                              milliseconds: 250,
                            ),
                          ),
                          onChanged: (value) {
                            if (value.trim().isNotEmpty &&
                                widget.answerOptionControllers.length >= 2) {
                              if (widget.answerOptionControllers
                                  .any((c) => c.text.trim().isEmpty)) {
                                widget.setFlowComplete(false);
                              } else {
                                widget.setFlowComplete(true);
                              }
                            } else {
                              widget.setFlowComplete(false);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  index == widget.answerOptionControllers.length - 1
                      ? SizedBox(
                          height: (MediaQuery.of(context).size.height / 10) * 3)
                      : Container()
                ],
              ),
            ),
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
                onPressed: () => widget.addOption(),
                child: Text("Add option"),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
