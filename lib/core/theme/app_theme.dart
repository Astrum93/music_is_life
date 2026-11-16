import 'package:flutter/material.dart';

/// 앱 전역 테마
abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      );
}
