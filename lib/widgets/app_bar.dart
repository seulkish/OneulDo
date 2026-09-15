// filename: widgets/app_bar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/position_badge.dart';
import '../models/work_status.dart';
import '../theme/work_status_style.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final Widget? positionBadge;
  final int notificationCount;
  final VoidCallback? onNotificationPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.positionBadge,
    this.notificationCount = 0,
    this.onNotificationPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final WorkStatus status = WorkStatus.working;
    final currentPosition = '사원';
    final date = DateFormat(
      'yyyy. MM. dd (E)',
      'ko_KR',
    ).format(DateTime.now());

    return AppBar(
      backgroundColor: Colors.white,
      shape: ShapedInputBorder(
        shape: Border.all(),
        borderSide: BorderSide(color: Colors.black12),
      ),
      elevation: 15,
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      titleSpacing: 28,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            date,
            style: textTheme.titleSmall?.copyWith(color: AppColors.inkFaint),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontFamily: 'GmarketSans',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.labelSmall?.copyWith(color: AppColors.inkFaint),
          ),
        ],
      ),
      actions: [
        // 사원 Badge
        PositionBadge(position: currentPosition, colors: status.badgeColors),
        const SizedBox(width: AppSpacing.sm),

        // 알림 아이콘 + 알림 갯수 Badge
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  context.go('/notification');
                },
                icon: Icon(Icons.notifications_none),
              ),
              Positioned(
                top: 3,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
