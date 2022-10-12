import 'package:fluttertoast/fluttertoast.dart';

class Utilis {
  static String url = 'http://127.0.0.1:8000/';

  static toatsMessage(String message) {
    Fluttertoast.showToast(msg: message);
  }
}
