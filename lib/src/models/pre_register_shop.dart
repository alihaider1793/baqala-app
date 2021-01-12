class PreRegisterShop {
  String success;
  String data;
  String message;

  PreRegisterShop();

  PreRegisterShop.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      success = jsonMap['success'] != null ? jsonMap['success'] : '';
      data = success = jsonMap['data'] != null ? jsonMap['data'] : '';
      message = success = jsonMap['message'] != null ? jsonMap['message'] : '';
    } catch (e) {
      print(e);
    }
  }
}
