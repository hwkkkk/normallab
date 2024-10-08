import 'package:flutter/material.dart';
import 'package:project_lab/Home.dart';
import 'package:project_lab/color.dart';
import 'package:project_lab/author.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _login = AuthService();

  @override
  void dispose() {
    // 화면이 종료될 때 컨트롤러 해제
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _in() async {
    String id_in = _idController.text+"@naver.com";
    String pw_in = _passwordController.text;

    try {
      User? user = await _login.logIn(id_in, pw_in); // 로그인 로직
      if (user != null) {
        print('로그인 성공: ${user.email}');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        // 로그인 성공 시 다음 페이지로 이동하는 로직 추가
      } else {
        print('로그인 실패');
        // 로그인 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패')),
        );
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: main_color, // AppBar의 배경 색상
        elevation: 0, // AppBar의 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 아이콘 설정
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 동작
          },
        ),
        title: Text(
          '로그인',
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'asset/logo.png',
                width: 300,
                height: 200,
              ),
              SizedBox(height: 20),
              Container(
                child: TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: '아이디',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                width: 320,
              ),
              SizedBox(height: 20),
              Container(
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                   // 비밀번호를 숨김 처리
                ),
                width: 320,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _in, // 로그인 버튼 클릭 시 _in 메서드 호출
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(320, 48), // 각 버튼의 최소 크기 설정
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // 패딩 설정
                  backgroundColor: main_color, // 배경 색상
                  foregroundColor: Colors.black, // 텍스트 색상
                  elevation: 0, // 버튼의 그림자 제거
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  '로그인',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
