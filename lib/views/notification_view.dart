import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

import '../models/notification.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {

  final List<AppNotification> _notifications = [
    AppNotification(
      title: '휴가가 승인되었습니다',
      description: '9월 5일 (금) 연차 · 결재자 본인',
      time: '방금',
      isRead: false,
    ),
    AppNotification(
      title: '출근 시각이 다가옵니다',
      description: '탄력 근무 시간대 시작 30분 전입니다.',
      time: '08:30',
    ),
    AppNotification(
      title: '주임 승진까지 260P',
      description: '오늘 소정 근로를 채우면 80P가 적립됩니다.',
      time: '어제',
      isRead: true,
    ),
  ];

  // firebase 연동 후 추가 구현 예정
  void _addNotification(AppNotification notification) {
    setState(() {
      _notifications.insert(0, notification);
    });
  }

  void _markAsRead(int index) {
    if (_notifications[index].isRead) return;

    setState(() {
      _notifications[index].isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  int get _unreadCount {
    return _notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvassub,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 76,

        leadingWidth: 64,
        leading: IconButton(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.chevron_left_rounded, size: 36),
        ),

        titleSpacing: 0,
        title: Text(
          '알림함',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
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
              '사원',
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
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),

            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '읽지 않은 알림 2건',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _unreadCount == 0
                      ? null
                      : _markAllAsRead,
                  child: const Text('모두 읽음'),
                ),
              ],
            ),
          ),
          
          Padding(padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
          ),
            child: _NotificationCard(
              notifications: _notifications,
              onNotificationTap: _markAsRead,
            ),
          ),

          // add 추가 테스트용 - 추후 지울 예정
          TextButton(
            onPressed: () {
              _addNotification(
                AppNotification(
                  title: '연속 출근 13일째',
                  description: '보너스 100P가 적립되었습니다.',
                  time: '방금',
                ),
              );
            },
            child: const Text('알림 추가'),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final List<AppNotification> notifications;
  final ValueChanged<int> onNotificationTap;

  const _NotificationCard({
    required this.notifications,
    required this.onNotificationTap,
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
        children: List.generate(
          notifications.length,
              (index) {
            final notification = notifications[index];

            return Column(
              children: [
                _NotificationMenuItem(
                  title: notification.title,
                  description: notification.description,
                  time: notification.time,
                  isRead: notification.isRead,
                  onTap: () => onNotificationTap(index),
                ),
                if (index < notifications.length - 1)
                  const Divider(height: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationMenuItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationMenuItem({
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
    required this.onTap,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead ? AppColors.fill : AppColors.primary
              ),
            ),
            const SizedBox(width: 14),
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
            Text(
              time,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}