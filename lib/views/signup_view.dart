// filename: ../views/signup_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oneul/widgets/common_text_field.dart';

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  //
  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
          child: Form(
            key: _formKey,
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

                const SizedBox(height: 8),

                Text('회원가입', style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),

                Text(
                  '1인 기업 대표이자 사원으로\n오늘부터 목표를 향해 입사해볼까요?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),

                // 닉네임
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('닉네임', style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  label: '닉네임을 입력해주세요',
                  controller: _nicknameController,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 이메일
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('이메일', style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  label: '이메일을 입력해주세요',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력해주세요';
                    }

                    final emailRegex = RegExp(
                      r'^[\w.%+-]+@[\w.-]+\.[a-zA-Z]{2,}$',
                    );

                    if (!emailRegex.hasMatch(email)) {
                      return '올바른 이메일 형식이 아닙니다';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('핸드폰 번호', style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 8),
                CommonTextField(
                  label: '핸드폰 번호를 입력해주세요',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '핸드폰 번호를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('비밀번호', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Text(
                        '* 비밀번호 6자리 이상',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                CommonTextField(
                  label: '비밀번호를 입력해주세요',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }

                    if (value.length < 6 ) {
                      return '비밀번호가 6자리 이상이어야 합니다';
                    }

                    return null;
                  },
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
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('비밀번호 확인', style: theme.textTheme.bodyMedium),
                ),
                const SizedBox(height: 8),

                CommonTextField(
                  label: '비밀번호를 다시 한 번 입력해주세요',
                  controller: _passwordConfirmController,
                  obscureText: _obscurePasswordConfirm,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }

                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }

                    return null;
                  },
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePasswordConfirm = !_obscurePasswordConfirm;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.inkFaint,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                CommonButton(
                  text: '다음 단계로',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.go('/signup/workplace');
                    }
                  },
                  version: ButtonVersion.login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
