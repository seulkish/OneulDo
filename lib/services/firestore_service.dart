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

        'jobtitle': '인턴',
        'point': 0,

        'workSettings': {
          'workplaceName': null,
          'address': null,
          'latitude': null,
          'longitude': null,
          'allowedRadiusMeters': null,
          'dailyWorkMinutes': null,
          'availableStartMinutes': null,
          'availableEndMinutes': null,
          'goals': null,
        },

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

  // 근무지 설정 조회
  Future<Map<String, dynamic>?> readWorkSettings() async {
    final snapshot = await userDocument.get();

    if (!snapshot.exists) return null;

    final data = snapshot.data();
    final workSettings = data?['workSettings'];

    if (workSettings is! Map) return null;

    return Map<String, dynamic>.from(workSettings);
  }

  // Update 사용자 정보 수정
  Future<void> updateUser({
    String? nickname,
    String? phone,
    String? profileImageUrl,
    String? jobtitle,
    int? point,
  }) async {
    final updateData = <String, dynamic> {
      'updatedAt' : FieldValue.serverTimestamp(),
    };
    if (nickname != null) updateData['nickname'] = nickname;
    if (phone != null) updateData['phone'] = phone;
    if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
    if (jobtitle != null) updateData['jobtitle'] = jobtitle;
    if (point != null) updateData['point'] = point;
    await userDocument.update(updateData);
  }

  // 임시
  Future<void> updateTemp(int temp) async {
    await userDocument.update({
      'point': temp,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 근무지 설정 수정
  Future<void> updateWorkplace({
    required String workplaceName,
    required String address,
    required double latitude,
    required double longitude,
    required int allowedRadiusMeters,
  }) async {
    await userDocument.update({
      'workSettings.workplaceName': workplaceName,
      'workSettings.address': address,
      'workSettings.latitude': latitude,
      'workSettings.longitude': longitude,
      'workSettings.allowedRadiusMeters': allowedRadiusMeters,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 근무시간 설정 수정
  Future<void> updateWorkTime({
    required int dailyWorkMinutes,
    required int availableStartMinutes,
    required int availableEndMinutes,
  }) async {
    await userDocument.update({
      'workSettings.dailyWorkMinutes': dailyWorkMinutes,
      'workSettings.availableStartMinutes': availableStartMinutes,
      'workSettings.availableEndMinutes': availableEndMinutes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 목표 설정 수정
  Future<void> updateGoal({
    required List<String> goals,
  }) async {
    await userDocument.update({
      'workSettings.goals': goals,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 온보딩 완료 처리
  Future<void> completeOnboarding({
    required List<String> goals,
  }) async {
    await userDocument.update({
      'workSettings.goals': goals,
      'onboardingCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
  Future<bool> saveAttendanceRecord({
    required int requiredWorkMinutes,
    required int availableEndMinutes,
    required double latitude,
    required double longitude,
    required double distanceMeters,
  }) async {
    final koreaNow = DateTime.now().toUtc().add(
      const Duration(hours: 9),
    );

    final dateId =
        '${koreaNow.year}-'
        '${koreaNow.month.toString().padLeft(2, '0')}-'
        '${koreaNow.day.toString().padLeft(2, '0')}';

    final attendanceDocument = userDocument
        .collection('attendanceRecords')
        .doc(dateId);

    final currentMinutes = koreaNow.hour * 60 + koreaNow.minute;

    final attendanceStatus =
        currentMinutes <= availableEndMinutes
            ? 'normal'
            : 'late';
    
    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(attendanceDocument);
      if (snapshot.exists) {
        return false;
      }

      transaction.set(attendanceDocument, {
        'userId': _uid,
        'dateId': dateId,
        'status': 'working',
        'attendanceStatus': attendanceStatus,
        'startedAt': FieldValue.serverTimestamp(),
        'endedAt': null,
        'workedMinutes': 0,
        'requiredWorkMinutes': requiredWorkMinutes,
        'latitude': latitude,
        'longitude': longitude,
        'distanceMeters': distanceMeters,
        'earnedPoint': 0,
      });
      return true;
    });

  }
}

