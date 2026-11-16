import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_is_life/features/contents/domain/entities/content.dart';

/// UserContents 문서 필드 이름 (기존 데이터와 호환되도록 예전 이름을 유지)
abstract final class ContentFields {
  static const authorUid = 'authorUid';
  static const authorName = 'name';
  static const title = 'title';
  static const body = 'contents';
  static const imageUrl = 'contentsImage';
  static const createdAt = 'time';
  static const hashTags = 'hashTags';
  static const likedBy = 'likedMember';
  static const trackName = 'trackName';
  static const trackArtistsName = 'artistsName';
  static const trackImage = 'trackImage';
}

/// Firestore 문서를 [Content]로 바꾼다. 없는 필드는 기본값으로 채운다.
Content contentFromFirestore(String id, Map<String, dynamic> data) {
  String str(String key) => data[key] is String ? data[key] as String : '';
  List<String> strList(String key) => data[key] is List
      ? (data[key] as List).whereType<String>().toList()
      : const <String>[];

  final createdAt = data[ContentFields.createdAt];
  final trackName = str(ContentFields.trackName);

  return Content(
    id: id,
    authorUid: str(ContentFields.authorUid),
    authorName: str(ContentFields.authorName),
    title: str(ContentFields.title),
    body: str(ContentFields.body),
    imageUrl: str(ContentFields.imageUrl),
    createdAt: createdAt is Timestamp
        ? createdAt.toDate()
        : DateTime.fromMillisecondsSinceEpoch(0),
    hashTags: strList(ContentFields.hashTags),
    likedBy: strList(ContentFields.likedBy),
    track: trackName.isEmpty
        ? null
        : ContentTrack(
            name: trackName,
            artistsName: str(ContentFields.trackArtistsName),
            imageUrl: str(ContentFields.trackImage),
          ),
  );
}

Map<String, dynamic> contentToFirestore(Content content) => {
      ContentFields.authorUid: content.authorUid,
      ContentFields.authorName: content.authorName,
      ContentFields.title: content.title,
      ContentFields.body: content.body,
      ContentFields.imageUrl: content.imageUrl,
      ContentFields.createdAt: Timestamp.fromDate(content.createdAt),
      ContentFields.hashTags: content.hashTags,
      ContentFields.likedBy: content.likedBy,
      if (content.track != null) ...{
        ContentFields.trackName: content.track!.name,
        ContentFields.trackArtistsName: content.track!.artistsName,
        ContentFields.trackImage: content.track!.imageUrl,
      },
    };
