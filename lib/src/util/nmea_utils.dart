import 'package:rtk_bluetooth/rtk_bluetooth.dart';
import 'package:rtk_bluetooth/src/bean/gpgga_info.dart';
import 'package:rtk_bluetooth/src/bean/gpvtg_info.dart';
import 'package:rtk_bluetooth/src/util/nmea_util.dart';

class NmeaUitls extends NmeaUtil {
  Function(RTKLocation location) locationCallBack;
  NmeaUitls({required this.locationCallBack});
  GPGGAInfo? info;
  @override
  void handleGpgga(String gpgga) {
    if (info != null) {
      RTKLocation location = info!.getLocation();

      locationCallBack(location);
    }
    info = GPGGAInfo();
    info!.getGPGGA(gpgga);
  }

  @override
  void handleGpgsa(String nmea) {}

  @override
  void handleGpgst(String gpgst) {
    if (info != null) {
      info!.getGPGST(gpgst);
    }
  }

  @override
  void handleGpgsv(String gpgsv) {
    //直接广播发出去？
    print(gpgsv);
  }

  @override
  void handleGpvtg(String nmea) {
    if (info != null) {
      GPVTGInfo gpvtgInfo = GPVTGInfo();
      gpvtgInfo.initFromStr(nmea);
      double speed = gpvtgInfo.mSpeedKilo!;
      speed = speed / 3.6;
      info!.setSpeed(speed);
    }
  }

  @override
  void handleGpzda(String nmea) {
    // TODO: implement handleGpzda
  }
}
