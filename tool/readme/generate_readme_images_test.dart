// README 이미지 생성기
//
// 실행: flutter test tool/readme --update-goldens
// 결과: docs/readme/*.png (README.md가 이 이미지들을 쓴다)
//
// 앱의 실제 글꼴(Pretendard, Bricolage Grotesque)과 컴포넌트로 배너·개념 카드·디자인 견본·
// 칭호 배지를 그리고, 화면 12장은 실제 앱 화면을 예시 데이터(readme_fixtures.dart)로 렌더링한다.
// test/ 밖에 두어서 일반 `flutter test`에는 포함되지 않는다.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/theme/app_theme.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';
import 'package:music_is_life/core/widgets/components/components.dart';
import 'package:music_is_life/features/auth/presentation/login/login_controller.dart';
import 'package:music_is_life/features/auth/presentation/login/login_screen.dart';
import 'package:music_is_life/features/contents/presentation/screens/content_detail_screen.dart';
import 'package:music_is_life/features/contents/presentation/screens/create_content_screen.dart';
import 'package:music_is_life/features/messenger/domain/entities/chat.dart';
import 'package:music_is_life/features/messenger/presentation/screen/chat_bubble_screen.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/playlist_screen.dart';
import 'package:music_is_life/features/profile/presentation/widgets/mini_profile_sheet.dart';
import 'package:music_is_life/features/auth/presentation/welcome/welcome_screen.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/lounge/lounge_fragment.dart';
import 'package:music_is_life/features/contents/presentation/story_stats.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/home/presentation/home_controller.dart';
import 'package:music_is_life/features/home/presentation/screen/home_screen.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_controller.dart';
import 'package:music_is_life/features/messenger/presentation/messenger_fragment.dart';
import 'package:music_is_life/features/profile/presentation/my_page_screen.dart';
import 'package:music_is_life/features/profile/presentation/profile_controller.dart';
import 'package:music_is_life/features/search/presentation/screen/search_fragment.dart';
import 'package:music_is_life/features/search/presentation/search_controller.dart';

import 'readme_fixtures.dart';

const _out = '../../docs/readme';
const _dpr = 2.0;

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final asset in assets) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
}

/// [child]를 [size] 크기로 그려 docs/readme/[name]에 저장한다.
Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required Size size,
  required Widget child,
  Future<void> Function()? before,
}) async {
  tester.view.physicalSize = size * _dpr;
  tester.view.devicePixelRatio = _dpr;
  addTearDown(tester.view.reset);

  // 앨범 커버 주소(readme.local)를 tool/readme/covers 파일로 돌려준다.
  // 테스트가 끝나기 전에 원래대로 돌려놓아야 한다. (Flutter 테스트가 검사한다)
  debugNetworkImageHttpClientProvider = CoverHttpClient.new;

  final key = GlobalKey();
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    // Material이 없으면 글자 밑에 노란 디버그 밑줄이 그려진다.
    home: RepaintBoundary(
      key: key,
      child: Material(type: MaterialType.transparency, child: child),
    ),
  ));
  await before?.call();
  // 이미지(앨범 커버) 디코딩은 실제 비동기 작업이라 runAsync로 기다린다.
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await expectLater(find.byKey(key), matchesGoldenFile('$_out/$name'));
  debugNetworkImageHttpClientProvider = null;
}

