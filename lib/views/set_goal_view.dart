// filename: ../views/set_goal_view.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:go_router/go_router.dart';
import '../widgets/app_card.dart';
import '../widgets/common_text_field.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/status_badge.dart';
import '../widgets/position_badge.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class SetGoalView extends StatefulWidget {
  const SetGoalView({super.key});

  @override
  State<SetGoalView> createState() => _SetGoalViewState();
}

class _SetGoalViewState extends State<SetGoalView> {
  static const Set<String> _defaultGoals = {'공기업', '자격증'};

  final Set<String> _selectedGoals = {..._defaultGoals};

  static const String _goalsKey = 'selected_goals';

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

  Widget _arrow() {
    return const Icon(Icons.chevron_right, size: 16, color: AppColors.inkFaint);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final savedGoals = await _preferences.getStringList(_goalsKey);

    if (!mounted || savedGoals == null) return;

    setState(() {
      _selectedGoals
        ..clear()
        ..addAll(savedGoals);
    });
  }

  Future<void> _saveGoals() async {
    await _preferences.setStringList(_goalsKey, _selectedGoals.toList());
  }

  Future<void> _start() async {
    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('목표를 한 개 이상 선택해주세요.'),
        ),
      );
      return;
    }

    await _saveGoals();

    if (!mounted) return;
    context.go('/');
  }

  void _skip() {
    showConfirmDialog(
      context: context,
      title: '목표 설정을 건너뛸까요?',
      message: '목표를 설정하지 않으면 목표별 업무 템플릿과 포인트 제도가 적용되지 않습니다.',
      confirmText: '건너뛰기',
      cancelText: '계속 설정하기',
      onConfirm: _confirmSkip,
    );
  }

  Future<void> _confirmSkip() async {
    debugPrint('건너뛰기 확인 실행');

    _selectedGoals.clear();
    await _saveGoals();

    debugPrint('저장된 목표: $_selectedGoals');

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),

              // 3단계 진행 바
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 1,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                'STEP 3 / 3',
                style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              Text(
                '목표를 고릅니다',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Text('목표에 맞춰 업무 템플릿과 포인트 기준이 정해집니다. 나중에 마이페이지에서 바꿀 수 있습니다.'),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '준비 중인 목표',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Text(
                      '* 복수 선택 가능',
                      style: theme.textTheme.bodyMedium?.copyWith(
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
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('시작 직급은 인턴입니다', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 20),
                    Text(
                      '출근과 업무 완료로 포인트가 쌓이고, 기준 포인트를 넘기면 '
                      '직급이 올라갑니다. 무단 결근은 포인트가 차감됩니다.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkMuted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 4,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PositionBadge(position: '인턴', colors: AppBadges.normal),
                        _arrow(),
                        PositionBadge(position: '사원', colors: AppBadges.notStarted,),
                        _arrow(),
                        PositionBadge(position: '...', colors: AppBadges.notStarted,),
                        _arrow(),
                        PositionBadge(position: '이사', colors: AppBadges.notStarted,),
                        TextButton(
                          onPressed: () {
                            context.go('/career');
                          },
                          child: Text(
                            '자세히 보기',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(28, 12, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonButton(
              text: '출근하러 가기',
              onPressed: _start,
              version: ButtonVersion.normal,
              status: WorkStatus.beforeWork,
            ),
            // const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  '건너뛰고 시작하기',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.inkFaint,
                  ),
                ),
              ),
            ),
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
