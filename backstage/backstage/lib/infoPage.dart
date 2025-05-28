import 'dart:math';
import 'dart:ui';

import 'package:backstage/httpReq.dart';
import 'package:backstage/tools.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int _selectedIndex = 0;
  late Future _personFuture;
  late Future _musicFuture;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _atarashiiPasswordController =
      TextEditingController();
  final TextEditingController _songNameController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  final TextEditingController _singerController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _pictureController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _personFuture = HttpReq().getAllUsers();
    _musicFuture = HttpReq().getAllSongs();
  }

  void refresh(){
    setState(() {
      _personFuture = HttpReq().getAllUsers();
      _musicFuture = HttpReq().getAllSongs();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AppBar _buildAppBar() {
    List<dynamic> texts = ['歌曲管理', '人员管理'];
    return AppBar(
      title: Text(
        texts[_selectedIndex],
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      toolbarHeight: 80,
      actions: [IconButton(onPressed: refresh, icon: Icon(Icons.refresh))],
    );
  }

  List<ListTile> buildPersonListTiles(List list) {
    ListTile listTile;
    List<ListTile> listTiles = [];
    for (int i = 0; i < list.length; i++) {
      var data = list[i];
      var id = data['_id'] ?? "";
      var nickname = data['nickname'] ?? "";
      var account = data['account'] ?? "";
      var bio = data['bio'] ?? "";
      var password = data['password'] ?? "";
      if(account == 'admin'){
        continue;
      }
      listTile = ListTile(
        leading: Image.asset("assets/image/avatar.png"),
        title: Text(nickname),
        subtitle: Text('$account\n$bio'),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _accountController.text = account;
                  _nicknameController.text = nickname;
                  _bioController.text = bio;
                  _atarashiiPasswordController.text = password;
                  Tools().simpleDialog(
                    context,
                    "修改个人信息",
                    SizedBox(
                      height: 250,
                      child: Column(
                        children: [
                          TextField(
                            controller: _accountController,
                            decoration: InputDecoration(
                              labelText: '请输入新账号',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _nicknameController,
                            decoration: InputDecoration(
                              labelText: '请输入新昵称',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _bioController,
                            decoration: InputDecoration(
                              labelText: '请输入新个人介绍',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _atarashiiPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: '请输入新密码',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    () {
                      var account = _accountController.text;
                      var nickname = _nicknameController.text;
                      var bio = _bioController.text;
                      var password = _atarashiiPasswordController.text;

                      Map body = {
                        'id': id,
                        'account': account,
                        'nickname': nickname,
                        'bio': bio,
                        'password': password,
                      };

                      HttpReq().updateUserInfo(body);

                      setState(() {
                        _personFuture = HttpReq().getAllUsers();
                      });
                    },
                    true,
                  );
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  Tools().simpleDialog(context, "删除用户", Text("确认删除该用户？"), () {
                    HttpReq().deleteUser(id);
                    setState(() {
                      _personFuture = HttpReq().getAllUsers();
                    });
                  }, true);
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
        ),
        isThreeLine: true,
      );
      listTiles.add(listTile);
    }
    return listTiles;
  }

  List<ListTile> buildMusicListTiles(List list) {
    ListTile listTile;
    List<ListTile> listTiles = [];
    for (int i = 0; i < list.length; i++) {
      var data = list[i];
      var id = data['_id'] ?? '';
      var songName = data['song_name'] ?? '';
      var translation = data['translation'] ?? '';
      var singer = data['singer'] ?? '';
      var album = data['album'] ?? '';
      var description = data['description'] ?? '';
      var url = data['url'] ?? '';
      var picture = data['picture'] ?? '';

      listTile = ListTile(
        leading: Icon(Icons.music_note),
        title:
            translation.trim().isEmpty
                ? Text(songName)
                : Text('$songName ($translation)'),
        subtitle: Text('$singer - 《$album》\n$translation'),
        isThreeLine: true,
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _songNameController.text = songName;
                  _translationController.text = translation;
                  _singerController.text = singer;
                  _albumController.text = album;
                  _descriptionController.text = description;
                  _urlController.text = url;
                  _pictureController.text = picture;

                  Tools().simpleDialog(
                    context,
                    "修改歌曲信息",
                    SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            TextField(
                              controller: _songNameController,
                              decoration: InputDecoration(
                                labelText: '请输入新歌曲名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _translationController,
                              decoration: InputDecoration(
                                labelText: '请输入新翻译名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _singerController,
                              decoration: InputDecoration(
                                labelText: '请输入新歌手名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _albumController,
                              decoration: InputDecoration(
                                labelText: '请输入新专辑名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: '请输入新描述',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _urlController,
                              decoration: InputDecoration(
                                labelText: '请输入新歌曲url',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _pictureController,
                              decoration: InputDecoration(
                                labelText: '请输入新专辑图url',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    () {
                      var song_name = _songNameController.text;
                      var translation = _translationController.text;
                      var singer = _singerController.text;
                      var album = _albumController.text;
                      var description = _descriptionController.text;
                      var url = _urlController.text;
                      var picture = _pictureController.text;

                      Map body = {
                        'id': id,
                        'song_name': song_name,
                        'translation': translation,
                        'singer': singer,
                        'album': album,
                        'description': description,
                        'url': url,
                        'picture': picture,
                      };
                      HttpReq().updateSongInfo(body);

                      setState(() {
                        _musicFuture = HttpReq().getAllSongs();
                      });
                    },
                    true,
                  );
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(onPressed: () {
                Tools().simpleDialog(context, "删除歌曲", Text("确认删除该歌曲？"), () {
                  HttpReq().deleteSong(id);

                  setState(() {
                    _musicFuture = HttpReq().getAllSongs();
                  });
                }, true);
              }, icon: Icon(Icons.delete)),
            ],
          ),
        ),
      );
      listTiles.add(listTile);
    }

    return listTiles;
  }

  Widget buildMusicManagement() {
    return FutureBuilder(
      future: _musicFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List data = snapshot.data;
          List<ListTile> listTiles = buildMusicListTiles(data);
          return SingleChildScrollView(child: Column(children: listTiles));
        } else if (snapshot.hasError) {
          return Center(child: Text("错误，请重试！"));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildPersonManagement() {
    return FutureBuilder(
      future: _personFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List data = snapshot.data;
          List<ListTile> listTiles = buildPersonListTiles(data);
          return SingleChildScrollView(child: Column(children: listTiles));
        } else if (snapshot.hasError) {
          return Center(child: Text("错误，请重试！"));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return buildMusicManagement();
      // return Center();
      case 1:
        return buildPersonManagement();
      default:
        return Center(child: Text("错误页！"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "歌曲管理"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "人员管理"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue,
        onTap: _onItemTapped,
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  _songNameController.clear();
                  _singerController.clear();
                  _albumController.clear();
                  _descriptionController.clear();
                  _translationController.clear();
                  _urlController.clear();
                  _pictureController.clear();

                  Tools().simpleDialog(
                    context,
                    "添加歌曲",
                    SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: _songNameController,
                              decoration: InputDecoration(
                                labelText: '请输入新歌曲名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _translationController,
                              decoration: InputDecoration(
                                labelText: '请输入新翻译名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _singerController,
                              decoration: InputDecoration(
                                labelText: '请输入新歌手名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _albumController,
                              decoration: InputDecoration(
                                labelText: '请输入新专辑名',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: '请输入新描述',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _urlController,
                              decoration: InputDecoration(
                                labelText: '请输入新歌曲url',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _pictureController,
                              decoration: InputDecoration(
                                labelText: '请输入新专辑图url',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    () {
                      var song_name = _songNameController.text;
                      var translation = _translationController.text;
                      var singer = _singerController.text;
                      var album = _albumController.text;
                      var description = _descriptionController.text;
                      var url = _urlController.text;
                      var picture = _pictureController.text;

                      Map body = {
                        'song_name': song_name,
                        'translation': translation,
                        'singer': singer,
                        'album': album,
                        'description': description,
                        'url': url,
                        'picture': picture,
                      };

                      HttpReq().addSong(body);

                      setState(() {
                        _musicFuture = HttpReq().getAllSongs();
                      });
                    },
                    true,
                  );
                },
                tooltip: "添加歌曲",
                child: Icon(Icons.add),
              )
              : FloatingActionButton(
                onPressed: () {
                  _nicknameController.clear();
                  _accountController.clear();
                  _bioController.clear();
                  _atarashiiPasswordController.clear();

                  Tools().simpleDialog(
                    context,
                    "添加用户",
                    SizedBox(
                      height: 150,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          TextField(
                            controller: _accountController,
                            decoration: InputDecoration(
                              labelText: '请输入新账号',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            obscureText: true,
                            controller: _atarashiiPasswordController,
                            decoration: InputDecoration(
                              labelText: '请输入密码',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    () {
                      var account = _accountController.text;
                      var password = _atarashiiPasswordController.text;
                      Map body = {'account': account, 'password': password};

                      HttpReq().addUser(body);

                      setState(() {
                        _personFuture = HttpReq().getAllUsers();
                      });
                    },
                    true,
                  );
                },
                tooltip: "添加用户",
                child: Icon(Icons.add),
              ),
    );
  }
}
