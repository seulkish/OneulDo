// filename: ../widgets/status_badge.dart

import 'package:flutter/material.dart';

import '../models/work_status.dart';
import '../theme/work_status_style.dart';

class StatusBadge extends StatelessWidget {
  final WorkStatus status;
  final String? label;

  const StatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final text = label ?? status.label;
    final colors = status.badgeColors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      // width: status.label.length * 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: textTheme.labelSmall?.copyWith(
              color: colors.foreground,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: colors.foreground,
              shape: BoxShape.circle
            ),
          )
        ],
      ),
    );
  }
}
