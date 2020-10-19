import 'package:climify/routes/feedback.dart';
import 'package:climify/services/updateLocation.dart';
import 'package:climify/widgets/emptyListText.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'listButton.dart';

class QuestionList extends StatelessWidget {
  final Function getActiveQuestions;

  const QuestionList({
    Key key,
    this.getActiveQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateLocation>(
      builder: (context, updateLocation, child) => Container(
        child: RefreshIndicator(
          onRefresh: () => getActiveQuestions(),
          child: updateLocation.questions != null &&
                  updateLocation.questions.isNotEmpty
              ? Container(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    itemCount: updateLocation.questions.length,
                    itemBuilder: (_, index) => ListButton(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackWidget(
                            question: updateLocation.questions[index],
                            room: updateLocation.room,
                          ),
                        ),
                      ),
                      child: Text(
                        updateLocation.questions[index].value,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                )
              : EmptyListText(
                  text: 'The list of questions is empty',
                ),
        ),
      ),
    );
  }
}
