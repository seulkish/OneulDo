// filename: /widgets/app_button.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/status_badge.dart';
import '../models/schedule.dart';

enum ButtonVersion { login, normal, kakao, naver, google }

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final ButtonVersion version;
  final Widget? icon;
  final WorkStatus? status;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.version = ButtonVersion.normal,
    this.isEnabled = true,
    this.icon,
    this.status,
  }) ;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeStyle = theme.elevatedButtonTheme.style;

    final double radius = switch (version) {
      ButtonVersion.login => 12,
      ButtonVersion.kakao => 12,
      ButtonVersion.naver => 12,
      ButtonVersion.google => 12,
      ButtonVersion.normal => 35,
    };

    final Color normalBackgroundColor = switch (status) {
      WorkStatus.beforeWork => AppColors.primary,
      WorkStatus.working => AppColors.positive,
      WorkStatus.fieldWork => AppColors.fieldPurple,
      WorkStatus.completed => AppColors.inkMuted,
      WorkStatus.vacation => AppColors.vacation,
      WorkStatus.overtime => AppColors.liveGreen,
      WorkStatus.absent => AppColors.taskRed,
      null => AppColors.primary,
    };

    final Color backgroundColor = switch (version) {
      ButtonVersion.kakao => const Color(0xFFFEE500),
      ButtonVersion.naver => const Color(0xFF03C75A),
      ButtonVersion.google => Colors.white,
      ButtonVersion.normal => normalBackgroundColor,
      _ => Theme.of(context).colorScheme.primary,
    };

    final Color foregroundColor = switch (version) {
      ButtonVersion.kakao => const Color(0xFF191919),
      ButtonVersion.naver => Colors.white,
      ButtonVersion.google => const Color(0xFF191919),
      _ => Colors.white,
    };

    final BorderSide borderSide = switch (version) {
      ButtonVersion.google => const BorderSide(
      color: Color(0xFFDCDEE3),
      width: 1,
    ),
    _ => BorderSide.none,
    };

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: themeStyle?.copyWith(
          backgroundColor: WidgetStatePropertyAll(backgroundColor),
          foregroundColor: WidgetStatePropertyAll(foregroundColor),
          side: WidgetStatePropertyAll(borderSide),
          elevation: const WidgetStatePropertyAll(3),
          shadowColor: const WidgetStatePropertyAll(
            Color(0x40000000),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (icon != null)
              Align(alignment: Alignment.centerLeft, child: icon!),
            Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 20,
                // fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
