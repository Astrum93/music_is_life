import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:music_is_life/data/memory/firebase/firestore/fire_store_data_util.dart';

abstract mixin class SearchDataProvider {
  /// late 키워드를 사용하는 이유는 state생성이 initState보다 빠르기 때문
  late final searchData = Get.find<SearchData>();
}

class SearchData extends GetxController {
  List searchUserInfoData = [];
  List searchContentsData = [];
  RxList userInfo = [].obs;
  RxList contents = [].obs;
  RxList recommendFriends = [].obs;
  RxList searchFriends = [].obs;

  @override
  void onInit() {
    FireStoreDataUtil.getUserInfoDoc();
    FireStoreDataUtil.getContentsDoc();
    super.onInit();
  }

  void userInfoCreate() async {
    final List<DocumentSnapshot> userInfoDocs =
        await FireStoreDataUtil.getUserInfoDoc();
    recommendFriends.value = userInfoDocs.toList();
  }

  void search(String keyword) async {
    if (keyword.isEmpty) {
      userInfo.clear();
      contents.clear();
      return;
    }

    final List<DocumentSnapshot> userInfoDocs =
        await FireStoreDataUtil.getUserInfoDoc();
    final List<DocumentSnapshot> contentsDocs =
        await FireStoreDataUtil.getContentsDoc();

    userInfo.value = userInfoDocs.where((doc) {
      // 문서 ID가 uid로 바뀌었으므로 이름(userName) 필드로 검색한다.
      return _fieldContains(doc, 'userName', keyword);
    }).toList();

    contents.value = contentsDocs.where((doc) {
      // 새 게시물은 자동 ID라서 제목(title) 필드로 검색한다.
      return _fieldContains(doc, 'title', keyword);
    }).toList();
  }

  void searchFriend(String keyword) async {
    if (keyword.isEmpty) {
      searchFriends.clear();
      return;
    }

    final List<DocumentSnapshot> userInfoDocs =
        await FireStoreDataUtil.getUserInfoDoc();

    searchFriends.value = userInfoDocs.where((doc) {
      // 문서 ID가 uid로 바뀌었으므로 이름(userName) 필드로 검색한다.
      return _fieldContains(doc, 'userName', keyword);
    }).toList();
  }

  bool _fieldContains(DocumentSnapshot doc, String field, String keyword) {
    final data = doc.data() as Map<String, dynamic>?;
    final value = data?[field];
    return value is String && value.toLowerCase().contains(keyword.toLowerCase());
  }
}
