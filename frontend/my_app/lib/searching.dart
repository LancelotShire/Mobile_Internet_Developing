import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:my_app/searchresult.dart';
import 'package:my_app/tools.dart';
import 'discovery.dart';
import 'httpreq.dart';

class SearchingPage extends StatefulWidget {
  const SearchingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchingPageState();
}

class _SearchingPageState extends State<SearchingPage> {
  late StreamSubscription<PlayerState>? _playerStateSubscription;
  late StreamSubscription<Duration>? _positionChangedSubscription;
  late StreamSubscription<void>? _playerCompleteSubscription;
  late FocusNode _searchFocusNode;
  final TextEditingController _searchController = TextEditingController();
  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _future = HttpReq().getSearchHistory();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });

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

  AppBar _buildAppBar() {
    return AppBar(
      actions: [_buildActionButton()],
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          SizedBox(width: 20),
          Expanded(
            child: SearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              elevation: WidgetStateProperty.all(0),
              leading: Icon(Icons.search),
              onSubmitted: (value) {
                if (_searchController.text != "") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SearchResult(
                            searchText: _searchController.text,
                            updateSearchHistory: _updateSearchHistory,
                          ),
                    ),
                  );
                  HttpReq().addSearchHistory(_searchController.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                                      // simplePlayMusic(
                                      //   '67d4114d07125eb8445aa9cf',
                                      // );
                                      if(currentSongList != []){
                                        simplePlayMusic(currentSongList[(currentSongIndex - 1)%currentSongList.length]);
                                        currentSongIndex =(currentSongIndex - 1)%currentSongList.length;
                                      }
                                    },
                                    iconSize: 50.0,
                                    color: Colors.grey[700],
                                    icon: Icon(Icons.skip_previous),
                                  ),
                                  _buildButton(isPlaying),
                                  IconButton(
                                    onPressed: () {
                                      // simplePlayMusic(
                                      //   "67d4114d07125eb8445aa9d1",
                                      // );
                                      if(currentSongList != []){
                                        simplePlayMusic(currentSongList[(currentSongIndex + 1)%currentSongList.length]);
                                        currentSongIndex =(currentSongIndex + 1)%currentSongList.length;
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

  Widget _buildSearchHistoryButton() {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> searchHistory = snapshot.data['search_history'];
          List<Widget> buttons = [];
          for (int i = 0; i < searchHistory.length; i++) {
            ElevatedButton button = ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SearchResult(
                          searchText: searchHistory[i],
                          updateSearchHistory: _updateSearchHistory,
                        ),
                  ),
                );
              },
              child: Text(searchHistory[i]),
            );
            buttons.add(button);
            buttons.add(SizedBox(width: 10));
          }
          return Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            children: buttons,
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("错误！请重试！"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _deleteSearchHistory() async {
    await HttpReq().deleteSearchHistory(); // 假设这是删除搜索历史的 API 调用
    setState(() {
      _future = HttpReq().getSearchHistory(); // 删除后重新请求最新的搜索历史
    });
  }

  // 处理返回时更新数据
  void _updateSearchHistory() {
    setState(() {
      _future = HttpReq().getSearchHistory(); // 重新请求最新的搜索历史
    });
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 20),
            Text(
              "搜索历史",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            IconButton(
              onPressed: () {
                _deleteSearchHistory();
              },
              icon: Icon(Icons.delete_outline),
            ),
          ],
        ),
        SizedBox(height: 20),
        //后边需要放按钮
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: _buildSearchHistoryButton(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      endDrawer: _buildDrawer(),
      body: _buildBody(),
    );
  }
}
