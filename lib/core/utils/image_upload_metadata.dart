import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';

/// Storage에 이미지를 올릴 때 붙이는 메타데이터.
///
/// Storage 보안 규칙이 `image/*` 형식만 허용하므로 contentType을 반드시 지정한다.
/// 파일 확장자로 알 수 없으면 image/jpeg로 본다. (image_picker 기본 형식)
SettableMetadata imageUploadMetadata(File file) {
  final type = lookupMimeType(file.path);
  return SettableMetadata(
    contentType: type != null && type.startsWith('image/') ? type : 'image/jpeg',
  );
}
