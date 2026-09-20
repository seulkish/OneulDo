enum LeaveDurationType {
  fullDay,    // 연차
  halfDay,    // 반차
  quarterDay, // 반반차
}

enum LeaveTimePosition {
  startOfWork, // 출근 후 사용
  endOfWork,   // 퇴근 전 사용
}

class LeavePolicy {
  final int halfDayMinutes;
  final int quarterDayMinutes;

  const LeavePolicy({
    this.halfDayMinutes = 240,    // 4시간
    this.quarterDayMinutes = 120, // 2시간
  });

  int durationFor(LeaveDurationType type) {
    return switch (type) {
      LeaveDurationType.fullDay => 480,
      LeaveDurationType.halfDay => halfDayMinutes,
      LeaveDurationType.quarterDay => quarterDayMinutes,
    };
  }
}