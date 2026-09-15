import 'package:flutter/material.dart';

import '../widgets/summary_item.dart';

class WorkSummaryCard extends StatelessWidget {
  final String workDays;
  final String totalWorkHours;
  final String averageWorkHours;

  const WorkSummaryCard({
    super.key,
    required this.workDays,
    required this.totalWorkHours,
    required this.averageWorkHours,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB),),
      ),
      child: Row(
        children: [
          Expanded(
            child: SummaryItem(
              label: '출근일',
              value: workDays,
            ),
          ),
          _divider(),
          Expanded(
            child: SummaryItem(
              label: '총 근무',
              value: totalWorkHours,
            ),
          ),
          _divider(),
          Expanded(
            child: SummaryItem(
              label: '일평균',
              value: averageWorkHours,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE5E7EB),
    );
  }
}

