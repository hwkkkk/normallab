import 'package:flutter/material.dart';
import 'package:project_lab/color.dart';
import 'package:project_lab/Home.dart';
import 'package:project_lab/author.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Membership extends StatefulWidget {
  const Membership({super.key});

  @override
  _MembershipState createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _id= TextEditingController();
  final TextEditingController _pw = TextEditingController();
  final AuthService _rollin = AuthService();


  void dispose() {
    // 화면이 종료될 때 컨트롤러 해제
    _name.dispose();
    _email.dispose();
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _signin() async {
    String id_rollin = _id.text+'@naver.com';
    String pw_rollin = _pw.text;

    try {
      User? user = await _rollin.register(id_rollin, pw_rollin); // 회원가입 처리
      if (user != null) {
        print('회원가입 성공: ${user.email}');
        // 회원가입 성공 시, SnackBar로 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 성공: ${user.email}')),
        );

        // 회원가입 성공 시 홈으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        print('회원가입 실패');
        // 회원가입 실패 시, SnackBar로 실패 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패')),
        );
      }
    } catch (e) {
      print('오류 발생: $e');
      // 예외 발생 시, SnackBar로 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 중 오류가 발생했습니다: $e')),
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
            '회원가입',
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SizedBox(height: 30,),


          Row(
            children: [
              SizedBox(width: 50,),
              Text('이름*'),
            ],
          ),


          SizedBox(height: 10,),

          Container(
            child: TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: '이름을 입력해주세요',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            width: 320,
          ),
          //이름

          SizedBox(height: 30,),

          Row(
            children: [
              SizedBox(width: 50,),
              Text('이메일*'),
            ],
          ),
          SizedBox(height: 10,),
          
          
          Container(
            child: TextField(
              controller: _email,
              decoration: InputDecoration(
                labelText: 'example@gmail.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            width: 320,
          ),
          
          SizedBox(height: 30,),
          
          //이메일
          
          Row(
            children: [

              SizedBox(width: 50,),
              Text('아이디*'),
            ],
          ),
          SizedBox(height: 10,),

          Container(
            child: TextField(
              controller: _id,
              decoration: InputDecoration(
                labelText: '아이디를 입력해주세요',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            width: 320,
          ),
          SizedBox(height: 30,),

          
          Row(
            children: [
              SizedBox(width: 50,),
              Text('비밀번호*'),
            ],
          ),
          SizedBox(height: 10,),
          Container(
            child: TextField(
              controller: _pw,
              decoration: InputDecoration(
                labelText: '비밀번호를 입력해주세요' ,
                border: OutlineInputBorder(),
              ),

              keyboardType: TextInputType.emailAddress,
            ),
            width: 320,
          ),

          SizedBox(height: 30,),
          
          ElevatedButton(
            onPressed: _signin,
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
              '회원가입 완료',
            ),
          ),
        ],

      ),

    );
  }
}
