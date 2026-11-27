import 'package:flutter/material.dart';
import 'package:music_is_life/core/fcm/fcm_manager.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/features/auth/presentation/widgets/logout_dialog.dart';
import 'package:music_is_life/core/widgets/components/app_tab_bar.dart';
import 'package:music_is_life/features/home/presentation/screen/home_screen.dart';
import 'package:music_is_life/features/contents/presentation/lounge/lounge_fragment.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_fragment.dart';

import 'package:music_is_life/features/search/presentation/screen/search_fragment.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  int _currentIndex = 0;

  /// Tab Items
  final List<Widget> _tabItems = <Widget>[
    const HomeScreen(),
    const SearchFragment(),
    const LoungeFragment(),
    const MessengerFragment()
  ];

  @override
  void initState() {
    super.initState();
    // 푸시 알림 설정은 여기서 한 번만 한다. (예전에는 홈 화면에서도 중복 호출했다)
    FcmManager.requestPermission();
    FcmManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) confirmLogout(context);
      },
      // 로그인 확인은 /home 라우트의 AuthMiddleware가 하고, 로그아웃하면 Welcome으로 이동한다.
      // 탭 4개를 모두 리디자인 라이트 테마로 옮겼으므로 탭 틀(배경·하단 탭)도 라이트로 그린다.
      child: Theme(
        data: AppTheme.light,
        child: Scaffold(
          body: SafeArea(
            child: _tabItems.elementAt(_currentIndex),
          ),
          bottomNavigationBar: AppTabBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }
}
