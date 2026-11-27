import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/auth/presentation/login/login_controller.dart';

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
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Builder(
          builder: (context) {
            final c = context.colors;
            final t = context.textStyles;
            return Scaffold(
              body: SafeArea(
                child: GestureDetector(
                  // 입력칸 밖을 누르면 키보드를 내린다.
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: '뒤로 가기',
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft),
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20, color: c.textPrimary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: 'music is life'),
                          TextSpan(
                              text: '.', style: TextStyle(color: c.accent)),
                        ]),
                        style: AppTypography.display(
                            size: 20, color: c.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Text('다시 만나서\n반가워요',
                          style: t.headlineMedium
                              ?.copyWith(fontSize: 28, height: 1.32)),
                      const SizedBox(height: AppSpacing.s),
                      Text('오늘의 인생곡을 이어서 기록해 보세요.',
                          style:
                              t.bodyMedium?.copyWith(color: c.textSecondary)),
                      const SizedBox(height: AppSpacing.xxl),
                      Form(
                        key: _formKey,
                        autovalidateMode: _autovalidate,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _FieldLabel('이메일'),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              validator: _controller.validateEmail,
                              onSaved: (value) =>
                                  _controller.email = value!.trim(),
                              onFieldSubmitted: (_) =>
                                  _passwordFocus.requestFocus(),
                              decoration: const InputDecoration(
                                  hintText: 'name@example.com'),
                            ),
                            const SizedBox(height: AppSpacing.l),
                            const _FieldLabel('비밀번호'),
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
                                suffixIcon: IconButton(
                                  tooltip: _obscure ? '비밀번호 보기' : '비밀번호 숨기기',
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: c.textTertiary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Obx(() {
                        final loading = _controller.isLoading.value;
                        return FilledButton(
                          onPressed: loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            disabledBackgroundColor: c.textPrimary,
                            disabledForegroundColor: c.surface,
                          ),
                          child: loading
                              ? SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.2, color: c.surface),
                                )
                              : const Text('로그인'),
                        );
                      }),
                      const SizedBox(height: AppSpacing.m),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('아직 계정이 없나요?', style: t.bodySmall),
                          TextButton(
                            // 로그인 화면을 시작하기(회원가입)로 바꾼다. 뒤로 가면 웰컴으로 돌아간다.
                            onPressed: () => Get.offNamed(Routes.join),
                            child: Text('시작하기',
                                style: t.labelLarge
                                    ?.copyWith(color: c.accentText)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.s),
      child: Text(text,
          style: context.textStyles.labelLarge
              ?.copyWith(color: context.colors.textSecondary)),
    );
  }
}
