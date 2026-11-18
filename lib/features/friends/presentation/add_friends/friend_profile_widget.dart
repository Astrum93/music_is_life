import 'package:flutter/material.dart';

/// 친구 찾기·채팅 초대 화면의 둥근 프로필 사진
class FriendProfileWidget extends StatelessWidget {
  const FriendProfileWidget({
    super.key,
    required this.imageUrl,
    required this.boxColor,
    required this.borderColor,
  });

  final String imageUrl;
  final Color? boxColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: boxColor,
          border: Border.all(color: borderColor),
          borderRadius: const BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
