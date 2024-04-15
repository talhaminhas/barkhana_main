import 'dart:convert';
import 'package:http/http.dart';

class PsApiResponse {
  PsApiResponse(Response response) {
    code = response.statusCode;

    if (isSuccessful()) {
      body = response.body;
      errorMessage = '';
    } else {
      body = null;
      final dynamic hashMap = json.decode(response.body);
      print(hashMap['message']);
      errorMessage = hashMap['message'];
    }
  }
  int code = 0;
  String? body;
  String errorMessage = '';

  bool isSuccessful() {
    return code >= 200 && code < 300;
  }

  bool isUnauthorized() {
    return code == 401;
  }
}
