import 'package:climify/models/feedbackQuestion.dart';
import 'package:climify/models/globalState.dart';
import 'package:climify/models/userModel.dart';
import 'package:climify/routes/answerQuestion.dart';
import 'package:climify/routes/buildingsRoute.dart';
import 'package:climify/routes/enterRoomNumber.dart';
import 'package:climify/routes/feedback.dart';
import 'package:climify/routes/selectQuestion.dart';
import 'package:climify/routes/userLogin.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/styles/textStyles.dart';
import 'package:climify/widgets/roundedBox.dart';
//import 'package:climify/test/testQuestion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/api_response.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climify Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Climify Feedback Tech Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GlobalState>(
      create: (context) => GlobalState(),
      child: MaterialApp(
        home: UserLogin(),
        routes: {
          "login": (context) => UserLogin(),
          "buildings": (context) => BuildingsPage(),
        },
      ),
    );
  }
}

// class _MyHomePageState extends State<MyHomePage> {
//   List<FeedbackQuestion> _questionList = [];
//   String _room = "";
//   String _testText = "";
//   final _selectQuestion = new SelectQuestion();

//   void _changeRoom(String room) {
//     setState(() async {
//       _room = room;
//       _getQuestions(room);
//     });
//   }

//   void _setTestText(String text) async {
//     setState(() {
//       _testText = text;
//     });
//   }

//   void _receiveFeedback(FeedbackQuestion question, int option) {
//     _setTestText(
//         "Answered: ${question.answerOptions[option]}. Room number is $_room");
//   }

//   void _getQuestions(String room) async {
//     final restService = RestService();
//     print(room);
//     APIResponse<List<FeedbackQuestion>> questionList =
//         await restService.getQuestionByRoom(room);
//     if (questionList.error != true) {
//       print(room);
//       _questionList = questionList.data;
//       print(_questionList.toString());
//     } else {
//       print(questionList.errorMessage);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Flexible(
//               child: Container(),
//               flex: 1,
//             ),
//             Flexible(
//               child: EnterRoomNumber(
//                 onTextInput: _changeRoom,
//               ),
//               flex: 3,
//             ),
//             Flexible(
//               child: Container(
//                 margin: EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 96,
//                 ),
//                 child: RoundedBox(
//                   onTap: () {
//                     if (_questionList != null && _questionList != []) {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => _selectQuestion,
//                           settings: RouteSettings(
//                             arguments: _questionList,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   decoration: BoxDecoration(
//                     color: _questionList == [] ? Colors.blue : Colors.lightBlue,
//                   ),
//                   child: Center(
//                     child: Text(
//                       "Select room",
//                       style: TextStyles.bodyStyle.copyWith(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//               flex: 1,
//               /*Flexible(
//               child: FeedbackWidget(
//                 question: testQuestion,
//                 room: _room,
//                 returnFeedback: _receiveFeedback,
//               ),
//               flex: 10,
//             ),
//             */
//             ),
//             Flexible(
//               child: InkWell(
//                 onLongPress: () => _setTestText(""),
//                 child: Container(
//                   child: Text(
//                     _testText,
//                   ),
//                 ),
//               ),
//               flex: 1,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
