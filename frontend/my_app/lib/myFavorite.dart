import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:my_app/httpreq.dart';
import 'package:my_app/tools.dart';
import 'searchresult.dart';
import 'discovery.dart';

class MyFavorite extends StatefulWidget {
  final List musicList;
  final String title;

  const MyFavorite({super.key, required this.musicList, required this.title});

  @override
  State<StatefulWidget> createState() => _MyFavoriteState();
}

class _MyFavoriteState extends State<MyFavorite> {
  late Future _future2;
  late Future _futureMusics;

  @override
  void initState() {
    super.initState();
    _futureMusics = loadMusicList();
    _future2 = HttpReq().getUserInfo();
    loadMusicList(); // 调用异步加载函数
  }

  Future<List<Music>> loadMusicList() async {
    // 直接调用你的后端一次性接口
    final data = await HttpReq().getSonglistInfoByList(widget.musicList);
    List<Music> musics = [];
    for (int i = 0;i< data.length;i++){
      var music = Music(data[i]);
      musics.add(music);
    }
    return musics;
  }

  void simplePlayMusic(String id) async {
    var response = await HttpReq().getInfo(id);
    await audioPlayer.play(UrlSource(response['url']));
    await HttpReq().addPlayHistory(id);
    final duration = await audioPlayer.getDuration();

    if (!mounted) return;

    setState(() {
      songName = response['song_name'] ?? "";
      singerName = response['singer'] ?? "";
      songURL = response['url'] ?? "";
      songObjectId = response['_id'] ?? "";
      lyrics = response['lyrics'] ?? []; // 关键点！
      pictureURL = response['picture'] ?? "";
      totalDuration = duration ?? Duration.zero;
      isPlaying = 1;
    });
  }

  ListTile buildListTile(Music music) {
    final Widget picture = music.picture ?? Icon(Icons.music_note);
    final String songName = music.songName ?? "未知歌曲";
    final String translation = music.translation ?? "";
    final String singer = music.singer ?? "未知歌手";
    final String album = music.album ?? "未知专辑";
    final String description = music.description ?? "";
    final dynamic id = music.id;

    final bool hasDescription = description.isNotEmpty;

    return ListTile(
      leading: picture,
      trailing: SizedBox(
        width: 40, // 或者你也可以用更宽一点的数值，比如 48
        child: FutureBuilder(
          future: HttpReq().getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data;
              final List like = data?['like'] ?? [];
              final bool isLiked = like.contains(id);
              return IconButton(
                onPressed: () async {
                  if (isLiked) {
                    await HttpReq().deleteItemFromLike(id);
                  } else {
                    await HttpReq().addItemToLike(id);
                  }
                  setState(() {
                    _future2 =
                        HttpReq()
                            .getUserInfo(); // 确保赋值新的 Future，触发 FutureBuilder 刷新
                  });
                },
                icon: Icon(Icons.favorite, color: isLiked ? Colors.red : null),
              );
            } else if (snapshot.hasError) {
              return Icon(Icons.error, color: Colors.red);
            } else {
              return Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
          },
        ),
      ),
      title: Text(
        translation.isEmpty ? songName : "$songName ($translation)",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      dense: true,
      subtitle:
          hasDescription
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$singer - 《$album》", style: TextStyle(fontSize: 13)),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )
              : Text("$singer - 《$album》"),
      isThreeLine: hasDescription,
      onTap: () {
        if (songObjectId == id && isPlaying == 1) {
          audioPlayer.pause();
          isPlaying = 0;
        } else if (songObjectId == id && isPlaying == 0) {
          audioPlayer.resume();
          isPlaying = 1;
        } else {
          currentSongList = widget.musicList;
          currentSongIndex = widget.musicList.indexOf(id);
          simplePlayMusic(id);
        }
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: SizedBox(height: 200, child: picture)),
                  SizedBox(height: 10),
                  Text(
                    translation != "" ? "$songName ($translation)" : songName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text("$singer - 《$album》"),
                  SizedBox(height: 6),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.skip_next),
                    label: Text('下一曲播放'),
                    onPressed: () {
                      Navigator.pop(context);
                      // 执行下一曲播放逻辑
                      currentSongList.insert(currentSongIndex + 1, id);
                      Tools().simpleDialog(
                        context,
                        "添加至下一曲播放",
                        Text("添加至下一曲播放成功！"),
                        () {},
                        false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(40),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.playlist_add),
                    label: Text('添加至歌单'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return Center(child: CircularProgressIndicator());
                        },
                        barrierDismissible: false,
                      );

                      HttpReq().getSonglist().then((res) {
                        Navigator.pop(context); // 关闭 loading dialog

                        List<ListTile> listTiles = [];
                        for (int i = 0; i < res.length; i++) {
                          listTiles.add(
                            ListTile(
                              leading: Icon(Icons.album),
                              title: Text(res[i]['songlist_name']),
                              onTap: () {
                                //实现逻辑
                                HttpReq().addSongToSonglist({
                                  "id": res[i]['_id'],
                                  "song_id": id,
                                });
                                String songlistName = res[i]['songlist_name'];
                                Tools().simpleDialog(
                                  context,
                                  "将歌曲添加至$songlistName",
                                  Text("添加成功！"),
                                  () {},
                                  false,
                                );
                              },
                            ),
                          );
                        }
                        Tools().simpleDialog(
                          context,
                          "将歌曲添加到歌单",
                          SizedBox(
                            width: 500,
                            height: 300,
                            child: SingleChildScrollView(
                              child: Column(children: listTiles),
                            ),
                          ),
                          () {},
                          false,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(40),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.close),
                    label: Text('关闭'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(40),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: _futureMusics,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;
          List<Widget> listTiles = [];
          if (data.length == 0) {
            return Center(child: Text("歌单为空"));
          }
          for (int i = 0; i < data.length; i++) {
            ListTile l = buildListTile(data[i]);
            listTiles.add(l);
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: listTiles,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("加载错误，请重试！"));
        } else {
          return Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildBody(),
    );
  }
}
