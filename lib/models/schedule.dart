enum ScheduleStatus {
  attendance, // 출근·퇴근
  completed, // 완료
  overdue, // 시간이 지났지만 미완료
  remaining, // 아직 시간이 남은 일정
}

class Schedule {
  final String time;
  final String title;
  final ScheduleStatus status;

  const Schedule({
    required this.time,
    required this.title,
    required this.status,
  });
}
