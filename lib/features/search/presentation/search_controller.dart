import 'package:get/get.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';
import 'package:music_is_life/features/contents/domain/repositories/contents_repository.dart';
import 'package:music_is_life/features/profile/domain/entities/user_profile.dart';
import 'package:music_is_life/features/profile/domain/repositories/profile_repository.dart';

/// 상단 검색 (사용자 이름 / 게시물 제목)
///
/// 예전에는 글자를 하나 칠 때마다 모든 사용자·게시물 문서를 Firestore에서 다시 읽었다.
/// 지금은 화면을 열 때 한 번 불러오고, 입력할 때는 불러온 목록에서 거른다.
class AppSearchController extends GetxController {
  AppSearchController(this._profiles, this._contents);

  final ProfileRepository _profiles;
  final ContentsRepository _contents;

  final userResults = <UserProfile>[].obs;
  final contentResults = <Content>[].obs;

  List<UserProfile> _allUsers = const [];
  List<Content> _allContents = const [];
  String _keyword = '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final users = await _profiles.fetchAllProfiles();
    if (users case Success(:final value)) _allUsers = value;
    _allContents = await _contents.watchAll().first;
    search(_keyword);
  }

  void search(String keyword) {
    _keyword = keyword;
    final k = keyword.trim().toLowerCase();
    if (k.isEmpty) {
      userResults.clear();
      contentResults.clear();
      return;
    }
    userResults.assignAll(
        _allUsers.where((u) => u.userName.toLowerCase().contains(k)));
    contentResults.assignAll(
        _allContents.where((c) => c.title.toLowerCase().contains(k)));
  }
}
