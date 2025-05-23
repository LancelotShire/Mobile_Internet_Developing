import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:my_app/loginPage.dart';
import 'package:my_app/modify.dart';
import 'package:my_app/myFavorite.dart';
import 'package:my_app/searchresult.dart';
import 'package:my_app/songlist.dart';
import 'package:my_app/tools.dart';
import 'httpreq.dart';
import 'searching.dart';
import 'isplaying.dart';

String USERID = "67d4f2ac2d40303e1077a608";

// Map dailyRecommendation = {};

String songName = "暂无播放";
String singerName = "";
String pictureURL =
    "http://p2.music.126.net/eDuh5s7BkMZDztreXYpvrA==/18225504742439648.jpg?param=177y177";
String songURL = "";
String songObjectId = "";
List currentSongList = [];
int currentSongIndex = 0;
List<dynamic> lyrics = [];
String formerLyric = "";
String currentLyric = "";
String nextLyric = "";
double progress = 0;
int isPlaying = 0;
Duration currentPosition = Duration.zero;
Duration totalDuration = Duration.zero;
final AudioPlayer audioPlayer = AudioPlayer();

Future<void> seekAudio(double value) async {
  final position = Duration(milliseconds: value.toInt());
  await audioPlayer.seek(position);
}

String formatDuration(Duration duration) {
  String minutes = duration.inMinutes.toString().padLeft(2, '0');
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return "$minutes:$seconds";
}

class Discovery extends StatefulWidget {
  const Discovery({super.key});

