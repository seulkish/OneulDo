import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Oneul 앱 공통 테마.
///
/// 출처: `Oneul_Flow_dc.html` → "색상", "타이포 · 규격" 섹션.
/// 서체: Pretendard 단일 서체 (Figma 원본은 Gmarket Sans TTF).
/// 스케일 6단계: Display / Title 1 / Title 2 / Body L / Body / Caption
class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'Pretendard';

  /// 문서 모션 스펙: enter cubic-bezier(0, 0, .15, 1) · 150–300ms
  static const Curve enterCurve = Cubic(0, 0, 0.15, 1);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationBase = Duration(milliseconds: 300);

  static ThemeData get light {
    final textTheme = _textTheme;

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primaryPressed,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.card,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.fill,
        outline: AppColors.hairline,
        outlineVariant: AppColors.divider,
        error: AppColors.taskRed,
        onError: AppColors.onPrimary,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.ink, size: 24),
      ),

      // ── 카드 ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── 버튼: 주 CTA (pill, 높이 56, weight 600) ─────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.hairline,
          disabledForegroundColor: AppColors.inkFaint,
          minimumSize: const Size.fromHeight(AppSpacing.primaryButtonHeight),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: textTheme.titleMedium,
        ).copyWith(
          overlayColor: const WidgetStatePropertyAll(Color(0x1F000000)),
        ),
      ),

      // ── 버튼: 보조 (테두리 hairline, 텍스트 inkMuted) ─────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.inkMuted,
          backgroundColor: AppColors.card,
          minimumSize: const Size.fromHeight(AppSpacing.primaryButtonHeight),
          side: const BorderSide(color: AppColors.hairline),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: textTheme.bodyLarge,
        ),
      ),

      // ── 버튼: 텍스트 / 링크 ─────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPressed,
          minimumSize: const Size(0, AppSpacing.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── 입력창 (radius 10, 테두리 hairline) ──────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.inkFaint),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.primary,
        ),
        helperStyle: textTheme.bodySmall?.copyWith(color: AppColors.inkFaint),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.taskRed),
        border: _fieldBorder(AppColors.hairline),
        enabledBorder: _fieldBorder(AppColors.hairline),
        focusedBorder: _fieldBorder(AppColors.primary, width: 1.5),
        disabledBorder: _fieldBorder(AppColors.divider),
        errorBorder: _fieldBorder(AppColors.taskRed),
        focusedErrorBorder: _fieldBorder(AppColors.taskRed, width: 1.5),
      ),

      // ── 하단 탭 (홈 · 기록 · 결재 · 커리어 · 마이) ────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFFB0B3BA),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── 바텀시트 (radius 20) ────────────────────────────────
      // ── 하단 탭 (홈 · 기록 · 결재 · 커리어 · 마이) ────────────
      // M3 NavigationBar 용. BottomNavigationBarThemeData 는
      // NavigationBar 에 적용되지 않으므로 사용하지 않습니다.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        height: 64,
        // 디자인 원본에 알약 인디케이터가 없으므로 투명 처리
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.primary : _tabInactive,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.primary : _tabInactive,
          );
        }),
        overlayColor: const WidgetStatePropertyAll(Color(0x14000000)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // ── 배지 · 칩 (pill) ────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fill,
        labelStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.inkMuted,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: const StadiumBorder(),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.fill,
      ),

      iconTheme: const IconThemeData(color: AppColors.ink, size: 24),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),

      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// 하단 탭 비활성 색상 (문서 색상표 외 값)
  static const Color _tabInactive = Color(0xFFB0B3BA);

  /// 문서 6단계 스케일 → Material TextTheme 매핑
  ///
  /// Display   45 / 54    600  → displaySmall
  /// Title 1   34 / 34    500  → headlineMedium
  /// Title 2   22 / 30.8  600  → titleLarge
  /// Body L    16 / 24    600  → titleMedium (버튼·강조 리스트)
  /// Body L    16 / 24    400  → bodyLarge   (입력값·본문)
  /// Body      14 / 22.4  400  → bodyMedium
  /// Caption   12 / 19.2  600  → labelSmall  (배지·탭 라벨)
  /// Caption   12 / 19.2  400  → bodySmall
  ///
  /// height 값은 (행간 ÷ 크기) 로 계산했습니다.
  /// letterSpacing 은 문서 표에 수치가 없어 0 으로 두었습니다.
  /// (디자인 원본은 큰 글자에 -0.4 ~ -0.6px 정도의 음수 자간을 씁니다.
  ///  필요하면 아래 주석 처리된 값을 적용하세요.)
  static const TextTheme _textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 45,
      height: 54 / 45,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
      // letterSpacing: -0.9,
    ),
    headlineMedium: TextStyle(
      fontSize: 34,
      height: 1.0,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
      // letterSpacing: -0.6,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      height: 30.8 / 22,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
      // letterSpacing: -0.4,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 22.4 / 14,
      fontWeight: FontWeight.w400,
      color: AppColors.inkMuted,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      height: 19.2 / 12,
      fontWeight: FontWeight.w600,
      color: AppColors.inkMuted,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 19.2 / 12,
      fontWeight: FontWeight.w400,
      color: AppColors.inkFaint,
    ),
  );
}