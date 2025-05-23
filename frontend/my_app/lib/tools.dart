import 'package:flutter/material.dart';
import 'package:my_app/httpreq.dart';

class Tools {
  List lyricsAnalyzer(Duration duration, List lyrics) {
    var time = duration.inSeconds+0.1;
    String formerLyric = "";
    String currentLyric = "";
    String nextLyric = "";
    for(int i = 0;i < lyrics.length;i++){
      if ((time>=lyrics[i][0]&&i+1==lyrics.length)||(time>=lyrics[i][0]&&time<lyrics[i+1][0])){
        if(i-1>=0){
          formerLyric = lyrics[i-1][1];
        }
        if(i+1<lyrics.length){
          nextLyric = lyrics[i+1][1];
        }
        currentLyric = lyrics[i][1];
        break;
      }
    }
    return [formerLyric,currentLyric,nextLyric];
  }

  void simpleDialog(BuildContext context,String title,Widget content,Function confirm, bool hasConfirmation){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
       title: Text(title),
       content: content,
        actions: [
          TextButton(
            child: Text("关闭"),
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
            },
          ),
          hasConfirmation? TextButton(
            child: Text("确认"),
            onPressed: () {
              confirm();
              Navigator.of(context).pop(); // 关闭对话框
              Tools().simpleDialog(context, title, Text("$title成功！"), () {}, false);
            },
          ): SizedBox.shrink(),
        ],
      );
    });
  }

  Future<bool> isLiked(String id) async {
    var data = await HttpReq().getUserInfo();
    var likes = data['like'];
    bool result = false;
    if (likes.contains(id)){
      result = true;
    }
    return result;
  }
}