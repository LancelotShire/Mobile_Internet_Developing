import 'package:flutter/material.dart';
import 'package:my_app/discovery.dart';
import 'package:my_app/httpreq.dart';
import 'package:my_app/registerPage.dart';
import 'package:my_app/tools.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
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
                  '登录协律',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                _buildTextField("输入手机号", phoneController),
                const SizedBox(height: 16),
                _buildTextField("输入密码", passwordController, obscureText: true),
                const SizedBox(height: 32),
                _buildButton("登陆", Colors.blue, Colors.white, () async {
                  // 登录逻辑
                  if (passwordController.text != "" &&
                      phoneController.text != "") {
                    var body = {
                      "account": phoneController.text,
                      "password": passwordController.text,
                    };

                    var res = await HttpReq().login(body);
                    var code = res["code"];

                    if (code == 0) {
                      USERID = res['user'];
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Discovery()),
                        (Route<dynamic> route) => false, // 移除所有旧页面
                      );
                    } else if (code == 1) {
                      Tools().simpleDialog(
                        context,
                        "登录消息",
                        Text("密码错误！"),
                        () {},
                        false,
                      );
                      passwordController.clear();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                      Tools().simpleDialog(
                        context,
                        "登录消息",
                        Text("账户不存在！请先注册。"),
                        () {},
                        false,
                      );
                    }
                  }
                }),
                const SizedBox(height: 16),
                _buildButton("注册", Color(0xFFEAF6FF), Colors.black, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                }),
                const Spacer(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text.rich(
                      TextSpan(
                        text: '登录/注册表示您同意 ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        children: [
                          TextSpan(
                            text: '《用户协议》',
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(text: ' 和 '),
                          TextSpan(
                            text: '《隐私政策》',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
