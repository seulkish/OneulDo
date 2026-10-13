// filename: /services/auth_session.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// 로그인 상태와 온보딩 완료 여부를 라우터에 알려주는 객체.
///
/// GoRouter의 refreshListenable로 연결해서 로그인·로그아웃·온보딩 완료 시
/// redirect가 다시 실행되도록 합니다.
class AuthSession extends ChangeNotifier {
  AuthSession() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  User? _user;

  /// null이면 아직 사용자 문서를 불러오는 중입니다.
  bool? _onboardingCompleted;

  bool get isLoggedIn => _user != null;
  bool? get onboardingCompleted => _onboardingCompleted;

  void _onAuthChanged(User? user) {
    _userSubscription?.cancel();
    _user = user;
    _onboardingCompleted = null;

    if (user != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
        (snapshot) {
          // 회원가입 직후 문서가 아직 없으면 온보딩 전으로 봅니다.
          final completed = snapshot.data()?['onboardingCompleted'] == true;
          if (completed == _onboardingCompleted) return;
          _onboardingCompleted = completed;
          notifyListeners();
        },
        onError: (Object error) {
          debugPrint('사용자 문서 구독 실패: $error');
        },
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
