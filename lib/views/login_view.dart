// filename: ../views/login_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/common_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuthService();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('로그인', style: theme.textTheme.displaySmall),
              const SizedBox(height: 8),

              Text(
                '1인 기업 대표이자 사원으로\n오늘도 목표를 향해 출근해 볼까요?',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('이메일', style: theme.textTheme.bodyMedium),
                  ),
                  const SizedBox(height: 8),
                  CommonTextField(controller: _emailController,label: '이메일을 입력해주세요'),
                  const SizedBox(height: 24),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('비밀번호', style: theme.textTheme.bodyMedium),
                        GestureDetector(
                          onTap: _resetPassword,
                          child: Text(
                            '비밀번호 재설정',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CommonTextField(
                    label: '비밀번호를 입력해주세요',
                    controller: _passwordController,
                    obscureText: true,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.inkFaint,
                      ),
                    ),
                  ), // 비밀번호 기능-isPassword: true
                ],
              ),
              const SizedBox(height: 48),

              CommonButton(
                text: '로그인',
                onPressed: _login,
                version: ButtonVersion.login,
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 18),
                    child: Text(
                      '간편 로그인',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              CommonButton(
                text: '카카오로 시작하기',
                version: ButtonVersion.kakao,
                onPressed: () {},
              ),
              const SizedBox(height: 12),

              CommonButton(
                text: '네이버로 시작하기',
                version: ButtonVersion.naver,
                onPressed: () {},
              ),
              const SizedBox(height: 12),

              CommonButton(
                text: '구글로 시작하기',
                version: ButtonVersion.google,
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    // color: const Color(0xFFD9DCE2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으면?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      context.go('/signup');
                    },
                    child: Text(
                      '회원가입',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    debugPrint('email: "${_emailController.text}"');
    debugPrint('password length: ${_passwordController.text.length}');

    try {
      await _auth.signInWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'invalid-credential' => '이메일 또는 비밀번호를 확인해주세요.',
        'invalid-email' => '이메일 형식이 올바르지 않습니다.',
        'too-many-requests' => '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요.',
        'channel-error' => '로그인 정보를 확인해주세요.',
        _ => '로그인에 실패했습니다. (${e.code})',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    final email = await _showResetPasswordDialog();
    if (email == null) return;

    try {
      await _auth.sendPasswordResetEmail(email);

      if (!mounted) return;
      _showMessage('비밀번호 재설정 이메일을 발송했습니다.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage(e.message ?? '이메일 발송에 실패했습니다.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('이메일 발송에 실패했습니다.');
    }
  }

  Future<String?> _showResetPasswordDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('비밀번호 재설정'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: '가입한 이메일을 입력해주세요.',
              ),
              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty) {
                  return '이메일을 입력해주세요.';
                }

                if (!email.contains('@')) {
                  return '올바른 이메일 형식이 아닙니다.';
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(
                    controller.text.trim(),
                  );
                }
              },
              child: const Text('이메일 발송'),
            ),
          ],
        );
      },
    );

    // controller.dispose();
    return email;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
