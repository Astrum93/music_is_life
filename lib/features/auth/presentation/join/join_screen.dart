import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/auth/presentation/join/join_controller.dart';
import 'package:music_is_life/features/auth/presentation/widgets/auth_page.dart';

/// 회원가입: 이름 · 이메일 · 비밀번호(+재확인) · 휴대전화 · [가입하기] · 로그인으로 가기
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _formKey = GlobalKey<FormState>();
  var _obscure = true;

  // 처음에는 입력 중에 오류를 띄우지 않고, 한 번 제출한 뒤부터 바로바로 알려준다.
  var _autovalidate = AutovalidateMode.disabled;

  JoinController get _controller => Get.find<JoinController>();

  Future<void> _submit() async {
    if (_controller.isLoading.value) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    _formKey.currentState!.save();

    final result = await _controller.join();
    if (!mounted) return;
    switch (result) {
      case Success():
        // 가입하면 바로 로그인된 상태이므로 홈으로 이동한다.
        Get.offAllNamed(Routes.home);
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibility = PasswordVisibilityButton(
      obscured: _obscure,
      onPressed: () => setState(() => _obscure = !_obscure),
    );
    const gap = SizedBox(height: AppSpacing.l);

    return AuthPage(
      title: '나만의 음악 일기장을\n시작해요',
      subtitle: '한 곡씩 쌓일 당신의 스펙트럼이 여기서 시작돼요.',
      children: [
        Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthFieldLabel('이름'),
                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.nickname],
                  maxLength: 20,
                  validator: _controller.validateName,
                  onSaved: (value) => _controller.name = value!.trim(),
                  decoration: const InputDecoration(
                    hintText: '2자 이상',
                    helperText: '다른 사람에게 보이는 이름이에요.',
                    counterText: '',
                  ),
                ),
                gap,
                const AuthFieldLabel('이메일'),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  validator: _controller.validateEmail,
                  onSaved: (value) => _controller.email = value!.trim(),
                  decoration:
                      const InputDecoration(hintText: 'name@example.com'),
                ),
                gap,
                const AuthFieldLabel('비밀번호'),
                TextFormField(
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: _controller.validatePassword,
                  // 재확인 검사가 지금 입력한 비밀번호와 비교하도록 입력할 때마다 넘긴다.
                  onChanged: (value) => _controller.password = value,
                  decoration: InputDecoration(
                      hintText: '6자리 이상', suffixIcon: visibility),
                ),
                const SizedBox(height: AppSpacing.s),
                TextFormField(
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  validator: _controller.validatePasswordConfirm,
                  onSaved: (value) => _controller.passwordConfirm = value!,
                  decoration: const InputDecoration(hintText: '비밀번호 한 번 더'),
                ),
                gap,
                const AuthFieldLabel('휴대전화'),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: _controller.validatePhoneNumber,
                  onSaved: (value) => _controller.phoneNumber = value!.trim(),
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(hintText: '010-1234-5678'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Obx(() => AuthSubmitButton(
              label: '가입하기',
              loading: _controller.isLoading.value,
              onPressed: _submit,
            )),
        const SizedBox(height: AppSpacing.m),
        AuthSwitchLink(
          question: '이미 계정이 있나요?',
          action: '로그인',
          // 회원가입 화면을 로그인으로 바꾼다. 뒤로 가면 웰컴으로 돌아간다.
          onPressed: () => Get.offNamed(Routes.login),
        ),
      ],
    );
  }
}
