// filename: /services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get userDocument {
    return _firestore.collection('users').doc(_uid);
  }

  // Create 사용자 정보 저장
  Future<void> createUser({
    required String email,
    required String nickname,
    required String phone,
  }) async {
    await userDocument.set(
      {
        'email': email,
        'nickname': nickname,
        'phone': phone,
        'profileImageUrl': null,
        'onboardingCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true)
    );
  }

  // Read 사용자 정보 조회
  Future<Map<String, dynamic>?> readUser() async {
    final documentSnapshot = await userDocument.get();
    if (!documentSnapshot.exists) {
      return null;
    }
    return documentSnapshot.data();
  }

  // Update 사용자 정보 수정
  Future<void> updateUser({
    String? nickname,
    String? phone,
    String? profileImageUrl,
  }) async {
    final updateData = <String, dynamic> {
      'updatedAt' : FieldValue.serverTimestamp(),
    };
    if (nickname != null) updateData['nickname'] = nickname;
    if (phone != null) updateData['phone'] = phone;
    if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
    await userDocument.update(updateData);
  }

  // Delete 사용자 정보 삭제
  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }
    await userDocument.delete();
  }

  // 출근 기록
  Future<void> saveAttendanceRecord({
    required int requiredWorkMinutes,
  }) async {
    final now = DateTime.now();

    final dateId =
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    await userDocument
        .collection('attendanceRecords')
        .doc(dateId)
        .set({
      'date': Timestamp.fromDate(
        DateTime(
          now.year,
          now.month,
          now.day,
        ),
      ),
      'status': 'working',
      'startedAt': FieldValue.serverTimestamp(),
      'endedAt': null,
      'workedMinutes': 0,
      'requiredWorkMinutes': requiredWorkMinutes,
      'earnedPoint': 0,
    });
  }
}

