import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/scaffold/app_snackbar.dart';
import 'package:music_is_life/features/music/presentation/music_controller.dart';
import 'package:music_is_life/core/widgets/box/expanded_box.dart';
import 'package:music_is_life/core/widgets/easy_text_form_field.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SearchYoutubeMusic extends StatefulWidget {
  const SearchYoutubeMusic({super.key});

  @override
  State<SearchYoutubeMusic> createState() => _SearchYoutubeMusicState();
}

class _SearchYoutubeMusicState extends State<SearchYoutubeMusic> {
  String singer = '';
  String titleOfSong = '';

  /// 검색에 성공하면 만들어지는 플레이어 컨트롤러
  YoutubePlayerController? youtubeController;

  MusicController get _music => Get.find<MusicController>();

  /// Form Key
  final formKey = GlobalKey<FormState>();

  /// 입력한 노래 제목·가수로 유튜브 영상을 찾아 재생한다.
  ///
  /// 예전에는 검색 결과가 없거나 주소 형식이 다르면 영상 ID를 자르다가 앱이 멈췄다.
  Future<void> _search() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    final result =
        await _music.findYoutubeVideo(title: titleOfSong, singer: singer);
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        youtubeController?.close();
        setState(() {
          youtubeController = YoutubePlayerController.fromVideoId(
            videoId: value,
            autoPlay: true,
          );
        });
      case Failed(:final failure):
        showErrorSnackBar(context, failure.message);
    }
  }

  @override
  void dispose() {
    youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      width: 380,
      height: 430,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 7,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              youtubeController != null
                  ? YoutubePlayer(
                      controller: youtubeController!,
                    )
                  : Image.asset(
                      'assets/icon/3d_casual_life_cloud_music.png',
                      scale: 2,
                    ),
              const ExpandedBox(),
              EasyTextFormField(
                  key: const ValueKey(2),
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '노래 제목을 올바르게 입력해 주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    titleOfSong = value!;
                  },
                  onChanged: (value) {
                    titleOfSong = value;
                  },
                  prefixIcon: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.amber,
                  ),
                  hintText: "검색 하실 노래 제목을 입력 해 주세요."),
              const SizedBox(height: 15),
              EasyTextFormField(
                  key: const ValueKey(1),
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '가수 이름을 올바르게 입력해 주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    singer = value!;
                  },
                  onChanged: (value) {
                    singer = value;
                  },
                  prefixIcon: const Icon(
                    Icons.person_search_outlined,
                    color: Colors.amber,
                  ),
                  hintText: "검색 하실 가수 이름을 입력 해 주세요."),
              const ExpandedBox(),
              FloatingActionButton(
                backgroundColor: Colors.greenAccent,
                onPressed: _search,
                child: const Icon(Icons.search, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
