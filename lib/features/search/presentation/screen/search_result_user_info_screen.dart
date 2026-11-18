import 'package:flutter/material.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';

import 'package:get/get.dart';
import 'package:music_is_life/features/search/presentation/search_controller.dart';

/// 사용자 검색 결과 (이름)
class SearchResultUserInfo extends StatelessWidget {
  const SearchResultUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final results = Get.find<AppSearchController>().userResults;
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: results.length,
              itemBuilder: (context, index) => Column(
                children: [
                  const Height(10),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            results[index].profileImageUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      const Width(15),
                      Text(
                        results[index].userName,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Height(10),
                ],
              ),
            ),
          ),
        ));
  }
}
