import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Bluetooth Demo Home Page'),
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
  List<ScanResult> _scanResults = [];
  ScanResult _activeResult;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _isOn;

  Future<void> _scanForDevices() async {
    setState(() {
      _scanResults = [];
    });
    await Future.delayed(Duration(milliseconds: 250));
    try {
      flutterBlue.startScan(timeout: Duration(seconds: 3));

      var subscription = flutterBlue.scanResults.listen((scanResult) {
        scanResult.forEach((element) {
          if (!_scanResults.contains(element)) {
            setState(() {
              _scanResults.add(element);
            });
            print("added: ${element.toString()}");
          }
        });
      });

// Stop scanning
      flutterBlue.stopScan();
      await Future.delayed(Duration(seconds: 3));
      return;
    } catch (e) {}
    return;
  }

  void _setActiveResult(ScanResult scanResult) async {
    setState(() {
      _activeResult = scanResult;
    });
    if (scanResult.device.name == 'Kontakt') {
      print("hey");
      BluetoothDevice device = scanResult.device;
      await device.connect();
      print("connected");
      List<BluetoothService> services =
          await scanResult.device.discoverServices();

      List<BluetoothCharacteristic> characteristics = [];
      List<BluetoothDescriptor> descriptors = [];
      services.forEach((service) {
        characteristics.addAll(service.characteristics);
        characteristics.forEach((c) => descriptors.addAll(c.descriptors));
      });
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.read) {
          List<int> value = await c.read();
          print('uuid: ${c.uuid}');
          print('value: $value');
        } else {
          print('uuid: ${c.uuid} unreadable');
        }
      }
      print("de");
      for (BluetoothDescriptor d in descriptors) {
        List<int> value = await d.read();
        print('uuid: ${d.uuid}');
        print('value: $value');
      }
      

      print("ho");

      device.disconnect();
    }
  }

  @override
  void initState() {
    super.initState();
    _getIsOn();
    _scanForDevices();
  }

  void _getIsOn() async {
    bool isOn = await flutterBlue.isOn;
    setState(() {
      _isOn = isOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _isOn == null
                ? Text(
                    'Initializing Bluetooth',
                  )
                : Text(
                    'Bluetooth status: ' + (_isOn ? "On" : "Off"),
                  ),
            Text(
              'List of found bluetooth devices:',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _scanForDevices(),
                child: ListView(
                  children: _scanResults
                      .map(
                        (scanResult) => _BluetoothDeviceWidget(
                          scanResult: scanResult,
                          setActiveResult: _setActiveResult,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _activeResult == null
                    ? <Widget>[
                        Text(
                          'More info (tap a result)',
                        ),
                      ]
                    : <Widget>[
                        Text(
                            'More info (${_activeResult.device.id.toString()})'),
                        Text(
                          'connectable: ${_activeResult.advertisementData.connectable.toString()}',
                        ),
                        Text(
                          'manufacturer data: ${_activeResult.advertisementData.manufacturerData.toString()}',
                        ),
                        Text(
                          'service data: ${_activeResult.advertisementData.serviceData.toString()}',
                        ),
                        Text(
                          'service uuids: ${_activeResult.advertisementData.serviceUuids.toString()}',
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BluetoothDeviceWidget extends StatelessWidget {
  _BluetoothDeviceWidget({
    Key key,
    this.scanResult,
    this.setActiveResult,
  }) : super(key: key);

  final ScanResult scanResult;
  final void Function(ScanResult) setActiveResult;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setActiveResult(scanResult),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blueGrey,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Name: ${scanResult.device.name}',
            ),
            Divider(
              thickness: 0,
              color: Colors.transparent,
            ),
            Text(
              'Local Name: ${scanResult.advertisementData.localName}',
            ),
            Text(
              'Device Type: ${scanResult.device.type.toString()}',
            ),
            Text(
              'Id: ${scanResult.device.id.toString()}',
            ),
            Text(
              'rssi: ${scanResult.rssi}',
            ),
          ],
        ),
      ),
    );
  }
}
