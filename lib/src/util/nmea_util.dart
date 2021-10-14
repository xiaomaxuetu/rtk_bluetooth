abstract class NmeaUtil {
  void handleNmea(String nmea) {
    if (nmea.isEmpty) {
      return;
    }
    String dataType = nmea.substring(3, nmea.indexOf(","));
    switch (dataType) {
      case "GGA":
        handleGpgga(nmea);
        break;
      case "GSV":
        handleGpgsv(nmea);
        break;
      case "GST":
        handleGpgst(nmea);
        break;
      case "VTG":
        handleGpvtg(nmea);
        break;
      case "ZDA":
        handleGpzda(nmea);
        break;
      case "GSA":
        handleGpgsa(nmea);
        break;
      default:
        break;
    }
  }

  void handleGpgga(String gpgga);
  void handleGpgsv(String gpgsv);
  void handleGpgst(String gpgst);
  void handleGpgsa(String nmea);
  void handleGpzda(String nmea);
  void handleGpvtg(String nmea);
}
