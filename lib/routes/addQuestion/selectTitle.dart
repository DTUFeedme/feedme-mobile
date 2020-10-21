import 'package:flutter/material.dart';

class SelectQuestionTitle extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function(bool) setFlowComplete;
  final Function() next;

  const SelectQuestionTitle({
    Key key,
    this.setFlowComplete,
    this.textEditingController,
    this.next,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Center(
                child: Text(
                  'Question title',
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 16,
              child: TextFormField(
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Example: \'How is the temperature?\'',
                ),
                controller: textEditingController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                maxLines: 3,
                minLines: 1,
                onChanged: (value) {
                  if (value.trim().length >= 3) {
                    setFlowComplete(true);
                  } else {
                    setFlowComplete(false);
                  }
                },
                validator: (value) => value.trim().length >= 3
                    ? null
                    : 'Questions must be at least 3 characters',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onEditingComplete: () {
                  if (textEditingController.text.trim().length >= 3) {
                    FocusScope.of(context).unfocus();
                    next();
                  }
                },
              ),
            ),
            Expanded(
              flex: 6,
              child: Center(
                child: Text(
                  'Swipe screen to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
