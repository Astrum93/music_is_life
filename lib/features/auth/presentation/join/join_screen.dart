import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/constant/constants.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/widgets/button/check_button.dart';
import 'package:music_is_life/core/widgets/button/google_join_button.dart';
import 'package:music_is_life/core/widgets/easy_text_form_field.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/auth/presentation/join/join_controller.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _formKey = GlobalKey<FormState>();

  JoinController get _controller => Get.find<JoinController>();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(context, '정보를 올바르게 입력해 주세요.');
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
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
                  Center(
                    child: Image(
                      image: const AssetImage('$basePath/icon/vr-headset.png'),
                      // 화면 크기의 -10만큼의 가로 길이
                      width: MediaQuery.of(context).size.width - 10,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(color: Colors.black),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Center(
                              child: Text(
                                '회원가입',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // 이름
                            EasyTextFormField(
                              key: const ValueKey(1),
                              keyboardType: TextInputType.name,
                              obscureText: false,
                              validator: (value) =>
                                  _controller.validateName(value as String?),
                              onSaved: (value) => _controller.name = value!,
                              onChanged: (value) => _controller.name = value,
                              prefixIcon: const Icon(
                                Icons.account_circle,
                                color: Colors.grey,
                              ),
                              hintText: "이름 (ID)",
                            ),
                            const SizedBox(height: 15),

                            // 이메일
                            EasyTextFormField(
                              key: const ValueKey(2),
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

                            // 비밀번호
                            EasyTextFormField(
                              key: const ValueKey(3),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              validator: (value) =>
                                  _controller.validatePassword(value as String?),
                              onSaved: (value) => _controller.password = value!,
                              onChanged: (value) => _controller.password = value,
                              prefixIcon: const Icon(
                                Icons.lock_open_rounded,
                                color: Colors.grey,
                              ),
                              hintText: "비밀번호",
                            ),
                            const SizedBox(height: 15),

                            // 비밀번호 재확인
                            EasyTextFormField(
                              key: const ValueKey(4),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              validator: (value) => _controller
                                  .validatePasswordConfirm(value as String?),
                              onSaved: (value) =>
                                  _controller.passwordConfirm = value!,
                              onChanged: (value) =>
                                  _controller.passwordConfirm = value,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.grey,
                              ),
                              hintText: "비밀번호 재확인",
                            ),
                            const SizedBox(height: 15),

                            // 전화 번호
                            EasyTextFormField(
                              key: const ValueKey(5),
                              keyboardType: TextInputType.phone,
                              obscureText: false,
                              validator: (value) => _controller
                                  .validatePhoneNumber(value as String?),
                              onSaved: (value) =>
                                  _controller.phoneNumber = value!,
                              onChanged: (value) =>
                                  _controller.phoneNumber = value,
                              prefixIcon: const Icon(
                                Icons.phone_android_rounded,
                                color: Colors.grey,
                              ),
                              hintText: "전화번호 (000-0000-0000)",
                            ),

                            const SizedBox(height: 30),

                            // 회원가입 버튼
                            CheckButton(
                              width: 40,
                              height: 40,
                              boxColor: AppColors.veryDarkGrey,
                              borderColor: Colors.transparent,
                              icon: Icons.check,
                              iconColor: Colors.green,
                              onTap: _submit,
                            ),

                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '또는 SNS 간편 가입',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(height: 30),
                              ],
                            ),

                            // 구글 회원가입 버튼 (아직 동작하지 않음)
                            const GoogleJoinButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
