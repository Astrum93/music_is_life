import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/firebase_options.dart';

import 'package:music_is_life/app.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: "assets/config/.env");

  // 저장된 로그인 정보가 복원될 때까지 기다린 뒤 첫 화면을 정한다.
  // (앱 시작 직후에는 currentUser가 잠깐 null일 수 있다.)
  final user = await FirebaseAuth.instance
      .authStateChanges()
      .first;

  runApp(
    MusicIsLifeApp(initialRoute: user != null ? Routes.home : Routes.welcome),
  );
  FlutterNativeSplash.remove();
}