void main() {
  final now = DateTime.now();
  final stories = buildStories(now);

  setUpAll(() async {
    await _loadFont('Pretendard', [
      'assets/fonts/Pretendard-Regular.otf',
      'assets/fonts/Pretendard-Medium.otf',
      'assets/fonts/Pretendard-Bold.otf',
      'assets/fonts/Pretendard-ExtraBold.otf',
    ]);
    await _loadFont(
        'BricolageGrotesque', ['assets/fonts/BricolageGrotesque-Variable.ttf']);
    await _loadFont('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
  });

  tearDown(Get.reset);

  void putControllers() {
    final contents = FakeContentsRepository(stories);
    final profileRepository = FakeProfileRepository();
    Get.put(ContentsController(contents, profileRepository,
        uid: me, userName: '정민'));
    Get.put(
        FriendsController(FakeFriendsRepository(), profileRepository, uid: me));
    Get.put(HomeController(profileRepository, uid: me));
    Get.put(ProfileController(profileRepository, me));
    Get.put(MessengerController(FakeMessengerRepository(), profileRepository,
        uid: me, userName: '정민'));
    Get.put(AppSearchController(profileRepository, contents));
    final spotify = FakeSpotifyRepository();
    final unused = UnusedMusicRepository();
    Get.put(MusicController(
      account: spotify,
      search: spotify,
      playlist: FakePlaylistRepository(),
      playback: unused,
      youtube: unused,
      profile: profileRepository,
      uid: me,
    ));
    Get.put(LoginController(UnusedAuthRepository()));
  }

  group('README 배너·카드', () {
    testWidgets('banner-light.png', (tester) async {
      await _capture(tester,
          name: 'banner-light.png',
          size: const Size(830, 330),
          child: const _Banner(dark: false));
    });
    testWidgets('banner-dark.png', (tester) async {
      await _capture(tester,
          name: 'banner-dark.png',
          size: const Size(830, 330),
          child: const _Banner(dark: true));
    });
    testWidgets('concept.png', (tester) async {
      await _capture(tester,
          name: 'concept.png',
          size: const Size(830, 290),
          child: const _Concept());
    });
    testWidgets('design.png', (tester) async {
      await _capture(tester,
          name: 'design.png',
          size: const Size(830, 170),
          child: const _Design());
    });
    for (final tier in Tier.values) {
      testWidgets('tier-${tier.name}.png', (tester) async {
        await _capture(
          tester,
          name: 'tier-${tier.name}.png',
          size: const Size(96, 24),
          child: Theme(
            data: AppTheme.light,
            child:
                Align(alignment: Alignment.centerLeft, child: TierBadge(tier)),
          ),
        );
      });
    }
  });

  group('README 화면', () {
    // 공감을 가장 많이 받은 night_neon의 이야기 (이야기 상세 화면용)
    final featured = stories.firstWhere((c) => c.authorUid == 'night_neon');
    const room = ChatRoom(
      id: 'r1',
      name: '새벽 감성 모임',
      memberUids: [me, 'night_neon', 'haneul.forest', 'morae_al'],
      memberNames: {
        me: '정민',
        'night_neon': 'night_neon',
        'haneul.forest': 'haneul.forest',
        'morae_al': 'morae_al',
      },
    );
    final screens = <String, Widget>{
      'welcome': const WelcomeScreen(),
      'login': const LogInScreen(),
      'home': const HomeScreen(),
      'write': const CreateContentScreen(),
      'detail': ContentDetailScreen(content: featured),
      'lounge': const LoungeFragment(),
      'search': const SearchFragment(),
      'miniprofile': const _MiniProfilePreview(),
      'messenger': const MessengerFragment(),
      'chat': const ChatBubbleScreen(room: room),
      'mypage': const MyScreen(),
      'collection': const MusicCollectionScreen(),
    };
    screens.forEach((name, screen) {
      testWidgets('screen-$name.png', (tester) async {
        putControllers();
        await _capture(
          tester,
          name: 'screen-$name.png',
          size: const Size(410, 864),
          child: _PhoneFrame(child: screen),
          before: switch (name) {
            'search' => () async {
                await tester.pump();
                await tester.enterText(find.byType(TextField), 'a');
                await tester.pump();
              },
            'write' => () async {
                await tester.pump();
                Get.find<MusicController>().pickForContent(const Track(
                    id: 'w1',
                    name: '도시의 불빛',
                    artistsName: '네온 라디오',
                    imageUrl: Covers.dawn));
                final fields = find.byType(TextField);
                await tester.enterText(
                    fields.at(0), '새벽, 무작정 강변을 달렸다');
                await tester.enterText(fields.at(1),
                    '창문을 조금 내리고 이 노래를 틀었을 때 그제야 숨이 쉬어졌다.\n요즘 잠 못 드는 사람들한테 꼭 들려주고 싶은 곡.');
                await tester.enterText(fields.at(2), '#새벽 #위로');
                FocusManager.instance.primaryFocus?.unfocus();
                await tester.pump();
              },
            'login' => () async {
                await tester.pump();
                await tester.enterText(
                    find.byType(TextFormField).at(0), 'jungmin@example.com');
                FocusManager.instance.primaryFocus?.unfocus();
                await tester.pump();
              },
            _ => null,
          },
        );
      });
    });
  });
}

/// 미니 프로필: 검색 화면 위로 올라온 바텀시트처럼 그린다.
class _MiniProfilePreview extends StatelessWidget {
  const _MiniProfilePreview();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const SearchFragment(),
        const ColoredBox(color: Color(0x73111111)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Theme(
            data: AppTheme.light,
            child: MiniProfileSheet(profile: profiles['night_neon']!),
          ),
        ),
      ],
    );
  }
}

/// 휴대폰 테두리: 화면을 390x844로 그리고 상단 안전 영역(44)을 비워 둔다.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(54)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(44),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: const Size(390, 844),
            padding: const EdgeInsets.only(top: 44, bottom: 20),
            viewPadding: const EdgeInsets.only(top: 44, bottom: 20),
          ),
          child: SizedBox(width: 390, height: 844, child: child),
        ),
      ),
    );
  }
}

List<Color> _spectrum(int n, String seed) =>
    List.generate(n, (i) => spectrumColorForKey('$seed-$i'));

