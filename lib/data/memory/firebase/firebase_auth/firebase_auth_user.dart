import 'package:firebase_auth/firebase_auth.dart';

/// 아직 클린 아키텍처로 옮기지 않은 화면에서 쓰는 현재 사용자 정보.
///
/// 예전에는 필드라서 위젯이 만들어지는 순간 `currentUser!`를 읽었고,
/// 로그아웃 상태에서 해당 화면이 만들어지면 바로 크래시가 났다.
/// 지금은 getter라서 실제로 값을 읽을 때만 평가한다.
///
/// TODO(ca-cleanup): 모든 화면을 옮기면 SessionController로 대체하고 삭제한다.
abstract mixin class FirebaseAuthUser {
  // Firebase 인증된 현재 유저
  User? get user => FirebaseAuth.instance.currentUser;

  // Firebase 인증된 uid
  String get currentUid => FirebaseAuth.instance.currentUser!.uid;

  // Firebase 인증된 displayName
  String? get displayName => FirebaseAuth.instance.currentUser?.displayName;
}
