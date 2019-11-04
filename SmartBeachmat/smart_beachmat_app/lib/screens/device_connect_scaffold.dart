import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_beachmat_app/widgets/left_app_bar.dart';

class DeviceConnectScaffold extends StatefulWidget {
  @override
  _DeviceConnectScaffoldState createState() => _DeviceConnectScaffoldState();
}

class _DeviceConnectScaffoldState extends State<DeviceConnectScaffold> {
  BluetoothDevice _device;

  StreamSubscription<ScanResult> _streamSubscription;

  double uvIndex = 0.41;
  int battery;

  bool connecting = false;
  bool connected = false;

  bool recording = false;

  // TODO: Change to botton_navigation_scaffold after connecting
  // TODO: Store connected device?
  Future<void> connect() async {
    setState(() {
      connecting = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      connected = true;
    });
    await Timer(Duration(seconds: 60), () {

      setState(() {
        Random rnd = Random();
        uvIndex = (12 + rnd.nextInt(89 - 12))/100;
      });
    });
    // setState(() {
    //   connecting = true;
    // });
    // print('SCANNING...');
    // // Start scanning
    // _streamSubscription = FlutterBlue.instance
    //     .scan(timeout: Duration(seconds: 3))
    //     .where((scanResult) {
    //   return scanResult.device.name == 'Smart Beach Mat' &&
    //       scanResult.advertisementData.serviceUuids.contains('180F') &&
    //       scanResult.advertisementData.serviceUuids.contains('181A');
    // }).listen((scanResult) async {
    //   _device = scanResult.device;

    //   print('FOUND DEVICE: ${_device.id.id}');

    //   await _streamSubscription.cancel(); // Stop listening
    //   await _device.connect();

    //   List<BluetoothService> services = await _device.discoverServices();
    //   services.forEach((service) async {
    //     service.characteristics.forEach((characteristic) async {
    //       await characteristic.setNotifyValue(true);
    //       characteristic.value.listen((value) {
    //         var bdata = ByteData(4);

    //         bdata.setUint8(0, value[0]);
    //         bdata.setUint8(1, value[1]);
    //         bdata.setUint8(2, value[2]);
    //         bdata.setUint8(3, value[3]);

    //         if (characteristic.uuid.toString() ==
    //             '00002a76-0000-1000-8000-00805f9b34fb') {
    //           setState(() {
    //             uvIndex = bdata.getFloat32(0, Endian.little);
    //           });
    //           print('INDEX: ${uvIndex}');
    //         } else if (characteristic.uuid.toString() ==
    //             '00002a19-0000-1000-8000-00805f9b34fb') {
    //           setState(() {
    //             battery = bdata.getInt32(0, Endian.little);
    //           });
    //           print('BATTERY: ${battery}');
    //         }
    //       });
    //     });
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return !connected //(uvIndex == null || battery == null)
        ? Scaffold(
            body: Padding(
              padding: EdgeInsets.all(17),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                          'Hold your smart beach mat close to the phone, and press the button below to connect.'),
                      Container(
                        height: 17,
                      ),
                      RaisedButton(
                        child: Text(connecting ? 'Connecting...' : 'Connect'),
                        onPressed: connecting ? null : connect,
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: LeftAppBar(
              context,
              title: Text('Current UV Index 🌞'),
            ),
            body: Padding(
              padding: EdgeInsets.all(17),
              child: Column(children: <Widget>[
                Container(
                  child: Text(
                    '${uvIndex.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 100,
                        color: Color.fromARGB(200, 255, 255, 255)),
                  ),
                  height: 300,
                  width: 300,
                  alignment: Alignment(0, 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      color: (uvIndex <= 2)
                          ? Colors.green
                          : (uvIndex <= 5)
                              ? Colors.yellow
                              : (uvIndex <= 7)
                                  ? Colors.orange
                                  : (uvIndex <= 10)
                                      ? Colors.red
                                      : Colors.purple),
                ),
                Container(
                  height: 17,
                ),
                // Text(
                //   '🔋 $battery',
                //   style: Theme.of(context).primaryTextTheme.headline,
                // ),
                RaisedButton(
                  child: Text(recording ? 'Stop Recording' : 'Start Recording'),
                  color: recording ? Colors.red : Colors.blue,
                  onPressed: (() {
                    setState(() {
                      recording = !recording;
                    });
                  }),
                )
              ]),
            ));
  }
}
