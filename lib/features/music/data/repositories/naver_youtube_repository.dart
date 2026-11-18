import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/domain/repositories/music_repositories.dart';

/// 네이버 동영상 검색 결과에서 첫 번째 유튜브 영상을 찾는다.
///
/// 검색 결과 HTML을 읽는 방식이라 네이버 화면 구조가 바뀌면 동작하지 않을 수 있다.
class NaverYoutubeRepository implements YoutubeRepository {
  NaverYoutubeRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<Result<String>> findVideoId({required String title, required String singer}) async {
    final query = 'youtube $title $singer'.trim();
    try {
      final uri = Uri.https('search.naver.com', '/search.naver', {
        'where': 'video',
        'query': query,
      });
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        return Failed(ServerFailure('영상을 검색하지 못했습니다.', code: '${response.statusCode}'));
      }
      final id = extractYoutubeVideoId(response.body);
      return id == null
          ? const Failed(NotFoundFailure('유튜브 영상을 찾지 못했습니다. 가수명과 노래 제목을 확인해 주세요.'))
          : Success(id);
    } catch (e) {
      return Failed(UnknownFailure('영상을 검색하지 못했습니다.', e));
    }
  }
}

final _videoIdPattern = RegExp(
  r'(?:youtube\.com/watch\?(?:[^"&]*&)*v=|youtu\.be/|youtube\.com/shorts/)([A-Za-z0-9_-]{11})',
);

/// 검색 결과 HTML에서 첫 번째 유튜브 영상 ID를 꺼낸다.
///
/// 예전에는 링크 문자열을 32글자 뒤에서 잘라 ID를 만들어서, 결과가 없거나 주소 형식이
/// 다르면 앱이 멈췄다.
String? extractYoutubeVideoId(String html) {
  final bs = BeautifulSoup(html);
  final candidates = [
    ...bs.findAll('a', class_: 'info_title').map((e) => e.attributes['href'] ?? ''),
    html,
  ];
  for (final text in candidates) {
    final match = _videoIdPattern.firstMatch(text);
    if (match != null) return match.group(1);
  }
  return null;
}
