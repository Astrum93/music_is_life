import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/constant/constants.dart';
import 'package:music_is_life/core/widgets/button/check_button.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/screens/playlist_search_screen.dart';

class MusicCollectionScreen extends StatefulWidget {
  const MusicCollectionScreen({super.key});

  @override
  State<MusicCollectionScreen> createState() => _MusicCollectionScreenState();
}

/// 마이 뮤직 (내 플레이리스트). 밀어서 삭제, 길게 눌러 대표곡 설정.
class _MusicCollectionScreenState extends State<MusicCollectionScreen> {
  MusicController get _music => Get.find<MusicController>();

  Future<void> _remove(PlaylistEntry entry) async {
    final result = await _music.removeFromPlaylist(entry);
    if (result case Failed(:final failure) when mounted) {
      showErrorSnackBar(context, failure.message);
    }
  }

  Future<void> _setProfileTrack(Track track) async {
    final result = await _music.setProfileTrack(track);
    if (!mounted) return;
    // 확인 다이얼로그를 닫는다.
    Navigator.of(context).pop();
    if (result case Failed(:final failure)) {
      showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('뮤직 리스트'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Obx(() {
            final collectionDocs = _music.playlist.toList();

            return ListView.builder(
              itemCount: collectionDocs.length,
              itemBuilder: (context, index) {
                final entry = collectionDocs[index];
                final track = entry.track;
                final trackImage =
                    track.imageUrl.isEmpty ? baseProfileImage : track.imageUrl;
                final trackName = track.name;
                final artistsName = track.artistsName;
                return Column(
                  children: [
                    Dismissible(
                      // 예전에는 순서(index)를 키로 써서, 삭제하면 다른 곡과 키가 겹쳤다.
                      key: ValueKey(entry.docId),
                      background: Container(
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Width(20),
                            Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                            Width(20),
                          ],
                        ),
                      ),
                      onDismissed: (direction) => _remove(entry),
                      child: GestureDetector(
                        onLongPress: () {
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
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      border:
                                          Border.all(color: Colors.redAccent),
                                      color: AppColors.veryDarkGrey,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '현제 음악을 \n프로필 뮤직으로 \n설정 하시겠습니까?',
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
                                        onTap: () => _setProfileTrack(track),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: MediaQuery.of(context).size.width - 10,
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                child: Image.network(trackImage),
                              ),
                              width30,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      trackName.length > 20
                                          ? SizedBox(
                                              width: trackName.length *
                                                  11.toDouble(),
                                              height: 50,
                                              child: Marquee(
                                                text: trackName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                                scrollAxis: Axis.horizontal,
                                                velocity: 30,
                                                blankSpace: 40,
                                              ),
                                            )
                                          : Text(
                                              trackName,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      artistsName.length > 15
                                          ? SizedBox(
                                              width: artistsName.length *
                                                  11.toDouble(),
                                              height: 50,
                                              child: Marquee(
                                                text: artistsName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Colors.grey.shade600,
                                                ),
                                                scrollAxis: Axis.horizontal,
                                                velocity: 30,
                                                blankSpace: 40,
                                              ),
                                            )
                                          : Text(
                                              artistsName,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    height10,
                  ],
                );
              },
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PlaylistSearchScreen()));
          },
          backgroundColor: AppColors.veryDarkGrey,
          splashColor: Colors.amberAccent.withValues(alpha: 0.5),
          child: const Icon(
            Icons.search,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
