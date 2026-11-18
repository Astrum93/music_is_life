import 'package:flutter/material.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/friend_profile_widget.dart';
import 'package:music_is_life/features/friends/presentation/add_friends/request_friends_dialog.dart';

class SearchFriendsResultScreen extends StatelessWidget {
  const SearchFriendsResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FriendsController>();
    return Obx(() {
      final profiles = controller.searchResults.toList();
      if (profiles.isEmpty) {
        return const Text(
          '검색 결과가 없습니다.',
          style: TextStyle(color: Colors.grey),
        );
      }
      return Expanded(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 150,
          ),
          itemCount: profiles.length,
          itemBuilder: (context, index) => GestureDetector(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) =>
                    RequestFriendDialog(profile: profiles[index]),
              );
            },
            child: Column(
              children: [
                FriendProfileWidget(
                    imageUrl: profiles[index].profileImageUrl,
                    boxColor: AppColors.veryDarkGrey,
                    borderColor: Colors.amberAccent),
                height10,
                Text(
                  profiles[index].userName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
