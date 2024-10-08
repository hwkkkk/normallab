import 'package:flutter/material.dart';
import 'package:project_lab/color.dart';
import 'package:project_lab/login.dart';
import 'package:project_lab/membership.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: main_color, // 원하는 배경 색 설정
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CIA',
                style: TextStyle(
                  color: Color(0xFF000000), // 검은색 텍스트
                  fontSize: 50,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20), // 텍스트와 이미지 사이의 간격 추가
              Image.asset(
                'asset/logo.png',
                width: 300,
              ),
              SizedBox(height: 20), // 이미지와 버튼 사이의 간격 추가
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 가로로 중앙 정렬
                children: [
                  SizedBox(width: 35),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(40, 50), // 각 버튼의 최소 크기 설정
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // 패딩 설정
                      backgroundColor: main_color, // 배경 색상
                      foregroundColor: Colors.black, // 텍스트 색상
                      elevation: 0, // 버튼의 그림자 제거
                    ),
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // 두 버튼 사이의 간격
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Membership()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(40, 50), // 각 버튼의 최소 크기 설정
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 패딩 설정
                      backgroundColor: main_color, // 배경 색상
                      foregroundColor: Colors.black, // 텍스트 색상
                      elevation: 0, // 버튼의 그림자 제거
                    ),
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
