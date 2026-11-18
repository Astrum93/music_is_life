import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/screens/content_detail_screen.dart';

/// 마이페이지의 내 게시물 목록 (2열 그리드)
class MyContentsGrid extends StatefulWidget {
  const MyContentsGrid({super.key});

  @override
  State<MyContentsGrid> createState() => _MyContentsGridState();
}

class _MyContentsGridState extends State<MyContentsGrid> {
  ContentsController get _controller => Get.find<ContentsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 내가 쓴 게시물 (최신순)
      final collectionDocs = _controller.myContents.toList();

      // GridView.builder
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: collectionDocs.length,
          itemBuilder: (context, index) {
            final content = collectionDocs[index];
            final contentsImage = content.imageUrl;

            return GridTile(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContentDetailScreen(content: content),
                    ),
                  );
                },
                // 보여줄 이미지 사이즈
                child: Hero(
                  tag: contentsImage,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.05), width: 1),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(contentsImage),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
