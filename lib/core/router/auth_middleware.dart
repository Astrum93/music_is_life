import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';

/// 로그인이 필요한 화면에 붙이는 미들웨어.
///
/// 로그인하지 않은 상태로 들어오면 [Routes.welcome]으로 보낸다.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isLoggedIn = Get.find<FirebaseAuth>().currentUser != null;
    return isLoggedIn ? null : const RouteSettings(name: Routes.welcome);
  }
}
