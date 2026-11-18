import 'package:flutter/material.dart';
import 'package:music_is_life/features/music/presentation/widgets/youtube_search_widget.dart';

class YoutubeSearchScreen extends StatefulWidget {
  const YoutubeSearchScreen({super.key});

  @override
  State<YoutubeSearchScreen> createState() => _YoutubeSearchScreenState();
}

class _YoutubeSearchScreenState extends State<YoutubeSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: const Column(
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '음악 검색',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                SearchYoutubeMusic(),
                SizedBox(height: 15),
                Text(
                  '* 해당 검색은 네이버 검색을 통해 이루어 집니다.\n* 올바른 가수명과 노래 제목을 입력해 주세요.\n* 올바르게 검색이 되면 바로 유튜브 영상이 재생됩니다.',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
