import 'package:background_fetch/background_fetch.dart';
import 'package:climify/routes/buildingManager.dart';
import 'package:climify/routes/userLogin.dart';
import 'package:climify/routes/userRoutes/registeredUserRoute.dart';
import 'package:climify/routes/userRoutes/unregisteredUserRoute.dart';
import 'package:climify/services/send_receive_location.dart';

//import 'package:climify/test/testQuestion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const EVENTS_KEY = "fetch_events";

class LocalNotifications {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static bool preventSelectNotification;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocalNotifications.flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails launchDetails = await LocalNotifications
      .flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();
  LocalNotifications.preventSelectNotification = launchDetails.didNotificationLaunchApp;
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
    onSelectNotification: selectNotification,
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
    await sendReceiveLocation();
    BackgroundFetch.finish(taskId);
    return;
  }).then((int status) {
    print('[BackgroundFetch] configure success: $status');
  }).catchError((e) {
    print('[BackgroundFetch] configure ERROR: $e');
  });

  runApp(MyApp());
}

Future selectNotification(String payload) async {
  if (LocalNotifications.preventSelectNotification) {
    return;
  }

  if (payload != null) {
    debugPrint('notification payload: ' + payload);
  }
  if (payload == "scan") {
    await sendReceiveLocation();
  }
  return;
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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UnregisteredUserScreen(),
      routes: {
        "unregistered": (context) => UnregisteredUserScreen(),
        "login": (context) => UserLogin(),
        "registered": (context) => RegisteredUserScreen(),
        "buildingManager": (context) => BuildingManager(),
      },
    );
  }
}
