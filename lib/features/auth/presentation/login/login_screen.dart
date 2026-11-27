import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/auth/presentation/login/login_controller.dart';
import 'package:music_is_life/features/auth/presentation/widgets/auth_page.dart';

/// 로그인: 다시 만나서 반가워요 · 이메일 · 비밀번호 · [로그인] · 시작하기로 가기
class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFocus = FocusNode();
  var _obscure = true;

  // 처음에는 입력 중에 오류를 띄우지 않고, 한 번 제출한 뒤부터 바로바로 알려준다.
  var _autovalidate = AutovalidateMode.disabled;

  LoginController get _controller => Get.find<LoginController>();

  Future<void> _submit() async {
    if (_controller.isLoading.value) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    _formKey.currentState!.save();

    final result = await _controller.login();
    if (!mounted) return;
    switch (result) {
      case Success():
        // 뒤로가기로 로그인 화면에 돌아오지 않도록 이전 화면을 모두 지운다.
        Get.offAllNamed(Routes.home);
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
  }

  @override
  void dispose() {
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: '다시 만나서\n반가워요',
      subtitle: '오늘의 인생곡을 이어서 기록해 보세요.',
      children: [
        Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthFieldLabel('이메일'),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                validator: _controller.validateEmail,
                onSaved: (value) => _controller.email = value!.trim(),
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                decoration: const InputDecoration(hintText: 'name@example.com'),
              ),
              const SizedBox(height: AppSpacing.l),
              const AuthFieldLabel('비밀번호'),
              TextFormField(
                focusNode: _passwordFocus,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: _controller.validatePassword,
                onSaved: (value) => _controller.password = value!,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: '6자리 이상',
                  suffixIcon: PasswordVisibilityButton(
                    obscured: _obscure,
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Obx(() => AuthSubmitButton(
              label: '로그인',
              loading: _controller.isLoading.value,
              onPressed: _submit,
            )),
        const SizedBox(height: AppSpacing.m),
        AuthSwitchLink(
          question: '아직 계정이 없나요?',
          action: '시작하기',
          // 로그인 화면을 시작하기(회원가입)로 바꾼다. 뒤로 가면 웰컴으로 돌아간다.
          onPressed: () => Get.offNamed(Routes.join),
        ),
      ],
    );
  }
}
