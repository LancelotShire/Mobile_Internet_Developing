import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpReq{
  // static const String URL = 'https://backstage.lancelotshire.me/api';
  static const String URL = 'http://localhost:8000';

  Future getAllUsers() async {
    var url = Uri.parse('$URL/getAllUsers');
    print("getAllUsers-------------------------------------------------------");
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getAllSongs() async {
    var url = Uri.parse('$URL/getAllSongs');
    print("getAllMusics------------------------------------------------------");
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future updateUserInfo(Map body) async {
    var url = Uri.parse('$URL/updateUserInfo');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    print("updateUserInfo----------------------------------------------------");
    var res = await http.put(url,headers: headers,body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future updateSongInfo(Map body) async {
    var url = Uri.parse('$URL/updateSongInfo');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    print("updateSongInfo----------------------------------------------------");
    var res = await http.put(url,headers: headers,body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future deleteUser(String id) async {
    var url = Uri.parse('$URL/deleteUser/$id');
    print("deleteUser--------------------------------------------------------");
    var res = await http.delete(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future deleteSong(String id) async {
    var url = Uri.parse('$URL/deleteSong/$id');
    print("deleteSong--------------------------------------------------------");
    var res = await http.delete(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future addUser(Map body) async {
    var url = Uri.parse('$URL/register');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    print("addUser-----------------------------------------------------------");
    var res = await http.post(url,headers: headers,body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future addSong(Map body) async {
    var url = Uri.parse('$URL/addSong');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    print("addSong-----------------------------------------------------------");
    var res = await http.post(url,headers: headers,body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future login(Map body) async {
    var url = Uri.parse('$URL/login');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var res = await http.post(url, headers: headers, body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }
}