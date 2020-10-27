import 'package:climify/routes/viewAnsweredQuestions.dart';
import 'package:climify/services/bluetooth.dart';
import 'package:climify/services/rest_service.dart';
import 'package:climify/services/updateLocation.dart';
import 'package:climify/services/sharedPreferences.dart';
import 'package:climify/services/snackbarError.dart';
import 'package:climify/widgets/questionList.dart';
import 'package:climify/widgets/scanAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class UnregisteredUserScreen extends StatefulWidget {
  const UnregisteredUserScreen({
    Key key,
  }) : super(key: key);

  @override
  _UnregisteredUserScreenState createState() => _UnregisteredUserScreenState();
}

class _UnregisteredUserScreenState extends State<UnregisteredUserScreen> {
  SharedPrefsHelper _sharedPrefsHelper;
  RestService _restService;
  BluetoothServices _bluetooth;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _visibleIndex = 0;
  bool _fetchingTokens = true;
  String _title = "Provide feedback";
  String _t = "week";

  @override
  void initState() {
    super.initState();

    _restService = RestService();
    _sharedPrefsHelper = SharedPrefsHelper();
    _bluetooth = BluetoothServices();
    _setupState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _setupState() async {
    setState(() {
      _fetchingTokens = true;
    });

    Tuple2 tokens =
        await _sharedPrefsHelper.getUnauthorizedTokens(_restService);

    // Provider.of<GlobalState>(context)
    //     .updateAccount("no email", tokens.item1, tokens.item2, context);
    SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
    await sharedPrefsHelper.setUserTokens(tokens);
    setState(() {
      _fetchingTokens = false;
    });
    await _getAndSetRoom();
  }

  void _setT(String t) {
    setState(() {
      _t = t;
    });
  }

  Future<void> _getAndSetRoom() async {
    UpdateLocation updateLocation =
        Provider.of<UpdateLocation>(context, listen: false);
    if (updateLocation.scanning) {
      return;
    }

    if (!await _bluetooth.isOn) {
      SnackBarError.showErrorSnackBar("Bluetooth is not on", _scaffoldKey);
      return;
    }

    await updateLocation.sendReceiveLocation();
    // _getActiveQuestions();
  }

  Future<void> _getActiveQuestions() async {
    UpdateLocation updateLocation =
        Provider.of<UpdateLocation>(context, listen: false);
    await updateLocation.updateQuestions();
    return;
  }

  void _gotoLogin() {
    _sharedPrefsHelper.setStartOnLogin(true);
    Navigator.of(context).pushReplacementNamed("login");
  }

  void _changeWindow(int index) {
    setState(() {
      _visibleIndex = index;
      switch (index) {
        case 0:
          _title = "Give feedback";
          break;
        case 1:
          _title = "View your feedback";
          break;
        default:
      }
    });
  }

  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(milliseconds: 1500)) {
      currentBackPressTime = now;
      SnackBarError.showErrorSnackBar(
          "Exit application by pressing the back button again", _scaffoldKey,
          duration: Duration(milliseconds: 1500));
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: scanAppBar(
        _getAndSetRoom,
        _title,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            title: Text("Give feedback"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            title: Text("See feedback"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            title: Text("Login"),
          ),
        ],
        onTap: (int index) => index != 2 ? _changeWindow(index) : _gotoLogin(),
        currentIndex: _visibleIndex,
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Visibility(
                visible: _visibleIndex == 0,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: QuestionList(
                          getActiveQuestions: _getActiveQuestions,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                maintainState: true,
                visible: _visibleIndex == 1,
                child: Container(
                  child: _fetchingTokens
                      ? Container()
                      : ViewAnsweredQuestionsWidget(
                          scaffoldKey: _scaffoldKey,
                          user: "me",
                          t: _t,
                          setT: _setT,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
