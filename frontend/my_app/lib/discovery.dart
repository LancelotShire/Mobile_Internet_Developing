import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:my_app/tools.dart';
import 'httpreq.dart';
import 'searching.dart';
import 'isplaying.dart';

String songName = "暂无播放";
String singerName = "";
String pictureURL =
    "http://p2.music.126.net/eDuh5s7BkMZDztreXYpvrA==/18225504742439648.jpg?param=177y177";
String songURL = "";
String songObjectId = "";
List currentSongList = [];
int currentPlayStatus = 0;
String nextSong = "";
bool isLiked = false;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // 监听播放状态变化
    _playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        setState(() {
          isPlaying = 1;
        });
      }
    });

    // 监听音乐播放进度
    _positionChangedSubscription = audioPlayer.onPositionChanged.listen((position) {
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

  void simplePlayMusic(String Id) async {
    var response = await HttpReq().getInfo(Id);
    await audioPlayer.play(UrlSource(response['url']));
    setState(() async {
      totalDuration = (await audioPlayer.getDuration())!;
      pictureURL = response['picture'];
      songName = response['song_name'];
      singerName = response['singer'];
      songURL = response['url'];
      songObjectId = response['_id'];
      lyrics = response['lyrics'];
    });
    isPlaying = 1;
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return Center(
          child: FutureBuilder(
            future: HttpReq().test(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(child: Text(snapshot.data['message']));
              } else if (snapshot.hasError) {
                return const Center(child: Text("错误！请重试！"));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );

      case 1:
        return Center(child: Text('这是歌单页'));

      case 2:
        return Center(
          child: ElevatedButton(
            onPressed: () {
              simplePlayMusic("67d3ef835507910649d68893");
            },
            child: Text("点我播放青空"),
          ),
        );

      default:
        return const Center(child: Text('Unknown Page!'));
    }
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
    List<dynamic> text = ['发现', '歌单', '我的'];
    return AppBar(
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
                  SizedBox(width: 25),
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
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // 设置灰色背景颜色
                          borderRadius: BorderRadius.circular(25), // 设置圆角
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
                                      simplePlayMusic(
                                        '67d4114d07125eb8445aa9cf',
                                      );
                                    },
                                    iconSize: 50.0,
                                    color: Colors.grey[700],
                                    icon: Icon(Icons.skip_previous),
                                  ),
                                  _buildButton(isPlaying),
                                  IconButton(
                                    onPressed: () {
                                      simplePlayMusic(
                                        "67d4114d07125eb8445aa9d1",
                                      );
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
