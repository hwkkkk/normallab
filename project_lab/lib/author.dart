import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // FirebaseAuth 인스턴스를 전역적으로 사용
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 회원가입 메서드
  Future<User?> register(String id, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: id, password: password);
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // 로그인 메서드
  Future<User?> logIn(String id, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: id, password: password);
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // 로그아웃 메서드
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
