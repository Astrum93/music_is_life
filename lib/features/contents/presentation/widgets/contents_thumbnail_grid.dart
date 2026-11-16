import 'package:flutter/material.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/presentation/screens/content_detail_screen.dart';

/// 게시물 이미지를 4열 썸네일로 보여준다. 누르면 상세 화면으로 이동한다.
class ContentsThumbnailGrid extends StatelessWidget {
  const ContentsThumbnailGrid({super.key, required this.contents});

  final List<Content> contents;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final content = contents[index];
        return GridTile(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ContentDetailScreen(content: content),
              ),
            ),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.05), width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(content.imageUrl),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
