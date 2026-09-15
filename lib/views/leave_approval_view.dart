import 'package:flutter/material.dart' ;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../theme/app_colors.dart';
import '../widgets/app_card.dart';

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

class LeaveApprovalView extends StatefulWidget {
  const LeaveApprovalView({super.key});

  @override
  State<LeaveApprovalView> createState() => _LeaveApprovalViewState();
}

class _LeaveApprovalViewState extends State<LeaveApprovalView>
    with SingleTickerProviderStateMixin {
  ApprovalStatus _status = ApprovalStatus.pending;

  late final AnimationController _stampController;
  late final Animation<double> _stampScale;
  late final Animation<double> _stampOpacity;
  late final Animation<double> _stampRotation;

  @override
  void initState() {
    super.initState();

    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // 크게 내려왔다가 살짝 튕기면서 원래 크기로 돌아옵니다.
    _stampScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 2.5,
          end: 0.85,
        ).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.85,
          end: 1,
        ).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 30,
      ),
    ]).animate(_stampController);

    // 도장이 찍히는 순간 나타납니다.
    _stampOpacity = CurvedAnimation(
      parent: _stampController,
      curve: const Interval(
        0.1,
        0.5,
        curve: Curves.easeIn,
      ),
    );

    // 약간 비스듬하게 찍히도록 회전합니다.
    _stampRotation = Tween<double>(
      begin: -0.15,
      end: -0.04,
    ).animate(
      CurvedAnimation(
        parent: _stampController,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _approve() async {
    if (_status != ApprovalStatus.pending) return;

    setState(() {
      _status = ApprovalStatus.approved;
    });

    // 도장이 찍히는 순간 진동을 발생시킵니다.
    await Future<void>.delayed(
      const Duration(milliseconds: 280),
    );

    if (!mounted) return;

    HapticFeedback.mediumImpact();

    await _stampController.forward(from: 0);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('휴가 신청을 승인했습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _reject() {
    if (_status != ApprovalStatus.pending) return;

    HapticFeedback.lightImpact();

    setState(() {
      _status = ApprovalStatus.rejected;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('휴가 신청을 반려했습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.ink,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결재 승인',
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '상신한 휴가 신청서를 확인해요',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        child: AppCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 결재 상태
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '휴가 신청서',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _ApprovalBadge(status: _status),
                ],
              ),
              const SizedBox(height: 24),

              // 신청 내용
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    _ApprovalInfoRow(
                      label: '종류',
                      value: '반차(오후)',
                    ),
                    SizedBox(height: 14),
                    _ApprovalInfoRow(
                      label: '사용일',
                      value: '9월 4일 (금)',
                    ),
                    SizedBox(height: 14),
                    _ApprovalInfoRow(
                      label: '기안자 / 결재자',
                      value: '본인 / 본인',
                    ),
                    SizedBox(height: 14),
                    _ApprovalInfoRow(
                      label: '사유',
                      value: '사유 미기재',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 결재 상태에 따라 다른 UI 표시
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: switch (_status) {
                  ApprovalStatus.pending => _PendingApprovalArea(
                    key: const ValueKey('pending'),
                    onReject: _reject,
                    onApprove: _approve,
                  ),
                  ApprovalStatus.approved => _ApprovedArea(
                    key: const ValueKey('approved'),
                    controller: _stampController,
                    scaleAnimation: _stampScale,
                    opacityAnimation: _stampOpacity,
                    rotationAnimation: _stampRotation,
                  ),
                  ApprovalStatus.rejected => const _RejectedArea(
                    key: ValueKey('rejected'),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingApprovalArea extends StatelessWidget {
  final VoidCallback onReject;
  final VoidCallback onApprove;

  const _PendingApprovalArea({
    super.key,
    required this.onReject,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이 문서의 결재선은 본인 한 명입니다. '
              '스스로 승인해 처리할 수 있습니다.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.inkMuted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(
                      color: AppColors.hairline,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    '반려',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    '승인함',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 승인 완료
class _ApprovedArea extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final Animation<double> rotationAnimation;

  const _ApprovedArea({
    super.key,
    required this.controller,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 165,
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Opacity(
              opacity: opacityAnimation.value,
              child: Transform.rotate(
                angle: rotationAnimation.value,
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: ApprovalStamp(
            date: DateFormat('yyyy.MM.dd').format(DateTime.now()),
            approver: '본인',
          ),
        ),
      ),
    );
  }
}

//반려 완료 영역
class _RejectedArea extends StatelessWidget {
  const _RejectedArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE7E7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cancel_outlined,
            color: AppColors.taskRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '반려 처리된 휴가 신청서입니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.taskRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 신청 정보
class _ApprovalInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ApprovalInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 115,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.inkFaint,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// 결재 상태 배지
class _ApprovalBadge extends StatelessWidget {
  final ApprovalStatus status;

  const _ApprovalBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ApprovalStatus.pending => '결재 대기',
      ApprovalStatus.approved => '승인 완료',
      ApprovalStatus.rejected => '반려',
    };

    final foreground = switch (status) {
      ApprovalStatus.pending => AppColors.inkMuted,
      ApprovalStatus.approved => AppColors.positive,
      ApprovalStatus.rejected => AppColors.taskRed,
    };

    final background = switch (status) {
      ApprovalStatus.pending => AppColors.fill,
      ApprovalStatus.approved => AppBadges.approved.background,
      ApprovalStatus.rejected => const Color(0xFFFDE7E7),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// 승인 도장
class ApprovalStamp extends StatelessWidget {
  final String date;
  final String approver;

  const ApprovalStamp({
    super.key,
    required this.date,
    required this.approver,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 140),
      painter: _ApprovalStampPainter(
        date: date,
        approver: approver,
      ),
    );
  }
}

class _ApprovalStampPainter extends CustomPainter {
  final String date;
  final String approver;

  const _ApprovalStampPainter({
    required this.date,
    required this.approver,
  });

  static const Color stampColor = Color(0xFFF32636);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final circlePaint = Paint()
      ..color = stampColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      size.width / 2 - 7,
      circlePaint,
    );

    _drawText(
      canvas: canvas,
      text: date,
      center: Offset(
        center.dx,
        center.dy - 31,
      ),
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    _drawText(
      canvas: canvas,
      text: '승인',
      center: Offset(
        center.dx,
        center.dy + 1,
      ),
      fontSize: 32,
      fontWeight: FontWeight.w800,
    );

    _drawText(
      canvas: canvas,
      text: approver,
      center: Offset(
        center.dx,
        center.dy + 37,
      ),
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
  }

  void _drawText({
    required Canvas canvas,
    required String text,
    required Offset center,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: stampColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(
      covariant _ApprovalStampPainter oldDelegate,
      ) {
    return date != oldDelegate.date ||
        approver != oldDelegate.approver;
  }
}