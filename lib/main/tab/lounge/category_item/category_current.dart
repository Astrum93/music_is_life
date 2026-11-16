import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/contents/presentation/contents_controller.dart';
import 'package:music_is_life/features/contents/presentation/widgets/contents_thumbnail_grid.dart';

/// 라운지 - 내 게시물
class CategoryCurrent extends StatelessWidget {
  const CategoryCurrent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContentsController>();
    return Expanded(
      child: Obx(
        () => ContentsThumbnailGrid(contents: controller.myContents.toList()),
      ),
    );
  }
}
