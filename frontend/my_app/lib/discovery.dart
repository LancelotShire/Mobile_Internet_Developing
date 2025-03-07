import 'package:flutter/material.dart';
import 'songlist.dart';
import 'profile.dart';
import 'playing.dart';

class Discovery extends StatefulWidget {
  const Discovery({super.key});

  @override
  State<StatefulWidget> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return Center(child: Text('这是发现页'));

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
                backgroundImage: AssetImage('assets/image/avatar.png'),
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(text[index]),
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
      endDrawer: buildDrawer(),
    );
  }
}
