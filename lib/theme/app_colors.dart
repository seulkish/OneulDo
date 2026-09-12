import 'package:flutter/material.dart';

/// Oneul 앱 색상 토큰.
///
/// 출처: `Oneul_Flow_dc.html` → "색상" / "타이포 · 규격" 섹션.
/// 문서 원칙: 액센트는 OneulBlue 하나만 구조에 사용하고,
/// 나머지 색은 근태 구분 표시에만 사용한다.
class AppColors {
  const AppColors._();

  // ── Primary ───────────────────────────────────────────────
  /// Oneul Blue · 주 액센트 / CTA / 활성 상태
  static const Color primary = Color(0xFF326FE9);

  /// Blue Pressed · 포인트 수치 / 링크 / pressed
  static const Color primaryPressed = Color(0xFF2558C4);

  /// primary 위에 올라가는 텍스트·아이콘
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── 배경 · 면 ─────────────────────────────────────────────
  /// Canvas · 화면 배경 (Scaffold)
  static const Color canvas = Color(0xFFFAFAFA); // 좀 더 밝은 색으로 색상 변경

  ///
  static const Color canvassub = Color(0xFFF2F2F2);

  /// 카드 · 시트 · 바텀내비 배경
  static const Color card = Color(0xFFFFFFFF);

  /// Fill · 메타 블록 / 채움면 (프로그레스 트랙 등)
  static const Color fill = Color(0xFFF3F4F5);

  /// Hairline · 카드 경계 / 입력 테두리
  static const Color hairline = Color(0xFFDCDEE3);

  /// Divider · 리스트 구분선
  static const Color divider = Color(0xFFEEEFF1);

  // ── 텍스트 ────────────────────────────────────────────────
  /// Ink · 본문 / 제목
  static const Color ink = Color(0xFF1A1C20);

  /// Ink Muted · 보조 텍스트
  static const Color inkMuted = Color(0xFF555D6D);

  /// Ink Faint · 캡션 / 비활성
  static const Color inkFaint = Color(0xFF868B94);

  /// 비활성 아이콘 / 미선택 탭
  static const Color inkDisabled = Color(0xFFB0B3BA);

  // ── 상태 · 근태 구분 (구조 색으로 쓰지 않음) ────────────────
  /// Task Red · 남은 계획 / 강조 / 알림 뱃지
  static const Color taskRed = Color(0xFFFA342C);

  /// Vacation · 휴가 / 결재
  static const Color vacation = Color(0xFFEE8C23);

  /// Field Purple · 외근 / 출장
  static const Color fieldPurple = Color(0xFF8969EA);

  /// Positive · 정상 처리 / 달성
  static const Color positive = Color(0xFF079171);

  /// Callout Sky · 안내 배너 배경
  static const Color calloutSky = Color(0xFFE1F7FF);

  /// Callout 본문 텍스트 (안내 배너 위)
  static const Color calloutInk = Color(0xFF135FCD);

  // ── 배지 베이스 (팔레트 표에는 없고 목업에만 존재) ───────────
  /// 지각 / 자소서 계열 베이스 (탠 브라운)
  static const Color lateTan = Color(0xFFB4946C);

  /// GPS 도착 · 상신 완료 도트 (라이브 그린)
  static const Color liveGreen = Color(0xFF33C41D);

  /// 계획 카테고리 · 진행 바 (블루 그레이)
  static const Color categoryBlue = Color(0xFF6097CA);

  /// 계획 카테고리 · 진행 바 (세이지 그린)
  static const Color categoryGreen = Color(0xFF70B187);

  // ── 그림자 (문서 s1 / s2 / s3) ─────────────────────────────
  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,.078)
      offset: Offset(0, 1),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,.102)
      offset: Offset(0, 2),
      blurRadius: 10,
    ),
  ];

  static const List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0,0,0,.122)
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];
}

/// 배지 한 개의 배경 + 전경 색 한 쌍.
///
/// 목업의 배지는 모두 pill(radius 999) · font 12 · weight 600 이고
/// 배경/텍스트만 상태별로 달라집니다.
@immutable
class BadgeColors {
  const BadgeColors({required this.background, required this.foreground});

  /// 배지 배경
  final Color background;

  /// 배지 텍스트 (및 아이콘)
  final Color foreground;

  BadgeColors copyWith({Color? background, Color? foreground}) => BadgeColors(
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
  );

  @override
  bool operator ==(Object other) =>
      other is BadgeColors &&
          other.background == background &&
          other.foreground == foreground;

  @override
  int get hashCode => Object.hash(background, foreground);
}

/// 근태 · 상태 배지 색 조합.
///
/// 출처: `Oneul_Flow_dc.html` 목업 배지 마크업.
/// 반투명 배경은 원본 rgba 값을 ARGB 리터럴로 옮긴 것입니다.
/// (흰 카드 위에 올린다는 전제. 다른 배경 위에 쓰면 톤이 달라집니다.)
class AppBadges {
  const AppBadges._();

