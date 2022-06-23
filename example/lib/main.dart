import 'package:flutter/material.dart';
import 'package:rtk_bluetooth/rtk_bluetooth.dart';
import 'package:rtk_bluetooth_example/data.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => const MyApp(),
      },
    );
  }
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
                    style: const TextStyle(
                      color: Colors.white,
                    ))),
            TextButton(
                onPressed: () {
                  showAboutDialog(
                      context: context,
                      children: [SelectableText(list.join("|"))]);
                },
                child: const Text("导出",
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
    var nema = NmeaUitls(locationCallBack: (location) {
      print(location);
    });
    dataStr.split("|").forEach((e) {
      nema.handleNmea(e);
    });
    List<DeviceInfo> devices = await RtkBluetooth.getBondDevices;
    //NmeaUitls uitls = NmeaUitls();
    //这里直接使用第一个已经配对的设备
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
      nema.handleNmea(event);
    });
  }
}
