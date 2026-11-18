import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_is_life/core/constant/app_colors.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/core/widgets/button/check_button.dart';
import 'package:music_is_life/core/widgets/scaffold/custom_snackbar.dart';
import 'package:music_is_life/core/widgets/width_height_widget.dart';
import 'package:music_is_life/features/friends/presentation/friends_controller.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 친구 추가 확인 다이얼로그
class RequestFriendDialog extends StatefulWidget {
  const RequestFriendDialog({super.key, required this.profile});

  /// 친구로 추가할 사용자
  final UserProfile profile;

  @override
  State<RequestFriendDialog> createState() => _RequestFriendDialogState();
}

class _RequestFriendDialogState extends State<RequestFriendDialog> {
  FriendsController get _controller => Get.find<FriendsController>();

  /// 친구 추가
  Future<void> addFriends() async {
    final result = await _controller.addFriend(widget.profile.uid);
    if (!mounted) return;
    final (message, color) = switch (result) {
      Success() => ('친구 추가가 성공적으로 처리 되었습니다 🎉', Colors.greenAccent),
      Failed(failure: InvalidRequestFailure(code: 'self')) => (
          '자기 자신은 친구 등록 할 수 없습니다❗',
          Colors.purpleAccent
        ),
      Failed(failure: InvalidRequestFailure(code: 'already-friend')) => (
          '이미 등록된 사용자 입니다 😂',
          Colors.redAccent
        ),
      Failed(:final failure) => (failure.message, Colors.blueAccent),
    };
    Navigator.pop(context);
    CustomSnackBar.buildTopRoundedSnackBar(
        context, message, color, Colors.black, 3);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 300,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.veryDarkGrey,
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
            ),

            /// 프로필 사진
            Positioned(
                top: 20,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.veryDarkGrey,
                      border: Border.all(color: Colors.amberAccent),
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
                          widget.profile.profileImageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                height20,
                Text(
                  widget.profile.userName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                height10,
                const Text(
                  '친구로 등록 하시겠습니까?',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),

            /// 친구 추가 버튼
            Positioned(
              right: 0,
              bottom: 55,
              child: CheckButton(
                width: 40,
                height: 40,
                boxColor: AppColors.veryDarkGrey,
                borderColor: Colors.greenAccent,
                icon: Icons.check,
                iconColor: Colors.greenAccent,
                onTap: addFriends,
              ),
            ),

            /// 취소 버튼
            Positioned(
              left: 0,
              bottom: 55,
              child: CheckButton(
                width: 40,
                height: 40,
                boxColor: AppColors.veryDarkGrey,
                borderColor: Colors.redAccent,
                icon: Icons.clear,
                iconColor: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
