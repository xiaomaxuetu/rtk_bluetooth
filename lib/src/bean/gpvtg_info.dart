class GPVTGInfo {
  String? mRealNorthDirt;
  String? mMagnNorthDirt;
  double? mSpeedKnot;
  double? mSpeedKilo;
  String? mModule;

  initFromStr(String str) {
    List<String> split = str.split(",");
    mRealNorthDirt = split[1];
    mMagnNorthDirt = split[3];
    if (split[5].isNotEmpty) {
      mSpeedKnot = double.parse(split[5]);
    }
    if (split[7].isNotEmpty) {
      mSpeedKilo = double.parse(split[7]);
    }
  }
}
