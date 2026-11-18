import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/router/app_routes.dart';

class MessengerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MessengerAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            Get.toNamed(Routes.createChat);
          },
          icon: const Icon(
            Icons.add,
            color: Colors.grey,
            size: 30,
          ),
        ),
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size(double.infinity, 56.0);
}
