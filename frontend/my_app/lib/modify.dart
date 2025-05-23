import 'package:flutter/material.dart';
import 'package:my_app/discovery.dart';
import 'package:my_app/httpreq.dart';
import 'tools.dart';

class Modify extends StatefulWidget {
  const Modify({super.key});

  @override
  State<StatefulWidget> createState() => _ModifyState();
}

class _ModifyState extends State<Modify> {
  late Future<dynamic> _future;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = HttpReq().getUserInfo();
  }

  List<ListTile> _buildListTile(String nickname, String bio) {
    List<String> titles = ["昵称", "自我介绍"];
    List<Icon> icons = [Icon(Icons.person), Icon(Icons.info)];
    List<ListTile> listTiles = [
      ListTile(
        leading: icons[0],
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        title: Text(nickname),
        dense: true,
        subtitle: Text(titles[0]),
        onTap: () async {
          final newName = await showDialog<String>(
            context: context,
            builder: (context) {
              TextEditingController _controller = TextEditingController();
              return AlertDialog(
                title: Text('修改昵称'),
                content: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: '请输入新昵称',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), // 取消
                    child: Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _controller.text); // 返回输入值
                    },
                    child: Text('确认'),
                  ),
                ],
              );
            },
          );

          if (newName != null && newName.isNotEmpty) {
            await HttpReq().updateUserInfo({
              "id": USERID,
              "nickname": newName,
            });
            setState(() {
              _future = HttpReq().getUserInfo();
            });
          }
        },
      ),
      ListTile(
        leading: icons[1],
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        title: Text(bio),
        dense: true,
        subtitle: Text(titles[1]),
        onTap: () async {
          final newBio = await showDialog<String>(
            context: context,
            builder: (context) {
              TextEditingController _controller1 = TextEditingController();
              return AlertDialog(
                title: Text('修改自我介绍'),
                content: TextField(
                  controller: _controller1,
                  decoration: InputDecoration(
                    labelText: '请输入新自我介绍',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3, // 自我介绍一般可以多行
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), // 取消
                    child: Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _controller1.text); // 返回输入内容
                    },
                    child: Text('确认'),
                  ),
                ],
              );
            },
          );

          if (newBio != null && newBio.isNotEmpty) {
            await HttpReq().updateUserInfo({
              "id": USERID,
              "bio": newBio,
            });
            setState(() {
              _future = HttpReq().getUserInfo();
            });
          }
        },
      ),
      ListTile(
        leading: Icon(Icons.password),
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        title: Text("点击修改密码"),
        onTap: () {
          Tools().simpleDialog(
            context,
            "修改密码",
            IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min, // 关键，防止占满父容器
                children: [
                  TextField(
                    controller: _controller2,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '请输入旧密码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10), // 增加分隔美观
                  TextField(
                    controller: _controller3,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '请输入新密码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _controller4,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '请再输入一次新密码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            () {
              bool allowed = false;
              if((_controller3.text == _controller4.text)){
                // 验证原密码流程
              }
            },
            true,
          );
        },
      ),
    ];
    return listTiles;
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;
          List<Widget> children = _buildListTile(data["nickname"], data["bio"]);
          return Column(children: children);
        } else if (snapshot.hasError) {
          return const Center(child: Text("错误！请重试！"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: 80,
        title: Text(
          "修改个人信息",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
        ),
      ),
      body: _buildBody(),
    );
  }
}
