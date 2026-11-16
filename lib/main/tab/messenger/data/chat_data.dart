import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:music_is_life/data/memory/firebase/firestore/fire_store_data_util.dart';

abstract mixin class ChatDataProvider {
  late final chatData = Get.find<ChatData>();
}

class ChatData extends GetxController {
  RxString chatImage = "".obs;
  RxString chatName = "".obs;
  RxString manager = "".obs;
  /// 채팅방 멤버 uid 목록 (Firestore 쿼리용)
  RxList member = [].obs;
  /// 멤버 uid -> 화면에 보여줄 이름
  RxMap<String, String> memberNames = <String, String>{}.obs;
  RxList likedMember = [].obs;

  void toggleMember(String uid, String name) {
    if (member.contains(uid)) {
      member.remove(uid);
      memberNames.remove(uid);
    } else {
      member.add(uid);
      memberNames[uid] = name;
    }
  }
  RxList friendsUserInfoDocs = [].obs;

  @override
  void onInit() {
    FireStoreDataUtil.currentUserFriendsDoc();
    super.onInit();
  }

  void getFriendsUserInfo() async {
    List friendsId = [];
    final DocumentSnapshot currentUserFriendsDoc =
        await FireStoreDataUtil.currentUserFriendsDoc();
    friendsId = currentUserFriendsDoc.get('friends');
    for (dynamic id in friendsId) {
      friendsUserInfoDocs.add(await FirebaseFirestore.instance
          .collection('UserInfo')
          .doc(id)
          .get());
    }
  }
}
