import 'package:flutter/material.dart';
import 'package:rtk_bluetooth/rtk_bluetooth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> list = [];
  bool isConnected = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('经典蓝牙'),
          actions: [
            TextButton(
                onPressed: () {
                  if (isConnected) {
                    RtkBluetooth.close(callBack: (data) {
                      setState(() {
                        isConnected = false;
                      });
                    });
                  } else {
                    initBlueTooth();
                  }
                },
                child: Text(!isConnected ? "连接" : "断开",
                    style: TextStyle(
                      color: Colors.white,
                    )))
          ],
        ),
        body: Center(
          child: ListView(
            children: list
                .map((e) => ListTile(
                      title: Text(e),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  initBlueTooth() async {
    List<DeviceInfo> devices = await RtkBluetooth.getBondDevices;
    NmeaUitls uitls = NmeaUitls();
    RtkBluetooth.connect(
        callBack: (info) {
          print(info);
          setState(() {
            isConnected = true;
          });
        },
        address: devices.first.address!);
    RtkBluetooth.onNmeaChange.listen((event) {
      print(event);
      list.insert(0, event);
      setState(() {});
    });
  }
}