/// 배너: 로고 · 질문 · 한 줄 소개 · 인생 스펙트럼. 다크 모드용은 밝은 카드로 뒤집는다.
class _Banner extends StatelessWidget {
  const _Banner({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    const c = AppColorTokens.light;
    final bg = dark ? c.background : c.inverseSurface;
    final fg = dark ? c.textPrimary : c.onInverseSurface;
    final muted = dark ? c.textSecondary : c.onInverseSurfaceMuted;
    final text = AppTypography.textTheme(primary: fg, secondary: muted);
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 34, 36, 26),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'music is life'),
              TextSpan(text: '.', style: TextStyle(color: c.accent)),
            ]),
            style: AppTypography.display(size: 56, color: fg),
          ),
          const SizedBox(height: 14),
          Text('당신의 인생곡은 무엇인가요?',
              style: text.headlineMedium?.copyWith(fontSize: 26)),
          const SizedBox(height: 6),
          Text('인생곡과 짧은 이야기로 쌓아 가는 음악 일기장 SNS',
              style: text.bodyMedium?.copyWith(color: muted)),
          const Spacer(),
          LifeSpectrum(
              colors: _spectrum(420, 'banner'), height: 72, radius: 12),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in ['DAY 1', '한 줄 = 한 곡', '오늘'])
                Text(label,
                    style: text.labelSmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w400,
                        fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 개념 카드 3장: 인생곡 + 짧은 이야기 / 누르면 뒤집혀요 / 쌓이는 음악 일기장
class _Concept extends StatelessWidget {
  const _Concept();

  @override
  Widget build(BuildContext context) {
    const c = AppColorTokens.light;
    final text = AppTypography.textTheme(
        primary: c.textPrimary, secondary: c.textSecondary);
    final dawn = Covers.image(Covers.dawn);

    Widget card(Widget visual, String title, String desc) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: c.background, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 130, child: visual),
                const SizedBox(height: 14),
                Text(title,
                    style: text.titleMedium
                        ?.copyWith(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(desc, style: text.bodySmall?.copyWith(height: 1.5)),
              ],
            ),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card(
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(fit: StackFit.expand, children: [
              Transform.scale(
                scale: 1.3,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Image(image: dawn, fit: BoxFit.cover),
                ),
              ),
              const ColoredBox(color: Color(0x5C000000)),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text('잠이 오지 않던 새벽,\n무작정 강변을 달렸다',
                    style: text.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.35)),
              ),
            ]),
          ),
          '인생곡 + 짧은 이야기',
          '사진은 올리지 않아요. 곡의 앨범이 이야기의 유일한 이미지예요.',
        ),
        const SizedBox(width: 12),
        card(
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SIDE A',
                          style: AppTypography.display(
                              size: 12,
                              weight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('이야기',
                          style:
                              text.bodySmall?.copyWith(color: Colors.white70)),
                    ]),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(fit: StackFit.expand, children: [
                  Image(image: dawn, fit: BoxFit.cover),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Text('SIDE B',
                        style: AppTypography.display(
                            size: 12,
                            weight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ]),
              ),
            ),
          ]),
          '누르면 뒤집혀요',
          '앞면(SIDE A)은 이야기, 뒷면(SIDE B)은 그 이야기에 어울리는 노래.',
        ),
        const SizedBox(width: 12),
        card(
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: c.inverseSurface,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Theme(
                    data: AppTheme.light,
                    child: const TierBadge(Tier.archivist)),
                const Spacer(),
                LifeSpectrum(
                    colors: _spectrum(120, 'concept'), height: 52, radius: 6),
              ],
            ),
          ),
          '쌓이는 음악 일기장',
          '가입일부터 한 곡씩. 인생 스펙트럼·칭호·디스코그래피로 기록이 보여요.',
        ),
      ],
    );
  }
}

/// 디자인 견본: 색 · 글꼴
class _Design extends StatelessWidget {
  const _Design();

  @override
  Widget build(BuildContext context) {
    const c = AppColorTokens.light;
    final text = AppTypography.textTheme(
        primary: c.textPrimary, secondary: c.textSecondary);
    const swatches = [
      ('바탕', Color(0xFFF4F4F5)),
      ('카드', Color(0xFFFFFFFF)),
      ('글자', Color(0xFF111111)),
      ('강조', Color(0xFF6C47FF)),
      ('칭호', Color(0xFFF5C451)),
      ('기록 중', Color(0xFFFF3366)),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.surfaceMuted),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COLOR',
                    style: text.labelSmall?.copyWith(letterSpacing: 0.6)),
                const SizedBox(height: 10),
                Row(children: [
                  for (final (label, color) in swatches)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: c.surfaceMuted),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(label,
                                  style: text.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: c.textSecondary)),
                            ]),
                      ),
                    ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TYPE',
                    style: text.labelSmall?.copyWith(letterSpacing: 0.6)),
                const SizedBox(height: 8),
                Text('D+412 · Vol.2',
                    style:
                        AppTypography.display(size: 28, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text('Pretendard — 이야기는 가볍고 또렷하게', style: text.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
