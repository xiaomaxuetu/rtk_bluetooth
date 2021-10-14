import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rtk_bluetooth/rtk_bluetooth.dart';
import 'package:rtk_bluetooth/src/bean/device_info.dart';

typedef RtkBluetoothConnectCallBack = Function(ConnectResultInfo);

class RtkBluetooth {
  static const MethodChannel _channel = MethodChannel('rtk_bluetooth');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static final _onNmeaChange = StreamController<String>.broadcast();
  RtkBluetooth._();
  static Future _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onNmeaChange':
        _onNmeaChange.add(call.arguments);
    }
  }

  static Stream<String> get onNmeaChange => _onNmeaChange.stream;

  static Future<List<DeviceInfo>> get getBondDevices async {
    final String? version = await _channel.invokeMethod('getBondDevices');
    List devices = jsonDecode(version!);
    return devices.map((e) => DeviceInfo.fromJson(e)).toList();
  }

  static connect(
      {required RtkBluetoothConnectCallBack callBack,
      required String address}) {
    _channel.setMethodCallHandler(_handleMessages);
    Isolate.current.addErrorListener(RawReceivePort((dynamic pair) {
      var isolateError = pair as List<dynamic>;
      var _error = isolateError.first;
      var _stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(_error, _stackTrace);
    }).sendPort);
    runZonedGuarded(() async {
      final String result =
          await _channel.invokeMethod('connect', {'address': address});
      Map<String, dynamic> resultMap = json.decode(result);
      callBack(ConnectResultInfo.fromJson(resultMap));
    }, (error, stack) {
      callBack(ConnectResultInfo());
    });
    FlutterError.onError = (details) {
      if (details.stack == null) {
        FlutterError.presentError(details);
      }
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    };
  }

  static close({required RtkBluetoothConnectCallBack callBack}) async {
    final String result = await _channel.invokeMethod('close');
    Map<String, dynamic> resultMap = json.decode(result);
    callBack(ConnectResultInfo.fromJson(resultMap));
  }
}
