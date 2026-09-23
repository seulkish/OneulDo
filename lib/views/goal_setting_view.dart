import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

import '../widgets/sub_page_app_bar.dart';
import '../widgets/app_button.dart';
import '../models/work_status.dart';

class GoalSettingView extends StatefulWidget {
  const GoalSettingView({super.key});

  @override
  State<GoalSettingView> createState() => _GoalSettingViewState();
}

class _GoalSettingViewState extends State<GoalSettingView> {
  static const Set<String> _defaultGoals = {'공기업', '자격증'};

  final Set<String> _selectedGoals = {..._defaultGoals};

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  final Set<String> _customGoals = {};

  final List<String> _goals = ['공기업', '대기업', '공무원', '자격증', '어학'];

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _showAddGoalDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('목표 직접 추가'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '목표를 입력해주세요'),
          ),
          actions: [
            TextButton(onPressed: () => dialogContext.pop(), child: const Text('취소')),
            FilledButton(
              onPressed: () {
                final goal = controller.text.trim();

                if (goal.isEmpty) return;

                if (_goals.contains(goal)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이미 등록된 목표입니다.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  _goals.add(goal);
                  _customGoals.add(goal);
                  _selectedGoals.add(goal);
                });

                dialogContext.pop();
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _removeGoal(String goal) {
    setState(() {
      _goals.remove(goal);
      _selectedGoals.remove(goal);
      _customGoals.remove(goal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: SubPageAppBar(title: '준비 목표 설정', position: '사원'),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '준비 중인 목표',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: Text(
                          '* 복수 선택 가능',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ..._goals.map(
                            (goal) => _GoalChip(
                          label: goal,
                          isSelected: _selectedGoals.contains(goal),
                          onTap: () => _toggleGoal(goal),
                          onDelete: _customGoals.contains(goal)
                              ? () => _removeGoal(goal)
                              : null,
                        ),
                      ),

                      _AddGoalChip(onTap: _showAddGoalDialog),
                    ],
                  ),
                ],
              ),
            ),

            Container()
          ],
        )
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 12, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonButton(
              text: '목표 내용 저장',
              onPressed: () {
                context.go('/my-page');
              },
              version: ButtonVersion.normal,
              status: WorkStatus.beforeWork,
            ),
            // const SizedBox(height: 8),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = isSelected
        ? AppBadges.chipSelected
        : AppBadges.chipUnselected;

    return Material(
      color: colors.background,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.hairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  Icons.check,
                  size: 18,
                  color: AppColors.primaryPressed,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (onDelete != null && !isSelected) ...[
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddGoalChip extends StatelessWidget {
  const _AddGoalChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.card,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.hairline)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 18, color: AppColors.inkMuted),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '직접 추가',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}