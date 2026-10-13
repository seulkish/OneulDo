// filename: /services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/leave_request.dart';

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

  String get _todayDateId {
    final koreaNow = DateTime.now().toUtc().add(
      const Duration(hours: 9),
    );

    return '${koreaNow.year}-'
        '${koreaNow.month.toString().padLeft(2, '0')}-'
        '${koreaNow.day.toString().padLeft(2, '0')}';
  }

  DocumentReference<Map<String, dynamic>> get userDocument {
    return _firestore.collection('users').doc(_uid);
  }

  DocumentReference<Map<String, dynamic>> get _todayAttendanceDocument {
    return userDocument
        .collection('attendanceRecords')
        .doc(_todayDateId);
  }

  // 아직 끝나지 않은 근무 상태
  static const _activeStatuses = {'working', 'fieldWork', 'overtime'};

  // 현재 근무 문서
  // 오늘 기록이 없고 전날 근무가 진행 중이면(자정을 넘긴 근무) 전날 문서를 사용합니다.
  Future<DocumentReference<Map<String, dynamic>>>
      _currentAttendanceDocument() async {
    final todayDocument = _todayAttendanceDocument;
    final todaySnapshot = await todayDocument.get();

    if (todaySnapshot.exists) return todayDocument;

    final koreaNow = DateTime.now().toUtc().add(const Duration(hours: 9));
    final yesterday = DateTime(koreaNow.year, koreaNow.month, koreaNow.day - 1);
    final yesterdayDocument = userDocument
        .collection('attendanceRecords')
        .doc(_dateId(yesterday));
    final yesterdaySnapshot = await yesterdayDocument.get();

    final status = yesterdaySnapshot.data()?['status'] as String?;
    if (_activeStatuses.contains(status)) return yesterdayDocument;

    return todayDocument;
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

        'jobTitle': '인턴',
        'points': 0,

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

  Future<Map<String, dynamic>?> readTodayAttendance() async {
    final snapshot = await (await _currentAttendanceDocument()).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  // 날짜를 근태 문서 ID 형식으로 변환
  // date는 조회하려는 한국 달력 날짜를 전달합니다.
  String _dateId(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // 일별 근태 조회
  Future<Map<String, dynamic>?> readAttendanceByDate(
      DateTime date,
      ) async {
    final snapshot = await userDocument
        .collection('attendanceRecords')
        .doc(_dateId(date))
        .get();

    final data = snapshot.data();

    if (data == null) return null;

    return {
      ...data,
      'dateId': snapshot.id,
    };
  }

  // 기간별 근태 조회
  // 시작일 포함, 종료일 제외
  Future<List<Map<String, dynamic>>> readAttendanceByPeriod({
    required DateTime startDate,
    required DateTime endDateExclusive,
  }) async {
    final startId = _dateId(startDate);
    final endId = _dateId(endDateExclusive);

    if (startId.compareTo(endId) >= 0) {
      throw ArgumentError('종료일은 시작일 이후여야 합니다.');
    }

    final snapshot = await userDocument
        .collection('attendanceRecords')
        .where(
      FieldPath.documentId,
      isGreaterThanOrEqualTo: startId,
    )
        .where(
      FieldPath.documentId,
      isLessThan: endId,
    )
        .orderBy(FieldPath.documentId)
        .get();

    return snapshot.docs.map((document) {
      return {
        ...document.data(),
        'dateId': document.id,
      };
    }).toList();
  }

  // 월별 근태 조회
  Future<List<Map<String, dynamic>>> readMonthlyAttendance(
      DateTime month,
      ) {
    return readAttendanceByPeriod(
      startDate: DateTime(month.year, month.month, 1),
      endDateExclusive: DateTime(month.year, month.month + 1, 1),
    );
  }

  Future<void> validateFieldWorkRequest() async {
    final snapshot = await (await _currentAttendanceDocument()).get();

    if (!snapshot.exists) {
      throw Exception('출근 후에만 외근을 신청할 수 있습니다.');
    }

    final data = snapshot.data();

    if (data == null) {
      throw Exception('오늘 근무 기록을 불러올 수 없습니다.');
    }

    final status = data['status'] as String?;

    if (status == 'fieldWork') {
      throw Exception('이미 외근 중입니다.');
    }

    if (status != 'working') {
      throw Exception('현재 근무 중인 상태에서만 외근을 신청할 수 있습니다.');
    }
  }

  // Update 사용자 정보 수정
  Future<void> updateUser({
    String? nickname,
    String? phone,
    String? profileImageUrl,
    String? jobTitle,
    int? points,
  }) async {
    final updateData = <String, dynamic> {
      'updatedAt' : FieldValue.serverTimestamp(),
    };
    if (nickname != null) updateData['nickname'] = nickname;
    if (phone != null) updateData['phone'] = phone;
    if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
    if (jobTitle != null) updateData['jobTitle'] = jobTitle;
    if (points != null) updateData['points'] = points;
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

  // 출근 기록
  Future<bool> saveAttendanceRecord({
    required int requiredWorkMinutes,
    required int availableEndMinutes,
    required double latitude,
    required double longitude,
    required double distanceMeters,
    required bool isFieldWork,
    String? workplaceName,
  }) async {
    final koreaNow = DateTime.now().toUtc().add(
      const Duration(hours: 9),
    );

    final dateId =
        '${koreaNow.year}-'
        '${koreaNow.month.toString().padLeft(2, '0')}-'
        '${koreaNow.day.toString().padLeft(2, '0')}';

    final attendanceDocument = _todayAttendanceDocument;

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
        'workplace': workplaceName,
        'status': isFieldWork ? 'fieldWork' : 'working',
        'attendanceStatus': attendanceStatus,

        // 최초 출근과 일반 근무 종료
        'startedAt': FieldValue.serverTimestamp(),
        'endedAt': null,

        // 추가 근무 시작과 종료
        'overtimeStartedAt': null,
        'overtimeEndedAt': null,

        // 유형별 근무시간
        'workedMinutes': 0,
        'fieldWorkMinutes': 0,
        'overtimeMinutes': 0,
        'totalWorkedMinutes': 0,

        'requiredWorkMinutes': requiredWorkMinutes,
        'latitude': latitude,
        'longitude': longitude,
        'distanceMeters': distanceMeters,
        'earnedPoint': 0,
      });
      return true;
    });

  }

  // 퇴근 기록 저장
  Future<bool> saveEndWork() async {
    // 실제 시간 계산 및 Timestamp 저장에 사용
    final now = DateTime.now();

    final attendanceDocument = await _currentAttendanceDocument();

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(attendanceDocument);

      if (!snapshot.exists) {
        throw Exception('오늘 출근 기록이 없습니다.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('출근 기록을 불러올 수 없습니다.');
      }

      final status = data['status'] as String?;

      final startedAt = data['startedAt'] as Timestamp?;
      final endedAt = data['endedAt'] as Timestamp?;

      final overtimeStartedAt =
      data['overtimeStartedAt'] as Timestamp?;

      final overtimeEndedAt =
      data['overtimeEndedAt'] as Timestamp?;

      var workedMinutes =
          (data['workedMinutes'] as num?)?.toInt() ?? 0;

      var fieldWorkMinutes =
          (data['fieldWorkMinutes'] as num?)?.toInt() ?? 0;

      var overtimeMinutes =
          (data['overtimeMinutes'] as num?)?.toInt() ?? 0;

      // 일반 근무 또는 외근 종료
      if (status == 'working' || status == 'fieldWork') {
        if (startedAt == null) {
          throw Exception('출근 시간이 저장되어 있지 않습니다.');
        }

        if (endedAt != null) {
          return false;
        }

        final baseWorkMinutes = now
            .difference(startedAt.toDate())
            .inMinutes
            .clamp(0, 1440);

        final fieldWorkStartedAt =
            data['fieldWorkStartedAt'] as Timestamp?;

        if (status == 'fieldWork' && fieldWorkStartedAt != null) {
          // 근무 중 외근이 승인된 경우: 승인 전은 일반 근무, 이후는 외근
          workedMinutes = fieldWorkStartedAt
              .toDate()
              .difference(startedAt.toDate())
              .inMinutes
              .clamp(0, baseWorkMinutes);
          fieldWorkMinutes = baseWorkMinutes - workedMinutes;
        } else if (status == 'fieldWork') {
          // 하루 전체가 외근인 경우
          fieldWorkMinutes = baseWorkMinutes;
          workedMinutes = 0;
        } else {
          // 일반 근무인 경우
          workedMinutes = baseWorkMinutes;
          fieldWorkMinutes = 0;
        }

        final totalWorkedMinutes =
            workedMinutes +
                fieldWorkMinutes +
                overtimeMinutes;

        transaction.update(attendanceDocument, {
          'endedAt': Timestamp.fromDate(now),

          'workedMinutes': workedMinutes,
          'fieldWorkMinutes': fieldWorkMinutes,
          'overtimeMinutes': overtimeMinutes,
          'totalWorkedMinutes': totalWorkedMinutes,

          'status': 'completed',
        });

        return true;
      }

      // 추가 근무 종료
      if (status == 'overtime') {
        if (overtimeStartedAt == null) {
          throw Exception('추가 근무 시작 시간이 저장되어 있지 않습니다.');
        }

        if (overtimeEndedAt != null) {
          return false;
        }

        overtimeMinutes = now
            .difference(overtimeStartedAt.toDate())
            .inMinutes
            .clamp(0, 1440);

        final totalWorkedMinutes =
            workedMinutes +
                fieldWorkMinutes +
                overtimeMinutes;

        transaction.update(attendanceDocument, {
          'overtimeEndedAt': Timestamp.fromDate(now),
          'overtimeMinutes': overtimeMinutes,
          'totalWorkedMinutes': totalWorkedMinutes,
          'status': 'completed',
        });

        return true;
      }

      if (status == 'completed') {
        return false;
      }

      throw Exception('퇴근할 수 없는 근무 상태입니다.');
    });
  }

  CollectionReference<Map<String, dynamic>> get _leaveRequests {
    return userDocument.collection('leaveRequests');
  }

  // 휴가·외근 신청 저장
  Future<LeaveRequest> createLeaveRequest({
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final document = _leaveRequests.doc();
    final koreaNow = DateTime.now().toUtc().add(const Duration(hours: 9));
    final documentNumber =
        'ON-${_dateId(koreaNow).replaceAll('-', '')}-'
        '${document.id.substring(0, 4).toUpperCase()}';

    await document.set({
      'documentNumber': documentNumber,
      'leaveType': type.value,
      'approvalStatus': LeaveApprovalStatus.pending.value,
      'startDate': kstDateToTimestamp(startDate),
      'endDate': kstDateToTimestamp(endDate),
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'decidedAt': null,
    });

    return LeaveRequest(
      id: document.id,
      documentNumber: documentNumber,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }

  // 결재 이력 조회 (최근 신청 순)
  Future<List<LeaveRequest>> readLeaveRequests({int limit = 20}) async {
    final snapshot = await _leaveRequests
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(LeaveRequest.fromFirestore).toList();
  }

  Future<LeaveRequest?> readLeaveRequest(String requestId) async {
    final snapshot = await _leaveRequests.doc(requestId).get();
    if (!snapshot.exists) return null;
    return LeaveRequest.fromFirestore(snapshot);
  }

  // 상신 취소: 승인 대기 중인 신청만 삭제할 수 있습니다.
  Future<bool> cancelLeaveRequest(String requestId) {
    final document = _leaveRequests.doc(requestId);

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(document);
      if (snapshot.data()?['approvalStatus'] != LeaveApprovalStatus.pending.value) {
        return false;
      }
      transaction.delete(document);
      return true;
    });
  }

  // 승인·반려 처리
  // 승인 시 외근은 오늘 근무 상태를 외근으로 바꾸고, 연차는 해당 날짜를 휴가로 기록합니다.
  Future<bool> decideLeaveRequest({
    required String requestId,
    required bool approve,
  }) async {
    final requestDocument = _leaveRequests.doc(requestId);
    final currentAttendanceDocument = await _currentAttendanceDocument();
    final koreaNow = DateTime.now().toUtc().add(const Duration(hours: 9));
    final today = DateTime(koreaNow.year, koreaNow.month, koreaNow.day);

    return _firestore.runTransaction<bool>((transaction) async {
      final requestSnapshot = await transaction.get(requestDocument);
      if (!requestSnapshot.exists) {
        throw Exception('결재 문서를 찾을 수 없습니다.');
      }

      final request = LeaveRequest.fromFirestore(requestSnapshot);
      if (request.status != LeaveApprovalStatus.pending) {
        return false;
      }

      final coversToday = !today.isBefore(request.startDate) &&
          !today.isAfter(request.endDate);

      // 트랜잭션은 모든 읽기를 쓰기보다 먼저 해야 합니다.
      DocumentSnapshot<Map<String, dynamic>>? attendanceSnapshot;
      final vacationDays = <DocumentReference<Map<String, dynamic>>>[];

      if (approve && request.type == LeaveType.fieldWork && coversToday) {
        attendanceSnapshot = await transaction.get(currentAttendanceDocument);
      }

      if (approve && request.type == LeaveType.fullDay) {
        for (var day = request.startDate;
            !day.isAfter(request.endDate) && vacationDays.length < 31;
            day = DateTime(day.year, day.month, day.day + 1)) {
          final dayDocument =
              userDocument.collection('attendanceRecords').doc(_dateId(day));
          final daySnapshot = await transaction.get(dayDocument);
          if (!daySnapshot.exists) vacationDays.add(dayDocument);
        }
      }

      transaction.update(requestDocument, {
        'approvalStatus': approve
            ? LeaveApprovalStatus.approved.value
            : LeaveApprovalStatus.rejected.value,
        'decidedAt': FieldValue.serverTimestamp(),
      });

      if (attendanceSnapshot?.data()?['status'] == 'working') {
        transaction.update(currentAttendanceDocument, {
          'status': 'fieldWork',
          'fieldWorkStartedAt': FieldValue.serverTimestamp(),
        });
      }

      for (final dayDocument in vacationDays) {
        transaction.set(dayDocument, {
          'userId': _uid,
          'dateId': dayDocument.id,
          'status': 'vacation',
          'leaveRequestId': requestId,
          'workedMinutes': 0,
          'fieldWorkMinutes': 0,
          'overtimeMinutes': 0,
          'totalWorkedMinutes': 0,
          'requiredWorkMinutes': 0,
          'earnedPoint': 0,
        });
      }

      return true;
    });
  }

  Future<bool> hasApprovedFieldWorkForToday() async {
    final koreaNow = DateTime.now().toUtc().add(
      const Duration(hours: 9),
    );

    // 한국 날짜 자정의 실제 시각 (KST 00:00 = UTC 전날 15:00)
    final todayStart = DateTime.utc(
      koreaNow.year,
      koreaNow.month,
      koreaNow.day,
    ).subtract(const Duration(hours: 9));
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    // 등호 조건만 사용해 복합 인덱스 없이 조회하고, 기간은 클라이언트에서 거릅니다.
    final snapshot = await userDocument
        .collection('leaveRequests')
        .where('leaveType', isEqualTo: 'fieldWork')
        .where('approvalStatus', isEqualTo: 'approved')
        .get();

    return snapshot.docs.any((document) {
      final data = document.data();
      final startDate = (data['startDate'] as Timestamp?)?.toDate();
      final endDate = (data['endDate'] as Timestamp?)?.toDate();

      if (startDate == null || endDate == null) return false;

      return startDate.isBefore(tomorrowStart) && !endDate.isBefore(todayStart);
    });
  }

  Future<bool> startOvertime() async {
    final now = DateTime.now();

    final attendanceDocument = await _currentAttendanceDocument();

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(attendanceDocument);

      if (!snapshot.exists) {
        throw Exception('오늘 근무 기록이 없습니다.');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('근무 기록을 불러올 수 없습니다.');
      }

      final status = data['status'] as String?;
      final endedAt = data['endedAt'] as Timestamp?;
      final overtimeStartedAt =
      data['overtimeStartedAt'] as Timestamp?;

      if (status != 'completed' || endedAt == null) {
        throw Exception('일반 근무를 먼저 종료해주세요.');
      }

      if (overtimeStartedAt != null) {
        return false;
      }

      transaction.update(attendanceDocument, {
        'overtimeStartedAt': Timestamp.fromDate(now),
        'overtimeEndedAt': null,
        'status': 'overtime',
      });

      return true;
    });
  }
}

