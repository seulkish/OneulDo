# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

OneulDo "오늘부터 나두" — a Flutter app that gamifies a job-seeker's daily routine as if it were a job: users "clock in" by GPS at a chosen workplace (library, cafe…), accumulate work time, request leave, and earn points / career positions. Backend is Firebase only (Auth + Firestore; web build is served by Firebase Hosting, project `oneul-do`). UI text, comments, and commit messages are in Korean.

## Commands

```bash
flutter pub get
flutter run --dart-define-from-file=env.json      # add -d chrome for web
flutter analyze                   # lints: package:flutter_lints/flutter.yaml
flutter test                      # all tests
flutter test test/widget_test.dart --plain-name "<test name>"   # single test

# Web deploy (firebase.json hosting.public = build/web)
flutter build web --dart-define-from-file=env.json && firebase deploy --only hosting

# Regenerate icons / splash after changing assets/icons/*
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

`test/widget_test.dart` is still the default counter template and does not match the app (it also pumps `OneulApp`, which needs Firebase initialized) — treat it as a placeholder, not a passing baseline.

The Kakao Local REST API key for `PlaceSearchService` is read via `String.fromEnvironment('KAKAO_REST_API_KEY')`. Put it in the gitignored `env.json` (copy `env.example.json`) and pass `--dart-define-from-file=env.json` to every `flutter run`/`build` (the Android Studio `main.dart` run config already does). Without it, nearby-workplace search throws.

## Architecture

Plain layered structure with no state-management library — views are `StatefulWidget`s that instantiate services directly and use `setState` / `FutureBuilder`.

- `lib/main.dart` — initializes Firebase and `ko_KR` date formatting, uses path URL strategy. On web, the whole app is constrained to a phone-sized frame (`kMaxScreenWidth` 500, `kMinScreenHeight` 800) via `MaterialApp.builder`.
- `lib/routes/app_router.dart` — single global `GoRouter`.
  - Auth guard in `redirect` uses `FirebaseAuth.instance.currentUser`; `/landing`, `/login`, `/signup` are public.
  - Onboarding is nested routes under signup: `/signup/workplace/worktime/goal`.
  - Main tabs use `StatefulShellRoute.indexedStack` rendered by `views/app_shell.dart` (bottom nav): home `/`, `/record`, `/leave`, `/career`, `/my-page`. Each branch has its own navigator key; sub-pages that should cover the bottom nav set `parentNavigatorKey: _rootNavigatorKey`.
  - Navigate by route `name` (`context.goNamed(...)`); `/career` receives a `WorkStatus` via `state.extra`.
- `lib/services/`
  - `firestore_service.dart` — all Firestore reads/writes for the signed-in user (`users/{uid}` and subcollections). Returns raw `Map<String, dynamic>`; models in `lib/models/` parse them. Attendance writes (clock-in/out, field work, overtime) use transactions.
  - `firebase_auth_service.dart` — email/password auth, sign-out, account deletion (also removes the user doc).
  - `place_search_service.dart` — Kakao Local keyword search around the current location (2 km, widening to 5 km if fewer than 3 results).
- `lib/models/work_status.dart` — `WorkStatus` enum (beforeWork, working, fieldWork, completed, vacation, overtime, absent) is the central state driving home/career UI; `workStatusFromFirestore` maps the stored string. Visual mapping lives in `lib/theme/work_status_style.dart`.
- `lib/theme/` — `AppColors` design tokens (single accent `primary` #326FE9; other colors are reserved for attendance-status display), `AppTheme.light`, fonts Pretendard / GmarketSans. Use these tokens and shared widgets in `lib/widgets/` (`AppButton`, `AppCard`, `SubPageAppBar`, `StatusBadge`, …) rather than ad-hoc styling.

## Data model & time conventions

`docs/firestore_schema.md` documents the Firestore layout — keep it in sync when adding fields:

```
users/{uid}
├── workSettings/current
├── attendanceRecords/{yyyy-MM-dd}
├── schedules/{scheduleId}
├── leaveRequests/{requestId}
└── notifications/{notificationId}
```

Dates are computed in KST explicitly (`DateTime.now().toUtc().add(Duration(hours: 9))`), not device local time; attendance doc IDs are the KST `yyyy-MM-dd`. Timestamps written to Firestore use `FieldValue.serverTimestamp()`.

## Agent skills

Firebase agent skills are vendored under `.claude/skills/` and `.agents/skills/` (tracked in `skills-lock.json`). Use them for Firestore rules, Auth, Hosting, etc.
