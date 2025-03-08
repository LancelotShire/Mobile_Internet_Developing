import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'songlist.dart';
import 'profile.dart';
import 'httpreq.dart';

class Discovery extends StatefulWidget {
  const Discovery({super.key});

  @override
  State<StatefulWidget> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
  int _selectedIndex = 0;
  final AudioPlayer _player = AudioPlayer();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _playMusic() async {
    await _player.play(
      UrlSource(
        'https://static.lancelotshire.me/music/HOYO-MiX%20-%20Da%20Capo.mp3',
      ),
    ); // 本地音频
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
        return Center(child: Text('这是我的页'));

      default:
        return const Center(child: Text('Unknown Page!'));
    }
  }

  AppBar _buildAppBar(int index) {
    List<dynamic> text = ['发现', '歌单', '我的'];
    return AppBar(
      actions: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: AssetImage('assets/image/DaCapo.jpeg'),
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(text[index], style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Drawer _buildDrawer() {
    double _progress = 20;
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Scaffold(
        appBar: AppBar(
          title: Text('正在播放', style: TextStyle(fontWeight: FontWeight.w600)),
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
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/image/DaCapo.jpeg', // 用实际的图片URL替换
                        fit: BoxFit.cover,
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
                        'Da Capo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'HOYO-MiX',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(
                        height: 210,
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 70,
                                child: Center(
                                  child: Text(
                                    '这是已播放歌词',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 70,
                                child: Center(
                                  child: Text(
                                    '这是正在播放的歌词',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 70,
                                child: Center(
                                  child: Text(
                                    '这是未播放歌词',
                                    style: TextStyle(
                                      fontSize: 20,
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
                              value: _progress,
                              min: 0.0,
                              max: 100.0,
                              divisions: 100,
                              onChanged: (value) {
                                setState(() {
                                  _progress = value;
                                });
                              },
                              // thumbColor: Colors.lightBlue,
                              // activeColor: Colors.lightBlue,
                              // inactiveColor: Colors.grey,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 27.0,
                                  ), // 左右各添加16像素的内边距
                                  child: Text(
                                    '00:00',
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
                                    '03:45',
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
                                    onPressed: () async {
                                      await _player.pause();
                                    },
                                    iconSize: 50.0,
                                    color: Colors.blue,
                                    icon: Icon(Icons.skip_previous),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _playMusic();
                                    },
                                    iconSize: 75.0,
                                    color: Colors.lightBlue,
                                    icon: Icon(Icons.play_circle_fill),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    iconSize: 50.0,
                                    color: Colors.blue,
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
