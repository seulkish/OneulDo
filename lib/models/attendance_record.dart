// lib/models/attendance_record.dart

import 'work_status.dart';

class AttendanceRecord {
  final DateTime date;
  final WorkStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int requiredWorkMinutes; // 당일 목표 근무시간 (분 단위)

  const AttendanceRecord({
    required this.date,
    required this.status,
    this.startedAt,
    this.endedAt,
    required this.requiredWorkMinutes,
  });

  Duration get workedDuration {
    if (startedAt == null) return Duration.zero;

    final endTime = endedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  bool get isWorking =>
      status == WorkStatus.working ||
          status == WorkStatus.fieldWork ||
          status == WorkStatus.overtime;

  double get progress {
    if (requiredWorkMinutes <= 0) return 0;

    return (workedDuration.inMinutes / requiredWorkMinutes)
        .clamp(0.0, 1.0);
  }

  AttendanceRecord copyWith({
    DateTime? date,
    WorkStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? targetWorkMinutes,
  }) {
    return AttendanceRecord(
      date: date ?? this.date,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      requiredWorkMinutes:
      targetWorkMinutes ?? this.requiredWorkMinutes,
    );
  }
}