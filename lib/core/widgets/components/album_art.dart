import 'package:flutter/material.dart';
import 'package:music_is_life/core/theme/tokens/tokens.dart';

/// 주소가 비어 있으면 이미지로 만들지 않는다. ([AlbumArt]는 null이면 회색 면을 보여준다)
ImageProvider? networkImageOrNull(String? url) =>
    (url == null || url.isEmpty) ? null : NetworkImage(url);

/// 앨범 아트: 앱에서 보여주는 모든 이미지(게시물, 프로필, 채팅방)는 이 위젯을 쓴다.
///
/// 개인 사진은 올리지 않고 곡의 앨범 아트만 쓴다.
/// 이미지가 없거나 불러오지 못하면 회색 면을 보여준다.
class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    required this.image,
    this.size = 48,
    this.radius = AppRadius.s,
    this.semanticLabel,
  });

  final ImageProvider? image;
  final double size;
  final double radius;

  /// 화면 읽기 프로그램용 설명. 없으면 장식 이미지로 취급한다.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(color: context.colors.surfaceMuted);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: image == null
            ? placeholder
            : Image(
                image: image!,
                fit: BoxFit.cover,
                semanticLabel: semanticLabel,
                excludeFromSemantics: semanticLabel == null,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}
