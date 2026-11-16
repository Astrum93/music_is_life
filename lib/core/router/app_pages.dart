import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/router/auth_middleware.dart';
import 'package:music_is_life/main/join/join_screen.dart';
import 'package:music_is_life/main/login/login_screen.dart';
import 'package:music_is_life/main/tab/home/home_fragment.dart';
import 'package:music_is_life/main/welcome_screen.dart';

/// 앱의 화면 목록.
///
/// 아직 옮기지 않은 화면은 기존 위젯을 그대로 연결해 두고,
/// 기능을 클린 아키텍처로 옮길 때 각 GetPage에 Binding을 추가한다.
abstract final class AppPages {
  static const initial = Routes.welcome;

  static final pages = <GetPage>[
    GetPage(name: Routes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: Routes.login, page: () => const LogInScreen()),
    GetPage(name: Routes.join, page: () => const JoinScreen()),
    GetPage(
      name: Routes.home,
      page: () => const HomeFragment(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
