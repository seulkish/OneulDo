// lib/models/work_status.dart

enum WorkStatus {
  beforeWork, // 출근 전
  working,    // 근무 중
  fieldWork,  // 외근 중
  completed,  // 퇴근 완료
  vacation,   // 휴가
  overtime,   // 연장 근무
  absent,     // 결근
}