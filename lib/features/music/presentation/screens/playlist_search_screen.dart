import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:music_is_life/core/constant/constants.dart';
import 'package:music_is_life/core/widgets/scaffold/custom_snackbar.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/features/music/presentation/widgets/spotify_connect_prompt.dart';
import 'package:music_is_life/features/music/presentation/widgets/track_search_app_bar.dart';

class PlaylistSearchScreen extends StatefulWidget {
  const PlaylistSearchScreen({super.key});

  @override
  State<PlaylistSearchScreen> createState() => _PlaylistSearchScreenState();
}

/// 마이 뮤직에 담을 곡을 Spotify에서 검색한다.
class _PlaylistSearchScreenState extends State<PlaylistSearchScreen> {
  final TextEditingController controller = TextEditingController();

  MusicController get _music => Get.find<MusicController>();

  @override
  void initState() {
    super.initState();
    _music
      ..clearSearch()
      ..refreshConnection();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _add(Track track) async {
    final result = await _music.addToPlaylist(track);
    if (!mounted) return;
    switch (result) {
      case Success():
        CustomSnackBar.buildTopRoundedSnackBar(
            context, '추가가 완료되었습니다.', Colors.greenAccent, Colors.black, 3);
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TrackSearchAppBar(
              controller: controller,
            ),
            Obx(
              () => !_music.isSpotifyConnected.value
                  ? const SpotifyConnectPrompt()
                  : _music.searchResults.isEmpty
                      ? const Text(
                          '스포티파이를 사용하는 검색입니다. \n되도록 영어로 써주세요!',
                          style: TextStyle(color: Colors.redAccent),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _music.searchResults.length,
                            itemBuilder: (context, index) {
                              final track = _music.searchResults[index];
                              final trackImage = track.imageUrl.isEmpty
                                  ? baseProfileImage
                                  : track.imageUrl;
                              final trackName = track.name;
                              final artistsName = track.artistsName;
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    width:
                                        MediaQuery.of(context).size.width - 10,
                                    height: 150,
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                trackName.length > 20
                                                    ? Expanded(
                                                        child: SizedBox(
                                                          width:
                                                              trackName.length *
                                                                  11.toDouble(),
                                                          height: 50,
                                                          child: Marquee(
                                                            text: trackName,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            scrollAxis:
                                                                Axis.horizontal,
                                                            velocity: 30,
                                                            blankSpace: 40,
                                                          ),
                                                        ),
                                                      )
                                                    : Text(
                                                        trackName,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                artistsName.length > 15
                                                    ? Expanded(
                                                        child: SizedBox(
                                                          width: artistsName
                                                                  .length *
                                                              11.toDouble(),
                                                          height: 50,
                                                          child: Marquee(
                                                            text: artistsName,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            ),
                                                            scrollAxis:
                                                                Axis.horizontal,
                                                            velocity: 30,
                                                            blankSpace: 40,
                                                          ),
                                                        ),
                                                      )
                                                    : Text(
                                                        artistsName,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                      ),
                                                height20,
                                                GestureDetector(
                                                  onTap: () => _add(track),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.greenAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  height20,
                                ],
                              );
                            },
                          ),
                        ),
            )
          ],
        ),
      ),
    );
  }
}
