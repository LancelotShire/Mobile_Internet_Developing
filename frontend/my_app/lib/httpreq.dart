import 'dart:convert';
import 'package:http/http.dart' as http;
import 'discovery.dart';

class HttpReq {
  // static const String URL = 'http://192.168.1.101:8000';
  // static const String URL = 'http://10.0.2.2:8000';
  static const String URL = 'http://lancelotshire.me:8000';

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

  Future searchSong(String name) async {
    var url = Uri.parse('$URL/search?name=$name');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getInfo(String id) async {
    var url = Uri.parse('$URL/getInfo/$id');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future addSearchHistory(String searchHistory) async {
    var url = Uri.parse('$URL/addSearchHistory');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      'user_id': USERID,
      'search_history': searchHistory,
    };
    var res = await http.post(url, headers: headers, body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getSearchHistory() async {
    var url = Uri.parse('$URL/getSearchHistory/$USERID');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future deleteSearchHistory() async {
    var url = Uri.parse('$URL/deleteSearchHistory/$USERID');
    var res = await http.delete(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getUserInfo() async {
    var url = Uri.parse('$URL/getUserInfo/$USERID');
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
    var res = await http.put(url, headers: headers, body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future addItemToLike(String id) async {
    var data = await getUserInfo();
    List like = data['like'];
    like.add(id);

    var url = Uri.parse('$URL/updateUserInfo');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map body = {"id": USERID, "like": like};
    var res = await http.put(url, headers: headers, body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future deleteItemFromLike(String id) async {
    var data = await getUserInfo();
    List like = data['like'];
    like.remove(id);

    var url = Uri.parse('$URL/updateUserInfo');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map body = {"id": USERID, "like": like};
    var res = await http.put(url, headers: headers, body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getSonglist() async {
    var url = Uri.parse('$URL/getSonglist/$USERID');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getSonglistInfo(String id) async {
    var url = Uri.parse('$URL/getSonglistInfo/$id');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getSonglistInfoByList(List musicList) async {
    var url = Uri.parse('$URL/getSonglistInfoByList');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map body = {"songlist": musicList};

    var res = await http.post(url, headers: headers, body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future addSonglist(String songlistName) async {
    var url = Uri.parse('$URL/addSonglist');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      'user_id': USERID,
      'songlist_name': songlistName,
    };
    var res = await http.post(url, headers: headers, body: jsonEncode(body));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future deleteSonglist(String id) async {
    var url = Uri.parse('$URL/deleteSonglist/$id');
    var res = await http.delete(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future addSongToSonglist(Map data) async {
    var url = Uri.parse('$URL/addSongToSonglist');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var res = await http.put(url, headers: headers, body: jsonEncode(data));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future addPlayHistory(String history) async {
    var url = Uri.parse('$URL/addPlayHistory');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var data = {
      "user_id": USERID,
      "play_history": history
    };
    var res = await http.put(url, headers: headers, body: jsonEncode(data));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getPlayHistory() async {
    var url = Uri.parse('$URL/getPlayHistory/$USERID');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getRecommendedSinger() async {
    var url = Uri.parse('$URL/getRecommendedSinger');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getEverydayRecommendation() async {
    var url = Uri.parse('$URL/getEverydayRecommendation');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future register(Map body) async {
    var url = Uri.parse('$URL/register');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var res = await http.post(url, headers: headers, body: jsonEncode(body));

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
