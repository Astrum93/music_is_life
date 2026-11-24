import 'package:flutter/material.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/fcm/fcm_manager.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/widgets/button/check_button.dart';
import 'package:music_is_life/core/widgets/components/app_tab_bar.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/home/presentation/screen/home_screen.dart';
import 'package:music_is_life/features/contents/presentation/lounge/lounge_fragment.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_fragment.dart';

import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';
import 'package:music_is_life/features/auth/presentation/session/session_controller.dart';
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
        if (!didPop) {
          showPopDialog(context);
        }
      },
      // 로그인 확인은 /home 라우트의 AuthMiddleware가 하고, 로그아웃하면 Welcome으로 이동한다.
      // 탭 4개를 모두 리디자인 라이트 테마로 옮겼으므로 탭 틀(배경·하단 탭)도 라이트로 그린다.
      // 로그아웃 다이얼로그는 기존 다크 디자인이라 이 Theme 바깥의 context로 연다.
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

  void showPopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(color: Colors.redAccent),
                color: AppColors.veryDarkGrey,
              ),
              child: const Center(
                child: Text(
                  '현제 계정에서 \n로그아웃 하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            height20,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckButton(
                  width: 40,
                  height: 40,
                  boxColor: AppColors.veryDarkGrey,
                  borderColor: Colors.redAccent,
                  icon: Icons.close,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Width(150),
                CheckButton(
                  width: 40,
                  height: 40,
                  boxColor: AppColors.veryDarkGrey,
                  borderColor: Colors.greenAccent,
                  icon: Icons.check,
                  iconColor: Colors.greenAccent,
                  onTap: () async {
                    // TODO(ca-home): 홈을 옮길 때 Binding으로 받도록 변경
                    await Get.find<SessionController>().logout();
                    Get.offAllNamed(Routes.welcome);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
