import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/constant/constants.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/widgets/button/check_button.dart';
import 'package:music_is_life/core/widgets/easy_text_form_field.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/auth/presentation/login/login_controller.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();

  LoginController get _controller => Get.find<LoginController>();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(context, '정보를 올바르게 입력해 주세요.');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),

      // 입력 제외 부분 Tap하면 키보드 사라지게
      body: Obx(
        () => ModalProgressHUD(
          inAsyncCall: _controller.isLoading.value,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 로그인 메인 이미지
                  const Center(
                    child: Image(
                      image: AssetImage('$basePath/icon/Login.png'),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // 메인 컨테이너
                  Container(
                    decoration: const BoxDecoration(color: Colors.black),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const _FieldLabel('이메일'),
                            const SizedBox(height: 15),

                            // 아이디 입력
                            EasyTextFormField(
                              key: const ValueKey(1),
                              keyboardType: TextInputType.emailAddress,
                              obscureText: false,
                              validator: (value) =>
                                  _controller.validateEmail(value as String?),
                              onSaved: (value) => _controller.email = value!,
                              onChanged: (value) => _controller.email = value,
                              prefixIcon: const Icon(
                                Icons.mail,
                                color: Colors.grey,
                              ),
                              hintText: "메일 주소",
                            ),
                            const SizedBox(height: 15),

                            const _FieldLabel('비밀번호'),
                            const SizedBox(height: 15),

                            // 비밀번호 입력
                            EasyTextFormField(
                              key: const ValueKey(2),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              validator: (value) =>
                                  _controller.validatePassword(value as String?),
                              onSaved: (value) => _controller.password = value!,
                              onChanged: (value) => _controller.password = value,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.grey,
                              ),
                              hintText: "비밀번호",
                            ),
                            const SizedBox(height: 35),

                            // 체크 버튼
                            CheckButton(
                              width: 40,
                              height: 40,
                              boxColor: AppColors.veryDarkGrey,
                              borderColor: Colors.transparent,
                              icon: Icons.check,
                              iconColor: Colors.green,
                              onTap: _submit,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
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
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
