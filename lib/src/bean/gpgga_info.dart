import 'dart:math';

import 'package:rtk_bluetooth/src/bean/blh_info.dart';
import 'package:rtk_bluetooth/src/bean/rtk_location.dart';
import 'package:rtk_bluetooth/src/bean/utc_time.dart';

class GPGGAInfo {
  UtcTime utcTime = UtcTime();
  BLHInfo blh = BLHInfo();
  int? stateSloution;
  String? flagLongitude;
  String? flagLatitude;
  double? geoidalUndulation;
  int? satellitesNumber;
  double? hdop;
  String? baseId;
  double? age;
  bool? received;
  double? nTimeoutCount;
  double? hRMS = 0;
  double? vRMS = 0;
  double? speed = 0;

  bool isAvaliable() {
    return blh.latitude! > 0 && blh.longitude! > 0 && hRMS! < 100;
  }

  setSpeed(double speed) {
    this.speed = speed;
  }

  String getSignalTag() {
    String strSolutionState;
    switch (stateSloution) {
      case 0:
        strSolutionState = "无效解";
        break;
      case 1:
        strSolutionState = "单点解";
        break;
      case 2:
        strSolutionState = "差分解";
        break;
      case 4:
        strSolutionState = "固定解";
        break;
      case 5:
        strSolutionState = "浮点解";
        break;
      case 7:
        strSolutionState = "基站";
        break;

      default:
        strSolutionState = "未知";
        break;
    }

    return strSolutionState;
  }

  getGPGGA(String data) {
    try {
      int arrayMaxSize = 18;
      List<String> strArray = <String>[]..length = arrayMaxSize;

      int nIndex = 0;
      for (String subString in data.split(",")) {
        if (nIndex > arrayMaxSize) {
          break;
        }
        strArray[nIndex] = subString;
        nIndex++;
      }
      String strTem;
      //1.时间
      strTem = strArray[1];
      if (strTem.length < 6) {
        utcTime.hour = 0;
        utcTime.minute = 0;
        utcTime.second = 0;
      } else {
        utcTime.hour = int.parse(strTem.substring(0, 2)) + 8;
        utcTime.minute = int.parse(strTem.substring(2, 4));
        utcTime.second = double.parse(strTem.substring(4, 6));
      }
      //2.解算状态
      strTem = strArray[6];
      if (strTem.isEmpty) {
        stateSloution = 0;
      } else {
        stateSloution = int.parse(strTem);
      }
      //3.经纬度坐标
      strTem = strArray[2];
      if (strTem.length < 2) {
        blh.latitude = 0;
        return;
      } else {
        blh.latitude = double.parse(strTem.substring(0, 2)) +
            double.parse(strTem.substring(2)) / 60;
      }
      strTem = strArray[4];
      if (strTem.isEmpty || strTem.length < 2) {
        blh.longitude = 0;
        return;
      } else {
        blh.longitude = double.parse(strTem.substring(0, 3)) +
            double.parse(strTem.substring(3)) / 60;
      }
      //增加南北标识
      strTem = strArray[3];
      if (strTem.isNotEmpty) {
        flagLatitude = strTem.substring(0, 1);
      }
      if (strTem == 's' || strTem == "S") {
        blh.latitude = (blh.latitude! * -1);
      }

      strTem = strArray[5];
      if (strTem.isNotEmpty) {
        flagLongitude = strTem.substring(0, 1);
      }

      if (strTem == 'w' || strTem == "W") {
        blh.longitude = (blh.longitude! * -1);
      }
      //高层异常和椭球高
      strTem = strArray[11];
      geoidalUndulation = double.parse(strTem);
      strTem = strArray[9];
      blh.altitude = double.parse(strTem);
      //使用卫星数
      strTem = strArray[7];
      satellitesNumber = int.parse(strTem);
      //HDOP
      strTem = strArray[8];
      hdop = double.parse(strTem);
      //基准站ID
      strTem = strArray[14];
      baseId = strTem;
      //基站ID如果和校验项之间无逗号分割
      int nTmp = baseId!.indexOf('*');
      if (nTmp != -1) {
        List<String> arr = baseId!.split('*');
        baseId = arr[0];
      }
      //差分类型Age
      strTem = strArray[13];
      age = double.parse(strTem);
      received = true;
      nTimeoutCount = 0;
    } catch (e) {
      e.toString();
    }
  }

  //获取水平和垂直误差
  getGPGST(String data) {
    try {
      List<String> args = data.split(RegExp(r",|\\*"));
      if (args.length < 9) {
        return;
      }
      double hrms = double.parse(
          (pow(double.parse(args[6]), 2) + pow(double.parse(args[7]), 2))
              .toDouble()
              .toStringAsFixed(4));
      hRMS = hrms;
      vRMS = double.parse(args[8]);
    } catch (e) {
      e.toString();
    }
  }

  RTKLocation getLocation() {
    RTKLocation location = RTKLocation(
        latitude: blh.latitude!,
        longitude: blh.longitude!,
        speed: speed!,
        altitude: blh.altitude!,
        accuracy: hRMS! > 0 ? hRMS! : hdop!.toDouble(),
        signalTag: getSignalTag());
    return location;
  }
}