  // ── 근태 상태 ─────────────────────────────────────────────
  /// 정상 출근 · 소정 근로 · 직급 배지
  static const BadgeColors normal = BadgeColors(
    background: Color(0xFFD5E7F7),
    foreground: Color(0xFF32587C),
  );

  /// 지각 (차감 없음)
  static const BadgeColors lateArrival = BadgeColors(
    background: Color(0x38B4946C), // rgba(180,148,108,0.22)
    foreground: Color(0xFF6B4E28),
  );

  /// 외근 · 출장 (GPS 면제)
  static const BadgeColors fieldWork = BadgeColors(
    background: Color(0x298969EA), // rgba(137,105,234,0.16)
    foreground: Color(0xFF50379B),
  );

  /// 휴가 (집계 제외)
  static const BadgeColors vacation = BadgeColors(
    background: Color(0x29EE8C23), // rgba(238,140,35,0.16)
    foreground: Color(0xFF8A4A0B),
  );

  /// 추가 근무 (+10P/h)
  static const BadgeColors overtime = BadgeColors(
    background: Color(0x2433C41D), // rgba(51,196,29,0.14)
    foreground: Color(0xFF1E6B12),
  );

  /// 결근
  static const BadgeColors absent = BadgeColors(
    background: Color(0xFFF3F4F5),
    foreground: Color(0xFF555D6D),
  );

  // ── 처리 상태 ─────────────────────────────────────────────
  /// 완료 (화면 진행 · 계획 완료)
  static const BadgeColors done = BadgeColors(
    background: Color(0xFFD9F6E9),
    foreground: Color(0xFF00745F),
  );

  /// 결재 승인
  static const BadgeColors approved = BadgeColors(
    background: Color(0x2433C41D), // rgba(51,196,29,0.14)
    foreground: Color(0xFF00745F),
  );

  /// 미착수
  static const BadgeColors notStarted = BadgeColors(
    background: Color(0xFFF3F4F5),
    foreground: Color(0xFF868B94),
  );

  // ── 포인트 ────────────────────────────────────────────────
  /// 포인트 적립 (+50P)
  static const BadgeColors pointGain = BadgeColors(
    background: Color(0xFFD5E7F7),
    foreground: Color(0xFF2878C7),
  );

  /// 포인트 차감
  static const BadgeColors pointLoss = BadgeColors(
    background: Color(0xFFFDE7E7),
    foreground: Color(0xFFCA1D13),
  );

  /// 포인트 상태: 적립 가능
  static const BadgeColors pointClaimable = BadgeColors(
    background: Color(0xFFFFF1C7),
    foreground: Color(0xFF9A6200),
  );

  /// 적립 완료 (비활성 톤)
  static const BadgeColors settled = BadgeColors(
    background: Color(0xFFF3F4F5),
    foreground: Color(0xFFB0B3BA),
  );

  // ── 계획 카테고리 ─────────────────────────────────────────
  /// 코딩테스트 · 알고리즘
  static const BadgeColors categoryCodingTest = BadgeColors(
    background: Color(0x3870B187), // rgba(112,177,135,0.22)
    foreground: Color(0xFF2F5C40),
  );

  /// 자소서
  static const BadgeColors categoryResume = BadgeColors(
    background: Color(0x38B4946C), // rgba(180,148,108,0.22)
    foreground: Color(0xFF6B4E28),
  );

  /// 전공 · 인강
  static const BadgeColors categoryMajor = BadgeColors(
    background: Color(0xFFD5E7F7),
    foreground: Color(0xFF32587C),
  );

  // ── 필터 칩 ───────────────────────────────────────────────
  /// 선택된 필터 칩 (반경 · 시간대 · 희망 기업 등)
  static const BadgeColors chipSelected = BadgeColors(
    background: Color(0x0F326FE9), // rgba(50,111,233,0.06)
    foreground: Color(0xFF2558C4),
  );

  /// 미선택 필터 칩 (테두리는 AppColors.hairline)
  static const BadgeColors chipUnselected = BadgeColors(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF555D6D),
  );

  // ── 강조 배지 (솔리드) ────────────────────────────────────
  /// 결재 관련 강조
  static const BadgeColors approvalAccent = BadgeColors(
    background: AppColors.vacation,
    foreground: AppColors.onPrimary,
  );

  /// 주 동선 강조
  static const BadgeColors primaryAccent = BadgeColors(
    background: AppColors.primary,
    foreground: AppColors.onPrimary,
  );
}

/// 모서리 반경 · 간격 · 터치 타깃 (문서 "타이포 · 규격" 표)
class AppRadius {
  const AppRadius._();

  static const double card = 16;
  static const double field = 10;
  static const double sheet = 20;
  static const double pill = 999;
}

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;

  /// 화면 좌우 여백 · 카드 내부 여백
  static const double screenH = 16;
  static const double cardPadding = 16;

  /// 최소 터치 타깃 / 주 버튼 높이
  static const double minTouch = 44;
  static const double primaryButtonHeight = 56;
}