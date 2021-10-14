class ConnectResultInfo {
  String? message = "";
  bool? isSuccess = false;

  ConnectResultInfo();

  ConnectResultInfo.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    isSuccess = json['isSuccess'];
  }
}
