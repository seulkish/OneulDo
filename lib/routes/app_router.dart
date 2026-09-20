// filename: routes/app_router.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../views/app_shell.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/set_workplace_view.dart';
import '../views/set_worktime_view.dart';
import '../views/set_goal_view.dart';
import '../views/career_view.dart';
import '../views/leave_request_view.dart';
import '../views/leave_approval_view.dart';
import '../views/study_record_view.dart';
import '../views/my_page_view.dart';
import '../views/landing_view.dart';
import '../views/workplace_setting_view.dart';
import '../views/worktime_setting_view.dart';
import '../views/work_policy_setting_view.dart';
import '../views/goal_setting_view.dart';
import '../views/notification_view.dart';

import '../models/work_status.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'home',
);
final GlobalKey<NavigatorState> _recordNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'record',
);
final GlobalKey<NavigatorState> _careerNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'career',
);
final GlobalKey<NavigatorState> _leaveNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'leave',
);
final GlobalKey<NavigatorState> _myPageNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'myPage',
);

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/landing',
  redirect: (context, state) {
    final isLoggedIn =
        FirebaseAuth.instance.currentUser != null;

    final path = state.uri.path;

    final isAuthRoute =
        path == '/landing' ||
            path == '/login' ||
            path == '/signup' ||
            path.startsWith('/signup/');

    // 비로그인 사용자의 일반 화면 접근 차단
    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    // 로그인 사용자는 홈으로 이동
    if (isLoggedIn && isAuthRoute) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/landing',
      name: 'landing',
      builder: (context, state) => const LandingView(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupView(),
      routes: [
        GoRoute(
          path: 'workplace',
          name: 'setWorkplace',
          builder: (context, state) => const SetWorkplaceView(),
          routes: [
            GoRoute(
              path: 'worktime',
              name: 'setWorkTime',
              builder: (context, state) => const SetWorkTimeView(),
              routes: [
                GoRoute(
                  path: 'goal',
                  name: 'setGoal',
                  builder: (context, state) => const SetGoalView(),)
              ]
            )
          ]
        ),
      ]
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeView(),
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  path: 'notification',
                  name: 'notification',
                  builder: (context, state) => const NotificationView(),
                ),
              ]
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _recordNavigatorKey,
          routes: [
            GoRoute(
              path: '/record',
              name: 'record',
              builder: (context, state) {
                return StudyRecordView();
              }
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _leaveNavigatorKey,
          routes: [
            GoRoute(
              path: '/leave',
              name: 'leave',
              builder: (context, state) => const LeaveRequestView(),
              routes: [
                GoRoute(
                  path: '/approval',
                  name: 'approval',
                  builder: (context, state) => const LeaveApprovalView(),
                ),
              ]
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _careerNavigatorKey,
          routes: [
            GoRoute(
              path: '/career',
              name: 'career',
              //builder: (context, state) => const CareerView(status: WorkStatus.beforeWork,),
              builder: (context, state) {
                final status =
                    state.extra as WorkStatus? ?? WorkStatus.beforeWork;
                return CareerView(status: status);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _myPageNavigatorKey,
          routes: [
            GoRoute(
              path: '/my-page',
              name: 'myPage',
              builder: (context, state) => const MyPageView(),
              routes: [
                GoRoute(
                  path: 'workplace',
                  name: 'myPageWorkplace',
                  builder: (context, state) => const WorkplaceSettingView(),
                ),
                GoRoute(
                  path: 'worktime',
                  name: 'myPageWorktime',
                  builder: (context, state) => const WorktimeSettingView(),
                ),
                GoRoute(
                  path: 'work-policy',
                  name: 'myPageWorkPolicy',
                  builder: (context, state) => const WorkPolicySettingView(),
                ),
                GoRoute(
                  path: 'goal',
                  name: 'myPageGoal',
                  builder: (context, state) => const GoalSettingView(),
                ),
              ]
            ),
          ],
        ),
      ],
    ),
  ],
);
