import 'package:flutter/material.dart';

class Tools {
  void simpleDialog(
    BuildContext context,
    String title,
    Widget content,
    Function confirm,
    bool hasConfirmation,
  ) {
    showDialog(
      context: context,
      builder: (context) {
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
            hasConfirmation
                ? TextButton(
                  child: Text("确认"),
                  onPressed: () {
                    confirm();
                    Navigator.of(context).pop(); // 关闭对话框
                    Tools().simpleDialog(
                      context,
                      title,
                      Text("$title成功！"),
                      () {},
                      false,
                    );
                  },
                )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
