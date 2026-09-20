# Firestore 데이터 구조

## 전체 구조

users/{uid}
├── workSettings/current
├── attendanceRecords/{date}
├── schedules/{scheduleId}
├── leaveRequests/{requestId}
└── notifications/{notificationId}

---

## 1. users

경로: users/{uid}

문서 ID는 Firebase Authentication에서 발급받은 UID를 사용한다.

예시:

{
"email": "oneul@example.com",
"nickname": "오늘",
"company": "새싹컴퍼니",
"department": "IT개발준비팀",
"position": "employee",
"employeeNumber": "20260902",
"point": 1240,
"createdAt": "Timestamp"
}

---

## 2. workSettings

경로: users/{uid}/workSettings/current

예시:

{
"workplaceName": "중앙도서관 3층 열람실",
"address": "서울특별시 서대문구",
"latitude": 37.559,
"longitude": 126.942,
"allowedRadiusMeters": 50,
"dailyWorkMinutes": 240,
"workStartHour": 8,
"workEndHour": 11,
"updatedAt": "Timestamp"
}

---

## 3. attendanceRecords

경로: users/{uid}/attendanceRecords/{yyyy-MM-dd}

예시:

{
"date": "Timestamp",
"status": "completed",
"startedAt": "Timestamp",
"endedAt": "Timestamp",
"workedMinutes": 245,
"requiredWorkMinutes": 240,
"earnedPoint": 50
}

---

## 4. schedules

경로: users/{uid}/schedules/{scheduleId}

예시:

{
"title": "알고리즘 문제 3개",
"description": "백준 실버 문제 풀이",
"scheduledAt": "Timestamp",
"type": "study",
"status": "remaining",
"point": 5,
"completedAt": null,
"createdAt": "Timestamp"
}

---

## 5. leaveRequests

경로: users/{uid}/leaveRequests/{requestId}

예시:

{
"durationType": "quarterDay",
"timeSlot": "endOfWork",
"startAt": "Timestamp",
"endAt": "Timestamp",
"reason": "병원 방문",
"status": "pending",
"createdAt": "Timestamp",
"approvedAt": null
}

---

## 6. notifications

경로: users/{uid}/notifications/{notificationId}

예시:

{
"title": "휴가 신청이 승인되었습니다",
"description": "9월 23일 반반차 신청이 승인되었습니다.",
"type": "leaveApproved",
"isRead": false,
"createdAt": "Timestamp"
}