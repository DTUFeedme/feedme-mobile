import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:climify/models/api_response.dart';
import 'package:climify/models/buildingModel.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/sharedPreferences.dart';

//import 'package:climify/test/testQuestion.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import 'models/roomModel.dart';

const EVENTS_KEY = "fetch_events";

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print("[BackgroundFetch] Headless event received: $taskId");
  if (taskId == 'flutter_background_fetch') {
    BackgroundFetch.finish(taskId);
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "send_location",
        delay: 10,
        periodic: false,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true));
  }
  // BackgroundFetch.scheduleTask(TaskConfig(
  //     taskId: "send_location",
  //     delay: 5000,
  //     periodic: false,
  //     forceAlarmManager: true,
  //     stopOnTerminate: false,
  //     enableHeadless: true));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

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

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<GlobalState>(
//       create: (context) => GlobalState(),
//       child: MaterialApp(
//         home: UnregisteredUserScreen(),
//         routes: {
//           "unregistered": (context) => UnregisteredUserScreen(),
//           "login": (context) => UserLogin(),
//           "registered": (context) => RegisteredUserScreen(),
//           "buildingManager": (context) => BuildingManager(),
//         },
//       ),
//     );
//   }
// }

class _MyHomePageState extends State<MyHomePage> {
  int _status = 0;
  List<String> _events = [];
  bool _enabled = true;
  int _testInt = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Load persisted fetch events from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _testInt = prefs.getInt("testInt") ?? 0;

    String json = prefs.getString(EVENTS_KEY);
    if (json != null) {
      setState(() {
        _events = jsonDecode(json).cast<String>();
      });
    }

    // Configure BackgroundFetch.
    BackgroundFetch.configure(
            BackgroundFetchConfig(
              minimumFetchInterval: 1,
              forceAlarmManager: true,
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: NetworkType.ANY,
            ),
            _fetchRoomLocationBackground)
        .then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Schedule a "one-shot" custom-task in 10000ms.
    // These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
    // where device must be powered (and delay will be throttled by the OS).
    // BackgroundFetch.scheduleTask(TaskConfig(
    //     taskId: "com.transistorsoft.customtask",
    //     delay: 10000,
    //     periodic: false,
    //     forceAlarmManager: true,
    //     stopOnTerminate: false,
    //     enableHeadless: true));

    // BackgroundFetch.scheduleTask(TaskConfig(
    //     taskId: "send_location",
    //     delay: 3500,
    //     periodic: false,
    //     forceAlarmManager: true,
    //     stopOnTerminate: false,
    //     enableHeadless: true));

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _fetchRoomLocationBackground(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime timestamp = new DateTime.now();
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received: $taskId");
    setState(() {
      _events.insert(0, "$taskId@${timestamp.toString()}");
    });
    // Persist fetch events in SharedPreferences
    prefs.setString(EVENTS_KEY, jsonEncode(_events));

    print("sending stuff");
    SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
    RestService _restService = RestService();
    Tuple2<String, String> _tokens =
        await sharedPrefsHelper.getUnauthorizedTokens(_restService);
    BluetoothServices _bluetoothServices = BluetoothServices();
    SharedPreferences _sp = await SharedPreferences.getInstance();
    await sharedPrefsHelper.setUserTokens(_tokens);
    APIResponse<Tuple2<BuildingModel, RoomModel>> apiResponse =
        await _bluetoothServices.getBuildingAndRoomFromScan();
    print(apiResponse.errorMessage ?? "no error");
    RoomModel _room = apiResponse?.data?.item2;
    print(_room);
    print(_room?.name);
    if (_room?.name == "Funny") {
      int i = _sp.getInt("testInt") ?? 0;
      await _sp.setInt("testInt", i + 1);
    }

    BackgroundFetch.finish(taskId);
  }

  void _onBackgroundFetch(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime timestamp = new DateTime.now();
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received: $taskId");
    setState(() {
      _events.insert(0, "$taskId@${timestamp.toString()}");
    });
    // Persist fetch events in SharedPreferences
    prefs.setString(EVENTS_KEY, jsonEncode(_events));

    if (taskId == "flutter_background_fetch") {
      // Schedule a one-shot task when fetch event received (for testing).
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "flutter_test",
          delay: 5000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true));
    }

    if (taskId == "send_location") {
      print("sending stuff");
      SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
      RestService _restService = RestService();
      Tuple2<String, String> _tokens =
          await sharedPrefsHelper.getUnauthorizedTokens(_restService);
      BluetoothServices _bluetoothServices = BluetoothServices();
      SharedPreferences _sp = await SharedPreferences.getInstance();
      await sharedPrefsHelper.setUserTokens(_tokens);
      APIResponse<Tuple2<BuildingModel, RoomModel>> apiResponse =
          await _bluetoothServices.getBuildingAndRoomFromScan();
      print(apiResponse.errorMessage ?? "no error");
      RoomModel _room = apiResponse?.data?.item2;
      print(_room);
      print(_room?.name);
      if (_room?.name == "Funny") {
        int i = _sp.getInt("testInt");
        await _sp.setInt("testInt", i + 1);
      }
      // BackgroundFetch.scheduleTask(TaskConfig(
      //     taskId: "send_location",
      //     delay: 10000,
      //     periodic: false,
      //     forceAlarmManager: true,
      //     stopOnTerminate: false,
      //     enableHeadless: true));
    }

    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  void _onClickClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(EVENTS_KEY);
    setState(() {
      _events = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    const EMPTY_TEXT = Center(
        child: Text(
            'Waiting for fetch events.  Simulate one.\n [Android] \$ ./scripts/simulate-fetch\n [iOS] XCode->Debug->Simulate Background Fetch'));

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
            title: const Text('BackgroundFetch Example',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.amberAccent,
            brightness: Brightness.light,
            actions: <Widget>[
              Switch(value: _enabled, onChanged: _onClickEnable),
            ]),
        body: (_events.isEmpty)
            ? EMPTY_TEXT
            : Container(
                child: new ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (BuildContext context, int index) {
                      List<String> event = _events[index].split("@");
                      return InputDecorator(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 5.0, top: 5.0, bottom: 5.0),
                              labelStyle:
                                  TextStyle(color: Colors.blue, fontSize: 20.0),
                              labelText: "[${event[0].toString()}]"),
                          child: new Text(event[1],
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0)));
                    }),
              ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                          onPressed: () async {
                            SharedPreferences _sp =
                                await SharedPreferences.getInstance();
                            setState(() {
                              _testInt = _sp.getInt("testInt");
                            });
                          },
                          child: Text('test: $_testInt')),
                      RaisedButton(
                          onPressed: _onClickStatus,
                          child: Text('Status: $_status')),
                      RaisedButton(
                          onPressed: _onClickClear, child: Text('Clear'))
                    ]))),
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
