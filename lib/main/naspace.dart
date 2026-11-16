import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/di/initial_binding.dart';
import 'package:music_is_life/core/router/app_pages.dart';
import 'package:music_is_life/core/theme/app_theme.dart';

class NAspace extends StatelessWidget {
  const NAspace({super.key, required this.initialRoute});

  /// 로그인 상태에 따라 main()에서 정한 첫 화면
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
