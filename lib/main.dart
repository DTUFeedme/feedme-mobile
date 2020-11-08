import 'package:background_fetch/background_fetch.dart';
import 'package:climify/routes/addQuestion/addQuestionFlow.dart';
import 'package:climify/routes/buildingManager.dart';
import 'package:climify/routes/scanRoom/scanRoom.dart';
import 'package:climify/routes/splashScreen.dart';
import 'package:climify/routes/userLogin.dart';
import 'package:climify/routes/userRoutes/registeredUserRoute.dart';
import 'package:climify/routes/userRoutes/unregisteredUserRoute.dart';
import 'package:climify/services/updateLocation.dart';

//import 'package:climify/test/testQuestion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const EVENTS_KEY = "fetch_events";

class LocalNotifications {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static bool preventSelectNotification;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  UpdateLocation updateLocation = UpdateLocation();

  LocalNotifications.flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails launchDetails = await LocalNotifications
      .flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();
  LocalNotifications.preventSelectNotification =
      launchDetails.didNotificationLaunchApp;
  AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: (_, __, ___, ____) {
    print("iOS foreground notification");
    return;
  });
  InitializationSettings initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await LocalNotifications.flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) => selectNotification(
      payload,
      updateLocation,
    ),
  );

  BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 1,
        forceAlarmManager: false,
        stopOnTerminate: true,
        startOnBoot: true,
        enableHeadless: false,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ), (taskId) async {
    await updateLocation.sendReceiveLocation(fromAuto: true);
    BackgroundFetch.finish(taskId);
    return;
  }).then((int status) {
    print('[BackgroundFetch] configure success: $status');
  }).catchError((e) {
    print('[BackgroundFetch] configure ERROR: $e');
  });

  // runApp(ClimifyApp());
  runApp(
    ChangeNotifierProvider(
      create: (context) => updateLocation,
      child: ClimifyApp(),
    ),
  );
}

Future selectNotification(String payload, UpdateLocation updateLocation) async {
  if (LocalNotifications.preventSelectNotification) {
    return;
  }

  if (payload != null) {
    debugPrint('notification payload: ' + payload);
  }
  if (payload == "scan") {
    await updateLocation.sendReceiveLocation();
  }
  return;
}

// class MyApp extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Climify Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Climify Feedback Tech Demo'),
//     );
//   }
// }

class ClimifyApp extends StatefulWidget {
  ClimifyApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ClimifyAppState createState() => _ClimifyAppState();
}

class _ClimifyAppState extends State<ClimifyApp> {
  static const platform = const MethodChannel('CHANNEL');

  @override
  void dispose() {
    LocalNotifications.flutterLocalNotificationsPlugin.cancelAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Climify",
      home: SplashScreen(),
      onGenerateRoute: (settings) {
        Map<String, Widget Function(BuildContext)> routes = {
          "unregistered": (context) => UnregisteredUserScreen(),
          "login": (context) => UserLogin(),
          "registered": (context) => RegisteredUserScreen(),
          "buildingManager": (context) => BuildingManager(
                building: settings.arguments,
              ),
          "addQuestion": (context) => AddQuestionFlow(
                arguments: settings.arguments,
              ),
          "scanRoom": (context) => ScanRoomFlow(
            arguments: settings.arguments,
          ),
        };
        WidgetBuilder builder = routes[settings.name];
        return MaterialPageRoute(builder: (context) => builder(context));
      },
    );
  }

  Future<void> _callNative() async {
    await platform.invokeMethod("testNative");
  }
}
