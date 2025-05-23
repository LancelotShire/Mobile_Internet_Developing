import 'package:flutter/material.dart';
import 'package:my_app/httpreq.dart';
import 'package:my_app/myFavorite.dart';
import 'package:my_app/tools.dart';

class Songlist extends StatefulWidget {
  const Songlist({super.key});

  @override
  State<StatefulWidget> createState() => _SonglistState();
}

class _SonglistState extends State<Songlist> {
  List songlists = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshSonglists();
  }

  Future<void> refreshSonglists() async {
    var data = await HttpReq().getSonglist();
    if (mounted) {
      setState(() {
        songlists = data;
      });
    }
  }

  Widget _buildBody() {
    List<ListTile> listTiles = [];
    for (int i = 0; i < songlists.length; i++) {
      var data = songlists[i];
      var songlistName = data['songlist_name'];
      var id = data["_id"];
      ListTile listTile = ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        leading: Icon(Icons.album),
        title: Text(songlistName),
        onTap: () async {
          var data = await HttpReq().getSonglistInfo(id);
          var musicList = data['song'];
          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MyFavorite(musicList: musicList, title: songlistName),
            ),
          );
        },
        onLongPress: () async {
          Tools().simpleDialog(
            context,
            "删除$songlistName",
            Text("你确定要删除$songlistName吗？"),
            () async {// 关闭对话框
              await HttpReq().deleteSonglist(id);
              await refreshSonglists();
            },
            true,
          );
        },
      );
      listTiles.add(listTile);
    }
    return SingleChildScrollView(child: Column(children: listTiles));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("我的歌单")),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Tools().simpleDialog(
            context,
            "创建歌单",
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '请输入歌单名',
                border: OutlineInputBorder(),
              ),
            ),
            () async {// 关闭弹窗
              await HttpReq().addSonglist(_controller.text);
              _controller.clear();
              await refreshSonglists();
            },
            true,
          );
        },
        tooltip: "创建歌单",
        child: Icon(Icons.add),
      ),
    );
  }
}
