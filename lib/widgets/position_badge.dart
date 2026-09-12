// lib/widgets/position_badge.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'status_badge.dart';

class PositionBadge extends StatelessWidget {
  final String position;
  final BadgeColors colors;

  const PositionBadge({
    super.key,
    required this.position,
    this.colors = AppBadges.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        position,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