  @override
  State<StatefulWidget> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  late StreamSubscription<PlayerState>? _playerStateSubscription;
  late StreamSubscription<Duration>? _positionChangedSubscription;
  late StreamSubscription<void>? _playerCompleteSubscription;
  late Future _future;
  late Future _future2;
  late Future _dailyRecommendation;
  late Future _everyday;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Future<void> getDailyRecommendation() async {
  //   dailyRecommendation = await HttpReq().getRecommendedSinger();
  //   print(dailyRecommendation);
  // }

  @override
  void initState() {
    super.initState();
    _dailyRecommendation = HttpReq().getRecommendedSinger();
    _everyday = HttpReq().getEverydayRecommendation();

    _future2 = HttpReq().getUserInfo();

    _future = HttpReq().getPlayHistory();

    // 监听播放状态变化
    _playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((
      PlayerState state,
    ) {
      if (state == PlayerState.playing) {
        setState(() {
          isPlaying = 1;
        });
      }
    });

    // 监听音乐播放进度
    _positionChangedSubscription = audioPlayer.onPositionChanged.listen((
      position,
    ) {
      setState(() {
        currentPosition = position;
        if (currentPosition.inMilliseconds > 0 &&
            totalDuration.inMilliseconds > 0) {
          double progress1 =
              (currentPosition.inSeconds * 100) / totalDuration.inSeconds;
          progress = progress1;
          List lyr = Tools().lyricsAnalyzer(currentPosition, lyrics);
          formerLyric = lyr[0];
          currentLyric = lyr[1];
          nextLyric = lyr[2];
        }
      });
    });

    // 监听播放完成事件
    _playerCompleteSubscription = audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = 0;
        progress = 0;
        currentPosition = Duration(microseconds: 0);
      });
    });
  }

  @override
  void dispose() {
    // 取消播放状态变化的订阅
    _playerStateSubscription?.cancel();
    // 取消音乐播放进度的订阅
    _positionChangedSubscription?.cancel();
    // 取消播放完成事件的订阅
    _playerCompleteSubscription?.cancel();

    super.dispose();
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

  //注意这个是特制的
  ListTile buildListTile(Music music, List musicList) {
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
          currentSongList = musicList;
          currentSongIndex = musicList.indexOf(id);
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

  Future<Map> fetchAll() async {
    var historyList = await _future;
    var songInfoList = await HttpReq().getSonglistInfoByList(historyList);

    return {"historyList": historyList, "songInfoList": songInfoList};
  }

  FutureBuilder dailyRecommendationBuilder() {
    return FutureBuilder(
      future: _dailyRecommendation,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;
          String singer = data["singer"];
          List songlist = data['songlist'];
          List songInfoList = data['songInfoList'];
          List<Widget> listTiles = [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              width: double.infinity,
              child: Text(
                singer,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(height: 10),
          ];
          for (int i = 0; i < songInfoList.length; i++) {
            var currentData = songInfoList[i];
            Music music = Music(currentData);
            listTiles.add(buildListTile(music, songlist));
          }
          return Column(children: listTiles);
        } else if (snapshot.hasError) {
          return Text("错误！请重试！");
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Text(
                  "今日推荐",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FutureBuilder(
                  future: _everyday,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> sizedBoxes = [SizedBox(width: 20)];
                      var datas = snapshot.data;
                      for (int i = 0; i < datas.length; i++) {
                        var data = datas[i];
                        var songlistName = data['songlist_name'];
                        var song = data['song'];
                        var cover = data['cover'];

                        Widget sizedBox = InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MyFavorite(
                                      musicList: song,
                                      title: songlistName,
                                    ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  // 背景图
                                  SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: Image.network(
                                      cover,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // 底部模糊文字层
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: 80,
                                    child: ClipRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 5,
                                          sigmaY: 5,
                                        ),
                                        child: Container(
                                          color: Colors.white.withOpacity(
                                            0.2,
                                          ), // 可根据需求调整
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                songlistName,
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        sizedBoxes.add(sizedBox);
                        sizedBoxes.add(SizedBox(width: 20));
                      }
                      return Row(children: sizedBoxes);
                    } else if (snapshot.hasError) {
                      return Center(child: Text("加载错误，请重试！"));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Text(
                  "推荐歌手",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
                ),
              ),
              dailyRecommendationBuilder(),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Text(
                  "最近播放",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder(
                future: fetchAll(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data;
                    List<ListTile> listTiles = [];
                    List historyList = data?['historyList'];
                    List songInfoList = data?['songInfoList'];
                    for (int i = 0; i < songInfoList.length; i++) {
                      var currentData = songInfoList[i];
                      Music music = Music(currentData);
                      listTiles.add(buildListTile(music, historyList));
                    }
                    return Column(children: listTiles);
                  } else if (snapshot.hasError) {
                    return Text("错误！请重试！");
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        );

      case 1:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Text(
                  "资料库",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
                ),
              ),
              _buildPersonalPageListTile(3, () {
                // 待补全
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MyFavorite(
                          musicList: currentSongList,
                          title: "当前播放列表",
                        ),
                  ),
                );
              }),
              _buildPersonalPageListTile(4, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchingPage()),
                );
              }),
              _buildPersonalPageListTile(5, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Songlist()),
                );
              }),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Text(
                  "最近添加",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
                ),
              ),
              Wrap(
                children: [
                  SizedBox(
                    width: 186,
                    height: 220,
                    child: Column(
                      children: [
                        Material(
                          color: Colors.transparent, // 保证水波纹不遮背景色
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15), // 匹配容器圆角
                            onTap: () async {
                              var data = await HttpReq().getUserInfo();
                              List musicList = data['like'] ?? [];
                              if (!mounted) return; //确保 Widget 还“活着
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => MyFavorite(
                                        musicList: musicList,
                                        title: "我喜欢",
                                      ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  margin: EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue[50],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Icon(
                                      Icons.favorite,
                                      size: 75,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                Text(
                                  "我喜欢的音乐",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 2:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居中
            children: [
              SizedBox(height: 100),
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/image/avatar.png'),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: FutureBuilder(
                  future: HttpReq().getUserInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data;
                      return Text(
                        data["nickname"],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("发生错误！请重试！"));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: FutureBuilder(
                  future: HttpReq().getUserInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data;
                      return Text(
                        data['bio'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("发生错误！请重试！"));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(height: 15),
              _buildPersonalPageListTile(0, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Modify()),
                );
              }),
              _buildPersonalPageListTile(1, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchingPage()),
                );
              }),
              _buildPersonalPageListTile(2, () {
                showDialog(
                  context: context,
                  barrierDismissible: false, // 点击外部不关闭对话框
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: Text("退出登录"),
                      content: Text("确认退出登录？"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("取消"),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: Text("确认"),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // 先关闭对话框
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
            ],
          ),
        );

      default:
        return const Center(child: Text('Unknown Page!'));
    }
  }

  Widget _buildPersonalPageListTile(int i, Function f) {
    List titles = ['修改个人信息', '搜索', '退出登录', '播放列表', '搜索', '我的歌单'];
    List leadings = [
      Icons.person,
      Icons.search,
      Icons.exit_to_app,
      Icons.list,
      Icons.search,
      Icons.album,
    ];

    return ListTile(
      leading: Icon(leadings[i]),
      title: Text(
        titles[i],
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
      onTap: () {
        f();
      },
      tileColor: i % 2 == 0 ? Colors.grey[200] : Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
    );
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

  AppBar _buildAppBar(int index) {
    List<dynamic> text = ['发现', '歌单', '我的', '修改个人信息'];
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [_buildActionButton()],
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      toolbarHeight: 80,
      title:
          index == 0
              ? Row(
                children: [
                  Text(
                    text[index],
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchingPage(),
                          ),
                        );
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Text(
                text[index],
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
              ),
    );
  }

  IconButton _buildButton(int index) {
    return index == 0
        ? IconButton(
          onPressed: () {
            setState(() {
              if (progress == 0) {
                simplePlayMusic('67d4114d07125eb8445aa9cd');
              } else {
                audioPlayer.resume();
                isPlaying = 1;
              }
            });
          },
          iconSize: 75.0,
          color: Colors.grey[800],
          icon: Icon(Icons.play_circle_fill),
        )
        : IconButton(
          onPressed: () {
            setState(() {
              audioPlayer.pause();
              isPlaying = 0;
            });
          },
          icon: Icon(Icons.pause),
          iconSize: 75.0,
          color: Colors.grey[800],
        );
  }

  Drawer _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '正在播放',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30),
          ),
          toolbarHeight: 80,
        ),
        body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 顶部图片
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.width * 0.75,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
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
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
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
                  ),
                ),
                // 歌曲信息
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        songName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        singerName,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(
                        height: 180,
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 60,
                                child: Center(
                                  child: Text(
                                    formerLyric,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 60,
                                child: Center(
                                  child: Text(
                                    currentLyric,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 60,
                                child: Center(
                                  child: Text(
                                    nextLyric,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Slider(
                              value: progress,
                              min: 0.0,
                              max: 100.0,
                              divisions: 100,
                              onChanged: (value) {
                                setState(() {
                                  progress = value;
                                });
                                seekAudio(
                                  (value * totalDuration.inMilliseconds) / 100,
                                );
                              },
                              thumbColor: Color(0xAA4095E5),
                              activeColor: Color(0xAA4095E5),
                              inactiveColor: Colors.grey[400],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 27.0,
                                  ), // 左右各添加16像素的内边距
                                  child: Text(
                                    formatDuration(currentPosition),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 27.0,
                                  ), // 左右各添加16像素的内边距
                                  child: Text(
                                    formatDuration(totalDuration),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // 上一曲，下边是随便写的
                                      // simplePlayMusic(
                                      //   '67d52ce653f1422d22b65513',
                                      // );
                                      if (currentSongList != []) {
                                        simplePlayMusic(
                                          currentSongList[(currentSongIndex -
                                                  1) %
                                              currentSongList.length],
                                        );
                                        currentSongIndex =
                                            (currentSongIndex - 1) %
                                            currentSongList.length;
                                      }
                                    },
                                    iconSize: 50.0,
                                    color: Colors.grey[700],
                                    icon: Icon(Icons.skip_previous),
                                  ),
                                  // 暂停/播放键，较为麻烦故单独封装
                                  _buildButton(isPlaying),
                                  IconButton(
                                    onPressed: () {
                                      // //下一曲，下边是随便写的
                                      // simplePlayMusic(
                                      //   "67d4114d07125eb8445aa9d1",
                                      // );
                                      if (currentSongList != []) {
                                        simplePlayMusic(
                                          currentSongList[(currentSongIndex +
                                                  1) %
                                              currentSongList.length],
                                        );
                                        currentSongIndex =
                                            (currentSongIndex + 1) %
                                            currentSongList.length;
                                      }
                                    },
                                    iconSize: 50.0,
                                    color: Colors.grey[700],
                                    icon: Icon(Icons.skip_next),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: _buildAppBar(_selectedIndex),
      body: _buildBody(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'),
          BottomNavigationBarItem(icon: Icon(Icons.playlist_play), label: '歌单'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue,
        onTap: _onItemTapped,
      ),
      endDrawer: _buildDrawer(),
    );
  }
}
