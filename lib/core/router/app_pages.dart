import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/core/router/auth_middleware.dart';
import 'package:music_is_life/features/auth/presentation/join/join_binding.dart';
import 'package:music_is_life/features/auth/presentation/join/join_screen.dart';
import 'package:music_is_life/features/auth/presentation/login/login_binding.dart';
import 'package:music_is_life/features/auth/presentation/login/login_screen.dart';
import 'package:music_is_life/features/auth/presentation/welcome/welcome_screen.dart';
import 'package:music_is_life/features/profile/presentation/my_page_screen.dart';
import 'package:music_is_life/features/profile/presentation/profile_binding.dart';
import 'package:music_is_life/main/tab/home/home_fragment.dart';

/// 앱의 화면 목록.
///
/// 아직 옮기지 않은 화면은 기존 위젯을 그대로 연결해 두고,
/// 기능을 클린 아키텍처로 옮길 때 각 GetPage에 Binding을 추가한다.
abstract final class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.welcome, page: () => const WelcomeScreen()),
    GetPage(
      name: Routes.login,
      page: () => const LogInScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.join,
      page: () => const JoinScreen(),
      binding: JoinBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeFragment(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.myPage,
      page: () => const MyScreen(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
