class DeviceInfo {
  String? name;
  String? address;
  DeviceInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
  }
}
