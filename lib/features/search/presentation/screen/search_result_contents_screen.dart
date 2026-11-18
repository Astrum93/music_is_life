import 'package:flutter/material.dart';

import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:get/get.dart';
import 'package:music_is_life/features/search/presentation/search_controller.dart';
import 'package:music_is_life/features/contents/presentation/screens/content_detail_screen.dart';

/// 게시물 검색 결과 (제목). 누르면 상세로 이동한다.
class SearchResultContents extends StatelessWidget {
  const SearchResultContents({super.key});

  @override
  Widget build(BuildContext context) {
    final results = Get.find<AppSearchController>().contentResults;
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) => GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ContentDetailScreen(content: results[index]),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Height(10),
                          Row(
                            children: [
                              Container(
                                color: Colors.transparent,
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  child: Image.network(
                                    results[index].imageUrl,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                              const Width(15),
                              Text(
                                results[index].title,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Height(10),
                        ],
                      ),
                    )),
          ),
        ));
  }
}
