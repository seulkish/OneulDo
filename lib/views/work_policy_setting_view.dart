import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

import '../widgets/sub_page_app_bar.dart';

class WorkPolicySettingView extends StatelessWidget {
  const WorkPolicySettingView({super.key});

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
                    children: [
                      Expanded(
                        child: Text(
                          '지난달 근태 집계',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                      Text('집계 날짜: 08.01 ~ 08.31')
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              )

            ), 
            
            
          ],
        ),
      ),
    );
  }
}

class _ extends StatelessWidget {
  const _({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

