import 'package:flutter/material.dart';
import 'package:my_app/httpreq.dart';
import 'package:my_app/tools.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 背景渐变
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFEAF6FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    '注册',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField("输入手机号", phoneController),
                  const SizedBox(height: 12),
                  _buildTextField("输入密码", passwordController, obscureText: true),
                  const SizedBox(height: 12),
                  _buildTextField("再输入一次密码", confirmPasswordController, obscureText: true),
                  const SizedBox(height: 12),
                  _buildVerifyCodeField(codeController),
                  const SizedBox(height: 24),
                  _buildButton("注册", Colors.blue, Colors.white, () async {
                    if(passwordController.text == confirmPasswordController.text){
                      Map body = {
                        "account": phoneController.text,
                        "password": passwordController.text
                      };
                      var result = await HttpReq().register(body);
                      if (result["code"] == 0){
                        Tools().simpleDialog(context, "注册成功", Text("现在即可返回登录。"), () {}, false);
                      } else {
                        Tools().simpleDialog(context, "注册失败", Text("该账号已经存在。"), () {}, false);
                      }
                    } else {
                      Tools().simpleDialog(context, "两次密码不一致", Text("两次密码不一致，请重新输入。"), () {}, false);
                      passwordController.clear();
                      confirmPasswordController.clear();
                    }
                  }),
                  const Spacer(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text.rich(
                        TextSpan(
                          text: '注册表示您同意 ',
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
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Color(0xFFF5F9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildVerifyCodeField(TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField("验证码", controller),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            // 发送验证码逻辑
          },
          child: Text(
            "发送验证码",
            style: TextStyle(color: Colors.blue, fontSize: 14),
          ),
        )
      ],
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            Positioned(
              right: 12,
              child: Icon(Icons.bolt, color: Colors.white.withOpacity(0.6), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
