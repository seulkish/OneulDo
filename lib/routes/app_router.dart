// filename: routes/app_router.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../views/app_shell.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/set_workplace_view.dart';
import '../views/set_worktime_view.dart';
import '../views/set_goal_view.dart';
import '../views/career_view.dart';
import '../views/leave_request_view.dart';
import '../views/study_record_view.dart';
import '../views/my_page_view.dart';
import '../views/landing_view.dart';

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
  redirect: (context, state) {},
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
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _recordNavigatorKey,
          routes: [
            GoRoute(
              path: '/record',
              name: 'record',
              builder: (context, state) => const StudyRecordView(),
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
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _careerNavigatorKey,
          routes: [
            GoRoute(
              path: '/career',
              name: 'career',
              builder: (context, state) => const CareerView(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _myPageNavigatorKey,
          routes: [
            GoRoute(
              path: '/my_page',
              name: 'myPage',
              builder: (context, state) => const MyPageView(),
            ),
          ],
        ),
      ],
    ),
  ],
);
