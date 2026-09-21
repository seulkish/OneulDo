// filename: widgets/sub_page_app_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/firestore_service.dart';

import '../theme/app_colors.dart';

class SubPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String position;
  const SubPageAppBar({
    super.key,
    required this.title,
    required this.position,
  });

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: ShapedInputBorder(
        shape: Border.all(),
        borderSide: BorderSide(color: Colors.black12),
      ),
      elevation: 0,
      toolbarHeight: 76,

      leadingWidth: 64,
      leading: IconButton(
        onPressed: () {
          context.go('/my-page');
        },
        icon: const Icon(Icons.chevron_left_rounded, size: 36),
      ),

      titleSpacing: 0,
      title: Text(
        title,
        style: textTheme.headlineSmall?.copyWith(
          fontFamily: 'GmarketSans',
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
      ),

      actions: [
        // 사원 Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            position,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 14),

        // 알림 아이콘 + 개수 Badge
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 29,
                  color: AppColors.inkMuted,
                ),
              ),

              Positioned(
                top: 2,
                right: 1,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.taskRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '2',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
