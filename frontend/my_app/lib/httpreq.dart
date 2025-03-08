import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpReq {
  static const String URL = 'http://10.0.2.2:8000';

  Future test() async {
    var url = Uri.parse('$URL/');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future 

}