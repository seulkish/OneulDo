// filename: /services/firebase_auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance {
    // _auth.setLanguageCode('ko');
  }

  // 현재 로그인 사용자
  User? get currentUser => _auth.currentUser;

  // 이메일 회원가입
  Future<UserCredential> signupWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // 이메일 로그인
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException code: ${e.code}');
      debugPrint('FirebaseAuthException message: ${e.message}');

      throw Exception(_getErrorMessage(e.code));
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 비밀번호 재설정 메일
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: _getErrorMessage(e.code),
      );
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    // debugPrint('현재 사용자: ${user?.email}');
    // debugPrint('현재 UID: ${user?.uid}');

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final uid = user.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .delete();

    await user.delete();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'weak-password':
        return '비밀번호는 6자 이상 입력해주세요.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'user-disabled':
        return '사용이 중지된 계정입니다.';
      case 'too-many-requests':
        return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'operation-not-allowed':
        return 'Firebase에서 이메일 로그인이 활성화되지 않았습니다.';
      default:
        return '인증 처리 중 오류가 발생했습니다. ($code)';
    }
  }
}