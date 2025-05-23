import 'dart:async';
import 'dart:collection';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/isplaying.dart';
import 'package:my_app/tools.dart';
import 'discovery.dart';
import 'httpreq.dart';

class SearchResult extends StatefulWidget {
  final String searchText;
  final Function updateSearchHistory;

  const SearchResult({
    super.key,
    required this.searchText,
    required this.updateSearchHistory,
  });

  @override
  State<StatefulWidget> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult>
    with SingleTickerProviderStateMixin {
  late String _searchText;
  late TabController _tabController;
  late Future<dynamic> _future;
  late Future<dynamic> _future2;

  late List<Widget> _pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchText = widget.searchText;
    _tabController = TabController(length: 4, vsync: this);
    _future = HttpReq().searchSong(_searchText);
    _future2 = HttpReq().getUserInfo();
  }

  Builder _buildActionButton() {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: ClipOval(
            child: Image.network(
              pictureURL,
              fit: BoxFit.cover,
              loadingBuilder: (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child; // 图片加载完成时直接显示
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                    ),
                  );
                }
              },
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return Icon(Icons.error); // 加载失败时显示错误图标
              },
            ),
          ),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      actions: [_buildActionButton()],
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          SizedBox(width: 30),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 200, // 设置矩形条宽度
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50], // 设置灰色背景颜色
                  borderRadius: BorderRadius.circular(50), // 设置圆角
                ), // 设置矩形条高度
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.search), // 添加搜索放大镜图标
                    SizedBox(width: 10),
                    Text(_searchText, style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.blue,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: '综合'),
          Tab(text: '歌曲'),
          Tab(text: '歌手'),
          Tab(text: '专辑'),
        ],
      ),
    );
  }

  void simplePlayMusic(String id) async {
    var response = await HttpReq().getInfo(id);
    await audioPlayer.play(UrlSource(response['url']));
    await HttpReq().addPlayHistory(id);

    final duration = await audioPlayer.getDuration();
    if (!mounted) return;

    setState(() {
      songName = response['song_name'];
      singerName = response['singer'];
      songURL = response['url'];
      songObjectId = response['_id'];
      lyrics = response['lyrics'];
      pictureURL = response['picture'];
      totalDuration = duration!;
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
          currentSongList = [id];
          currentSongIndex = 0;
          simplePlayMusic(id);
        }
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // 允许内容自适应更高高度
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 关键点：让高度适应内容
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: SizedBox(height: 200, child: picture)),
                      SizedBox(height: 10),
                      Text(
                        translation != ""
                            ? "$songName ($translation)"
                            : songName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                            builder:
                                (_) =>
                                    Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );

                          HttpReq().getSonglist().then((res) {
                            Navigator.pop(context); // 关闭 loading dialog

                            List<ListTile> listTiles =
                                res.map<ListTile>((e) {
                                  return ListTile(
                                    leading: Icon(Icons.album),
                                    title: Text(e['songlist_name']),
                                    onTap: () {
                                      HttpReq().addSongToSonglist({
                                        "id": e['_id'],
                                        "song_id": id,
                                      });
                                      Tools().simpleDialog(
                                        context,
                                        "将歌曲添加至${e['songlist_name']}",
                                        Text("添加成功！"),
                                        () {},
                                        false,
                                      );
                                    },
                                  );
                                }).toList();

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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(40),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          _pages = [
            Center(child: CircularProgressIndicator()),
            Center(child: CircularProgressIndicator()),
            Center(child: CircularProgressIndicator()),
            Center(child: CircularProgressIndicator()),
          ];
          return TabBarView(
            controller: _tabController,
            children: _pages,
          ); // 加载中显示加载指示器
        } else if (snapshot.hasError) {
          return Text('加载错误！');
        } else {
          var data = snapshot.data;

          _pages = [
            buildPage1(data['all']),
            buildPage2(data['by_song']),
            buildPage3(data['by_singer']),
            buildPage4(data['by_album']),
          ];
          return TabBarView(controller: _tabController, children: _pages);
        }
      },
    );
  }

  Widget buildPage1(dynamic data) {
    List processedData = [];
    Map<String, dynamic> newHashMap = <String, dynamic>{};
    for (int i = 0; i < data.length; i++) {
      data[i].forEach((key, value) {
        newHashMap[key] = value;
      });
      Music music = Music(newHashMap);
      processedData.add(music);
    }
    return ListView.builder(
      itemCount: processedData.length, // 列表项的数量
      itemBuilder: (BuildContext context, int index) {
        return buildListTile(processedData[index]);
      },
    );
  }

  Widget buildPage2(dynamic data) {
    List processedData = [];
    Map<String, dynamic> newHashMap = <String, dynamic>{};
    for (int i = 0; i < data.length; i++) {
      data[i].forEach((key, value) {
        newHashMap[key] = value;
      });
      Music music = Music(newHashMap);
      processedData.add(music);
    }
    return ListView.builder(
      itemCount: processedData.length, // 列表项的数量
      itemBuilder: (BuildContext context, int index) {
        return buildListTile(processedData[index]);
      },
    );
  }

  Widget buildPage3(dynamic data) {
    List processedData = [];
    Map<String, dynamic> newHashMap = <String, dynamic>{};
    for (int i = 0; i < data.length; i++) {
      data[i].forEach((key, value) {
        newHashMap[key] = value;
      });
      Music music = Music(newHashMap);
      processedData.add(music);
    }
    return ListView.builder(
      itemCount: processedData.length, // 列表项的数量
      itemBuilder: (BuildContext context, int index) {
        return buildListTile(processedData[index]);
      },
    );
  }

  Widget buildPage4(dynamic data) {
    List processedData = [];
    Map<String, dynamic> newHashMap = <String, dynamic>{};
    for (int i = 0; i < data.length; i++) {
      data[i].forEach((key, value) {
        newHashMap[key] = value;
      });
      Music music = Music(newHashMap);
      processedData.add(music);
    }
    return ListView.builder(
      itemCount: processedData.length, // 列表项的数量
      itemBuilder: (BuildContext context, int index) {
        return buildListTile(processedData[index]);
      },
    );
  }

  Future<bool> _onWillPop() async {
    widget.updateSearchHistory(); // 调用回调函数来更新搜索历史
    return true; // 允许返回操作
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        endDrawer: IsPlaying(),
      ),
    );
  }
}

class Music {
  late String id;
  late String songName;
  late String singer;
  String? translation;
  late String album;
  late String description;
  late String url;
  late Widget picture; // 这里定义为 Widget 类型，因为它是 ClipRRect 包裹的 Image.network

  Music(Map<String, dynamic> info) {
    id = info['_id'] ?? '';
    songName = info['song_name'] ?? '';
    translation = info['translation'];
    singer = info['singer'] ?? '';
    album = info['album'] ?? '';
    description = info['description'] ?? '';
    url = info['url'] ?? '';
    picture = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(info['picture'] ?? ''),
    );
  }

  // 重写 hashCode 方法
  @override
  int get hashCode =>
      Object.hash(id, songName, singer, album, description, url, picture);

  // 重写 equals 方法
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Music && other.id == id;
  }
}
