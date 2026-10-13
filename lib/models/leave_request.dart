// models/leave_request.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveType {
  fullDay('fullDay', '연차'),
  morning('morning', '반차(오전)'),
  afternoon('afternoon', '반차(오후)'),
  fieldWork('fieldWork', '외근'),
  businessTrip('businessTrip', '출장');

  const LeaveType(this.value, this.label);

  /// Firestore에 저장하는 값
  final String value;

  /// 화면에 표시하는 이름
  final String label;

  static LeaveType fromValue(String? value) {
    return LeaveType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LeaveType.fullDay,
    );
  }

  static LeaveType fromLabel(String label) {
    return LeaveType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => LeaveType.fullDay,
    );
  }
}

enum LeaveApprovalStatus {
  pending('pending', '승인 대기'),
  approved('approved', '승인'),
  rejected('rejected', '반려');

  const LeaveApprovalStatus(this.value, this.label);

  final String value;
  final String label;

  static LeaveApprovalStatus fromValue(String? value) {
    return LeaveApprovalStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LeaveApprovalStatus.pending,
    );
  }
}

/// 한국 달력 날짜를 Firestore Timestamp로 변환합니다. (해당 날짜 KST 00:00)
Timestamp kstDateToTimestamp(DateTime date) {
  return Timestamp.fromDate(
    DateTime.utc(date.year, date.month, date.day)
        .subtract(const Duration(hours: 9)),
  );
}

/// Firestore Timestamp를 한국 달력 날짜로 변환합니다.
DateTime kstDateFromTimestamp(Timestamp timestamp) {
  final korea = timestamp.toDate().toUtc().add(const Duration(hours: 9));
  return DateTime(korea.year, korea.month, korea.day);
}

/// users/{uid}/leaveRequests/{requestId}
class LeaveRequest {
  final String id;
  final String documentNumber;
  final LeaveType type;

  /// 한국 달력 날짜 (시작일·종료일 모두 포함)
  final DateTime startDate;
  final DateTime endDate;

  final String reason;
  final LeaveApprovalStatus status;
  final DateTime? createdAt;
  final DateTime? decidedAt;

  const LeaveRequest({
    required this.id,
    required this.documentNumber,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = LeaveApprovalStatus.pending,
    this.createdAt,
    this.decidedAt,
  });

  factory LeaveRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final startDate = data['startDate'] as Timestamp?;
    final endDate = data['endDate'] as Timestamp?;
    final createdAt = data['createdAt'] as Timestamp?;
    final decidedAt = data['decidedAt'] as Timestamp?;

    return LeaveRequest(
      id: document.id,
      documentNumber: data['documentNumber'] as String? ?? document.id,
      type: LeaveType.fromValue(data['leaveType'] as String?),
      startDate: startDate == null
          ? DateTime.now()
          : kstDateFromTimestamp(startDate),
      endDate: endDate == null
          ? DateTime.now()
          : kstDateFromTimestamp(endDate),
      reason: data['reason'] as String? ?? '',
      status: LeaveApprovalStatus.fromValue(data['approvalStatus'] as String?),
      createdAt: createdAt?.toDate(),
      decidedAt: decidedAt?.toDate(),
    );
  }
}
