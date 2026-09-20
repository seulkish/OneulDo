// models/leave_policy.dart
enum LeaveType {
  fullDay,  // 연차
  morning,  // 오전 반차
  afternoon, // 오후 반차
  fieldWork, // 외근
}

enum LeaveApprovalStatus {
  pending,  // 승인 대기
  approved, // 승인 완료
  rejected, // 반려
}

class LeaveRequest {
  final String id;
  final LeaveType type;
  final DateTime startAt; // 반차 때문에 시간도 포함
  final DateTime endAt;
  final String reason;
  final LeaveApprovalStatus status;
  final DateTime createdAt;

  const LeaveRequest({
    required this.id,
    required this.type,
    required this.startAt,
    required this.endAt,
    required this.reason,
    this.status = LeaveApprovalStatus.pending,
    required this.createdAt,
  });

  LeaveRequest copyWith({
    LeaveType? type,
    DateTime? startAt,
    DateTime? endAt,
    String? reason,
    LeaveApprovalStatus? status,
    DateTime? createdAt,
  }) {
    return LeaveRequest(
      id: id,
      type: type ?? this.type,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}