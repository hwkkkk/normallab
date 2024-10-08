import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_lab/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser; // 사용자의 정보를 저장할 변수
  String? uid; // 사용자 uid를 저장할 변수
  final PageController _pageController = PageController(); // PageController 추가

  @override
  void initState() {
    super.initState();

    // Firebase 인증 상태가 변경되면 이를 감지
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is signed out!');
        // 유저가 없으면 로그인 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        print('User is signed in! UID: ${user.uid}');
        setState(() {
          currentUser = user;
          uid = user.uid; // uid를 설정
        });
      }
    });
  }

  // 로그아웃 함수
  Future<void> _signOut() async {
    await _auth.signOut();
    // 로그아웃 후 로그인 페이지로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  final ImagePicker _picker = ImagePicker();
  File? _image;

  // 갤러리에서 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final result = await _uploadImage(File(pickedFile.path));
      _show(base64Image, result, File(pickedFile.path)); // 파일을 넘겨줘야 Firestore에 저장 가능
    } else {
      print('no image');
    }
  }

  // 서버에 이미지를 업로드하는 함수
  Future<String> _uploadImage(File imageFile) async {
    if (uid == null) {
      return 'Error: User is not logged in'; // 유저가 로그인되지 않았을 때의 에러 처리
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.56.1:5000/predict'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print('Response data: $responseData');
        final decodedData = json.decode(responseData);

        if (decodedData.containsKey('final_prediction')) {
          return decodedData['final_prediction'];
        } else {
          print('No final_prediction in response');
          return 'Error';
        }
      } else {
        print('Error uploading image: ${response.statusCode}');
        return 'Error';
      }
    } catch (e) {
      print('Exception occurred during image upload: $e');
      return 'Error';
    }
  }

  // Firebase Storage에 이미지 업로드
  Future<String> _uploadImageToFirebase(File imageFile) async {
    if (!await imageFile.exists()) {
      print('Error: File does not exist.');
      return '';
    }
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child("normallab/$fileName");

      print('Uploading to: normallab/$fileName'); // 업로드 경로를 출력하여 디버깅

      // Firestorage에 파일 업로드
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // 다운로드 URL을 받아서 반환
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading to Firebase: $e');
      return '';
    }
  }

  // Firestore에 이미지 URL과 결과 저장
  Future<void> _saveImageToFirestore(String imageUrl, String result) async {
    print('imageUrl: $imageUrl, result: $result');
    try {
      if (uid == null) {
        print('Error: User is not logged in');
        return;
      }
      print("Current UID: $uid");

      // Firestore에 데이터 저장 로직
      await FirebaseFirestore.instance.collection('uploadedImages').add({
        'imageUrl': imageUrl,
        'uploadedAt': Timestamp.now(),
        'uid': uid, // 사용자 UID 저장
        'result': result, // 이미지 판별 결과 저장
      });
      print('Image and result saved to Firestore');
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
  }

  // 판별된 이미지와 결과를 Firestore에 저장하는 함수
  void _saveImage(File imageFile, String result) async {
    // Firebase에 이미지 업로드
    String imageUrl = await _uploadImageToFirebase(imageFile);
    if (imageUrl.isNotEmpty) {
      // 이미지 URL과 판별 결과를 Firestore에 저장
      await _saveImageToFirestore(imageUrl, result);
    } else {
      print('_uploadImageTOFIRE 베이스가 잘못됨');
    }
  }

  // 결과를 보여주는 함수
  void _show(String base64Image, String initialResult, File imageFile) {
    initialResult = initialResult.trim();
    String selectedResult;

    if (initialResult == '실제 광고' || initialResult == '사칭 광고') {
      selectedResult = initialResult;
    } else {
      selectedResult = '실제 광고'; // 기본값 설정
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이미지 분류 결과'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(base64Decode(base64Image), height: 200, width: 200),
              SizedBox(height: 20),
              Text('AI 분류 결과 $selectedResult 입니다.'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ai가 잘못 분류했나요?'),
                  DropdownButton<String>(
                    value: selectedResult,
                    items: ['실제 광고', '사칭 광고'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedResult = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                // Firebase Storage와 Firestore에 이미지와 결과 저장
                _saveImage(imageFile, selectedResult);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: main_color,
        elevation: 0, // AppBar의 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.black), // 뒤로가기 아이콘 설정
          onPressed: _signOut,
        ),
        title: Text('CIA'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController, // PageController 추가
              scrollDirection: Axis.vertical,
              children: <Widget>[
                _buildRepresentativeAdImagesPage(),
                _buildUploadedImagesList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 샘플 이미지를 보여주는 함수
  Widget _buildRepresentativeAdImagesPage() {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('asset/example1.png', height: 200, width: 200),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('asset/example2.png', height: 200, width: 200),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('asset/example3.png', height: 200, width: 200),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('asset/example4.png', height: 200, width: 200),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('asset/example5.png', height: 200, width: 200),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text('<대표적인 사칭 광고 이미지>', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
        SizedBox(height: 70),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () => _pickImage(ImageSource.camera),
              iconSize: 80,
            ),
            IconButton(
              icon: Icon(Icons.photo),
              iconSize: 80,
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
        SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            '업로드한 내역은 아래로 스와이프',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Text(
            'vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv',
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  // 사용자가 업로드한 이미지 목록을 Firestore에서 가져와 보여줌
  Widget _buildUploadedImagesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('uploadedImages')
          .where('uid', isEqualTo: uid) // uid로 사용자 필터링
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          scrollDirection: Axis.horizontal,
          children: snapshot.data!.docs.map((doc) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Image.network(doc['imageUrl'], height: 200, width: 200),
                  Text('Result: ${doc['result']}', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
