import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/music/data/repositories/firebase_playlist_repository.dart';
import 'package:music_is_life/features/music/data/repositories/naver_youtube_repository.dart';
import 'package:music_is_life/features/music/data/repositories/spotify_repository.dart';
import 'package:music_is_life/features/music/domain/entities/track.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';

/// 실제 로그인·네트워크 없이 OAuth2Helper를 흉내 낸다.
class _FakeHelper extends OAuth2Helper {
  _FakeHelper({this.hasToken = true, this.response})
      : super(
          SpotifyOAuth2Client(redirectUri: 'app://callback', customUriScheme: 'app'),
          clientId: 'client-id',
        );

  final bool hasToken;
  final http.Response? response;
  String? requestedUrl;

  @override
  Future<AccessTokenResponse?> getTokenFromStorage() async =>
      hasToken ? AccessTokenResponse.fromMap({'access_token': 't', 'token_type': 'Bearer'}) : null;

  @override
  Future<http.Response> get(String url, {Map<String, String>? headers, http.Client? httpClient}) async {
    requestedUrl = url;
    return response!;
  }
}

final _searchJson = jsonEncode({
  'tracks': {
    'items': [
      {
        'id': 'track-1',
        'name': 'Love wins all',
        'artists': [
          {'id': 'artist-1', 'name': 'IU'},
          {'id': 'artist-2', 'name': 'Feat'},
        ],
        'album': {
          'images': [
            {'url': 'https://img/large.png'},
            {'url': 'https://img/small.png'},
          ],
        },
      },
      {'id': 'track-2', 'name': '이미지 없음', 'artists': <Object>[], 'album': {'images': <Object>[]}},
    ],
  },
});

void main() {
  group('parseSearchResponse', () {
    test('곡 ID는 가수 ID가 아니라 곡 ID를 쓴다 (예전 버그)', () {
      final tracks = parseSearchResponse(_searchJson);

      expect(tracks.first.id, 'track-1');
      expect(tracks.first.artistsName, 'IU, Feat');
      expect(tracks.first.imageUrl, 'https://img/large.png');
    });

    test('가수·이미지가 없는 곡도 에러 없이 읽는다', () {
      final track = parseSearchResponse(_searchJson)[1];

      expect(track.artistsName, '');
      expect(track.imageUrl, '');
    });
  });

  group('SpotifyRepository', () {
    test('계정이 연결되지 않았으면 로그인 화면을 띄우지 않고 not-connected 실패를 돌려준다', () async {
      final helper = _FakeHelper(hasToken: false);
      final repository = SpotifyRepository(clientId: 'id', redirectUri: 'r', customUriScheme: 's', helper: helper);

      final result = await repository.search('love');

      expect(((result as Failed).failure as AuthFailure).code, 'spotify-not-connected');
      expect(helper.requestedUrl, isNull);
    });

    test('검색어를 URL 인코딩해서 요청하고 결과를 Track으로 돌려준다', () async {
      final helper = _FakeHelper(response: http.Response.bytes(utf8.encode(_searchJson), 200));
      final repository = SpotifyRepository(clientId: 'id', redirectUri: 'r', customUriScheme: 's', helper: helper);

      final result = await repository.search('  아이유 & 친구 ');

      final uri = Uri.parse(helper.requestedUrl!);
      expect(uri.queryParameters['q'], '아이유 & 친구');
      expect(uri.queryParameters['type'], 'track');
      expect(result.valueOrNull?.map((t) => t.id), ['track-1', 'track-2']);
      // charset 헤더가 없어도 한글 곡 제목이 깨지지 않는다.
      expect(result.valueOrNull?[1].name, '이미지 없음');
    });

    test('토큰이 만료돼 401이 오면 다시 연결하라는 실패를 돌려준다', () async {
      final helper = _FakeHelper(response: http.Response('{}', 401));
      final repository = SpotifyRepository(clientId: 'id', redirectUri: 'r', customUriScheme: 's', helper: helper);

      final result = await repository.search('love');

      expect(((result as Failed).failure as AuthFailure).code, 'spotify-not-connected');
    });
  });

  group('extractYoutubeVideoId', () {
    test('검색 결과 링크에서 영상 ID를 꺼낸다', () {
      const html = '<a class="info_title" href="https://www.youtube.com/watch?v=dQw4w9WgXcQ">x</a>';

      expect(extractYoutubeVideoId(html), 'dQw4w9WgXcQ');
    });

    test('youtu.be 주소와 파라미터가 섞인 주소도 처리한다', () {
      expect(extractYoutubeVideoId('<a href="https://youtu.be/abcdefghijk">'), 'abcdefghijk');
      expect(
        extractYoutubeVideoId('<a class="info_title" href="https://www.youtube.com/watch?feature=x&amp;v=ABCDEFGHIJK">'),
        'ABCDEFGHIJK',
      );
    });

    test('유튜브 링크가 없으면 null (예전에는 앱이 멈췄다)', () {
      expect(extractYoutubeVideoId('<html><body>결과 없음</body></html>'), isNull);
    });
  });

  group('FirebasePlaylistRepository', () {
    late FakeFirebaseFirestore firestore;
    late FirebasePlaylistRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = FirebasePlaylistRepository(firestore, now: () => DateTime(2026, 11, 17));
    });

    const track = Track(id: 'track-1', name: '같은 제목', artistsName: 'A', imageUrl: 'img');

    test('곡 ID를 문서 ID로 저장해서, 제목이 같은 다른 곡끼리 덮어쓰지 않는다', () async {
      await repository.add('me', track);
      await repository.add('me', track.copyWith(id: 'track-2', artistsName: 'B'));

      final entries = await repository.watch('me').first;
      expect(entries.map((e) => e.docId).toSet(), {'track-1', 'track-2'});
    });

    test('예전 문서(제목이 문서 ID)도 읽고, 문서 ID로 지운다', () async {
      await firestore.collection('UserInfo').doc('me').collection('UserPlayList').doc('Love wins all').set({
        'trackName': 'Love wins all',
        'trackImage': 'img',
        'artistsName': 'IU',
        'trackId': 'artist-id',
        'time': Timestamp.fromDate(DateTime(2024)),
      });

      final entries = await repository.watch('me').first;
      expect(entries.single.docId, 'Love wins all');
      expect(entries.single.track.name, 'Love wins all');

      await repository.remove('me', 'Love wins all');
      expect(await repository.watch('me').first, isEmpty);
    });

    test('최근에 담은 순으로 내보낸다', () async {
      repository = FirebasePlaylistRepository(firestore, now: () => DateTime(2024));
      await repository.add('me', track);
      repository = FirebasePlaylistRepository(firestore, now: () => DateTime(2025));
      await repository.add('me', track.copyWith(id: 'newer'));

      final entries = await repository.watch('me').first;
      expect(entries.map((e) => e.docId), ['newer', 'track-1']);
    });
  });
}
