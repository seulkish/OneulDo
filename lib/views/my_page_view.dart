// filename: ../views/my_page_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

import '../theme/app_colors.dart';
import '../widgets/app_bar.dart';

class MyPageView extends StatefulWidget {
  const MyPageView({super.key});

  @override
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirestoreService  _fs = FirestoreService();
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userFuture = _fs.readUser();
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();

      if (!mounted) return;

      context.go('/login');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그아웃에 실패했습니다.'),
        ),
      );
    }
  }

  Future<void> _withdrawAccount() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    debugPrint('현재 로그인 UID: ${currentUser?.uid}');
    debugPrint('현재 로그인 이메일: ${currentUser?.email}');

    if (currentUser == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 세션이 없습니다. 다시 로그인해 주세요.'),
        ),
      );

      context.go('/login');
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('회원 탈퇴'),
          content: const Text(
            '계정과 사용자 정보가 모두 삭제됩니다.\n정말 탈퇴하시겠어요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('탈퇴'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _fs.deleteUser();
      await _auth.deleteAccount();

      if (!mounted) return;

      context.go('/login');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = e.code == 'requires-recent-login'
          ? '보안을 위해 다시 로그인한 후 탈퇴해 주세요.'
          : '회원 탈퇴에 실패했습니다.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원 탈퇴 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvassub,
      appBar: CommonAppBar(title: '마이페이지', subtitle: '오늘의 설정과 정보를 관리해요',),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          children: [
            FutureBuilder(future: _userFuture, builder: (context, snapshot) {
              final userData = snapshot.data;
              if (userData == null) {
                return const Text('저장된 사용자 정보가 없습니다.');
              }
              return _ProfileSummaryCard(
                nickname: userData['nickname'] as String? ?? '사용자',
                email: userData['email'] as String? ?? '',
                profileImageUrl: userData['profileImageUrl'] as String?,
              );
            },
            ),
            const SizedBox(height: 16),

            _SettingsCard(
              onWorkplaceTap: () {
                context.go('/my-page/workplace');
              },
              onWorkTimeTap: () {
                context.go('/my-page/worktime');
              },
              onWorkPolicyTap: () {
                context.go('/my-page/work-policy');
              },
              onGoalTap: () {
                context.go('/my-page/goal');
              },
            ),
            const SizedBox(height: 16),

            const _NotificationSettingsCard(),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _signOut,
                  child: Text('로그아웃'),
                ),
                TextButton(
                  onPressed: _withdrawAccount,
                  child: const Text('회원 탈퇴'),
                ),
              ]
            ),

            // Center(
            //   child: TextButton(
            //     child: Text('목표 설정 바로가기'),
            //     onPressed: () {
            //       context.go('/signup/workplace/worktime/goal');
            //     },
            //   ),
            // ),

          ],
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String nickname;
  final String email;
  final String? profileImageUrl;

  const _ProfileSummaryCard({
    required this.nickname,
    required this.email,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final trimmedNickname = nickname.trim();
    final firstLetter = trimmedNickname.isNotEmpty ? trimmedNickname[0] : '오';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE1E3E6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.inkMuted.withValues(alpha: 0.2),
              ),
            ),
            child: profileImageUrl == null || profileImageUrl!.trim().isEmpty
                ? Text(
                firstLetter,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w600,
                  ),
                )
                : null,  
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '사원 · 입사 62일차 · 1,240P',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final VoidCallback onWorkplaceTap;
  final VoidCallback onWorkTimeTap;
  final VoidCallback onWorkPolicyTap;
  final VoidCallback onGoalTap;

  const _SettingsCard({
    required this.onWorkplaceTap,
    required this.onWorkTimeTap,
    required this.onWorkPolicyTap,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // color: AppColors.fill,
          color: const Color(0xFFE1E3E6),
        ),
      ),
      child: Column(
        children: [
          _SettingsMenuItem(
            title: '근무지',
            description: '중앙도서관 3층 열람실 · 반경 50m',
            onTap: onWorkplaceTap,
          ),
          const Divider(height: 1),
          _SettingsMenuItem(
            title: '근무 시간',
            description: '소정 근로 4시간 · 출근 08:00 ~ 11:00',
            onTap: onWorkTimeTap,
          ),
          const Divider(height: 1),
          // _SettingsMenuItem(
          //   title: '근태 구분과 처리 기준',
          //   description: '정상 출근 · 지각 · 외근/출장 · 휴가 · 추가 근무',
          //   onTap: onWorkPolicyTap,
          // ),
          // const Divider(height: 1),
          _SettingsMenuItem(
            title: '준비 목표',
            description: '공기업 · 자격증',
            onTap: onGoalTap,
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;
  final Widget? trailingIcon;

  const _SettingsMenuItem({
    required this.title,
    required this.description,
    this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                      height: 1.5
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailingIcon
              ?? Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: AppColors.inkMuted,
                ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSettingsCard extends StatefulWidget {
  const _NotificationSettingsCard({super.key});

  @override
  State<_NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<_NotificationSettingsCard> {
  bool _attendanceReminder = true;
  bool _workGoalNotification = true;
  bool _promotionNotification = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E3E6),),
      ),
      child: Column(
        children: [
          _SettingsMenuItem(
            title: '출근 리마인더',
            description: '탄력 근무 시작 30분 전 알림',
            trailingIcon: Switch(
              value: _attendanceReminder,
              onChanged: (value) {
                setState(() {
                  _attendanceReminder = value;
                });
              },
            ),
          ),
          const Divider(height: 1),
          _SettingsMenuItem(
            title: '소정 근로 달성 알림',
            description: '목표 시간을 채우면 알림',
            trailingIcon: Switch(
              value: _workGoalNotification,
              onChanged: (value) {
                setState(() {
                  _workGoalNotification = value;
                });
              },
            ),
          ),
          const Divider(height: 1),
          _SettingsMenuItem(
            title: '승진 알림',
            description: '직급 변동 시에만 알림',
            trailingIcon: Switch(
              value: _promotionNotification,
              onChanged: (value) {
                setState(() {
                  _promotionNotification = value;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
