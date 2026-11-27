import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

/// 로그인·회원가입 공통 틀: 뒤로 가기 · 로고 · 큰 제목 · 안내 문구 · [children]
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

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
                      Text(title,
                          style: t.headlineMedium
                              ?.copyWith(fontSize: 28, height: 1.32)),
                      const SizedBox(height: AppSpacing.s),
                      Text(subtitle,
                          style:
                              t.bodyMedium?.copyWith(color: c.textSecondary)),
                      const SizedBox(height: AppSpacing.xxl),
                      ...children,
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

/// 입력칸 위의 이름표
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

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

/// 비밀번호 보기/숨기기 버튼 (입력칸의 suffixIcon)
class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton(
      {super.key, required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: obscured ? '비밀번호 보기' : '비밀번호 숨기기',
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: context.colors.textTertiary,
      ),
    );
  }
}

/// 제출 버튼: 처리 중에는 같은 색을 유지한 채 로딩 표시로 바뀌고 눌리지 않는다.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        disabledBackgroundColor: c.textPrimary,
        disabledForegroundColor: c.surface,
      ),
      child: loading
          ? SizedBox.square(
              dimension: 20,
              child:
                  CircularProgressIndicator(strokeWidth: 2.2, color: c.surface),
            )
          : Text(label),
    );
  }
}

/// 맨 아래 "아직 계정이 없나요? 시작하기" 같은 다른 화면으로 가는 줄
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.question,
    required this.action,
    required this.onPressed,
  });

  final String question;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, style: t.bodySmall),
        TextButton(
          onPressed: onPressed,
          child: Text(action,
              style: t.labelLarge?.copyWith(color: context.colors.accentText)),
        ),
      ],
    );
  }
}
