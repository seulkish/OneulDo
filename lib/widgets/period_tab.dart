import 'package:flutter/material.dart';

enum PeriodType { weekly, monthly }

class PeriodTab extends StatelessWidget {
  final PeriodType selectedPeriod;
  final ValueChanged<PeriodType> onChanged;

  const PeriodTab({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _buildTab(
            context,
            text: '주간',
            period: PeriodType.weekly,
          ),
          _buildTab(
            context,
            text: '월간',
            period: PeriodType.monthly,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      BuildContext context, {
        required String text,
        required PeriodType period,
      }) {
    final isSelected = selectedPeriod == period;

    return Expanded(
      child: InkWell(
        onTap: () => onChanged(period),
        borderRadius: BorderRadius.circular(12),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(
          Colors.transparent,
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: const Color(0xFFE1E4E8))
                : null,
            boxShadow: isSelected
                ? const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ]
                : null,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isSelected
                  ? const Color(0xFF111111)
                  : const Color(0xFF9CA3AF),
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}