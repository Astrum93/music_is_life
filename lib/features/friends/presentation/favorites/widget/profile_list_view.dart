import 'package:flutter/material.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';

/// 팔로워·팔로잉 목록 (프로필 사진 + 이름)
///
/// 예전에는 팔로워·팔로잉 화면이 거의 같은 코드로 따로 있었고,
/// 항목마다 UserInfo 문서를 하나씩 따로 읽었다.
class ProfileListView extends StatelessWidget {
  const ProfileListView({super.key, required this.profiles});

  final List<UserProfile> profiles;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.amberAccent),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        profile.profileImageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                profile.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
