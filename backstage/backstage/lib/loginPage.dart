import 'package:backstage/InfoPage.dart';
import 'package:flutter/material.dart';
import 'httpReq.dart';
import 'tools.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 背景淡蓝
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFEAF6FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),
                const Text(
                  '登录协律后台管理系统',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                Text("账号: "),
                Text("admin", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField("输入密码", passwordController, obscureText: true),
                const SizedBox(height: 32),
                _buildButton("登陆", Colors.blue, Colors.white, () async {
                  // 登录逻辑
                  if (passwordController.text != "") {
                    var body = {
                      "account": "admin",
                      "password": passwordController.text,
                    };

                    var res = await HttpReq().login(body);
                    var code = res["code"];

                    if (code == 0) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => InfoPage()),
                            (Route<dynamic> route) => false, // 移除所有旧页面
                      );
                    } else{
                      Tools().simpleDialog(
                        context,
                        "登录消息",
                        Text("密码错误！"),
                            () {},
                        false,
                      );
                      passwordController.clear();
                    }
                  }
                }),
                const SizedBox(height: 16),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        bool obscureText = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Color(0xFFF5F9FF),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildButton(
      String text,
      Color bgColor,
      Color textColor,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
