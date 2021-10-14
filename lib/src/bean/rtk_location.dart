import 'package:rtk_bluetooth/rtk_bluetooth.dart';

class RTKLocation {
  double latitude;
  double longitude;
  double speed;
  double altitude;
  double accuracy;
  String signalTag;

  RTKLocation(
      {required this.latitude,
      required this.longitude,
      required this.speed,
      required this.altitude,
      required this.accuracy,
      required this.signalTag});
}
