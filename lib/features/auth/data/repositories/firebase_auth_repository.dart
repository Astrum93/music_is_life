import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_is_life/core/constant/constants.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/auth/domain/entities/auth_user.dart';
import 'package:music_is_life/features/auth/domain/entities/sign_up_params.dart';
import 'package:music_is_life/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // 사용자 문서 ID는 uid다. (2026-11 migrate-to-uid로 이름 -> uid 전환)
  static const _userInfoCollection = 'UserInfo';
  static const _userFriendsCollection = 'UserFriends';

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.toEntity());

  @override
  AuthUser? get currentUser => _auth.currentUser?.toEntity();

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Failed(AuthFailure('로그인에 실패했습니다.'));
      }
      return Success(user.toEntity());
    } on FirebaseAuthException catch (e) {
      return Failed(_mapAuthException(e));
    } catch (e) {
      return Failed(UnknownFailure('로그인 중 알 수 없는 오류가 발생했습니다.', e));
    }
  }

  @override
  Future<Result<AuthUser>> signUp(SignUpParams params) async {
    final name = params.name.trim();

    final User user;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: params.email.trim(),
        password: params.password,
      );
      user = credential.user!;
    } on FirebaseAuthException catch (e) {
      return Failed(_mapAuthException(e));
    } catch (e) {
      return Failed(UnknownFailure('회원가입 중 알 수 없는 오류가 발생했습니다.', e));
    }

    // 계정은 만들어졌으므로, 이후 단계가 실패하면 계정을 지워서 되돌린다.
    try {
      // 이름은 화면 표시·친구 검색에 쓰이므로 중복을 막는다.
      // (클라이언트 트랜잭션은 쿼리를 지원하지 않아 완전한 동시성 보장은 아니다.)
      final sameName = await _firestore
          .collection(_userInfoCollection)
          .where('userName', isEqualTo: name)
          .limit(1)
          .get();
      if (sameName.docs.isNotEmpty) {
        throw const _NameAlreadyInUse();
      }

      final batch = _firestore.batch()
        ..set(_firestore.collection(_userInfoCollection).doc(user.uid), {
          'uid': user.uid,
          'userName': name,
          'userMail': params.email.trim(),
          'userPhoneNumber': params.phoneNumber.trim(),
          'userProfileImage': baseProfileImage,
          'userProfileInfo': '',
          'userProfileBgImage': baseProfileBgImage,
        })
        // 마이페이지·홈 화면이 follower/following 필드를 바로 읽으므로 빈 배열로 만들어 둔다.
        ..set(_firestore.collection(_userFriendsCollection).doc(user.uid), {
          'friends': <String>[],
          'follower': <String>[],
          'following': <String>[],
        });
      await batch.commit();

      await user.updateDisplayName(name);
      await user.reload();

      return Success(
        AuthUser(uid: user.uid, email: user.email, displayName: name),
      );
    } on _NameAlreadyInUse {
      await _deleteQuietly(user);
      return const Failed(
        AuthFailure('이미 사용 중인 이름입니다.', code: 'name-already-in-use'),
      );
    } on FirebaseException catch (e) {
      await _deleteQuietly(user);
      return Failed(
        ServerFailure('사용자 정보를 저장하지 못했습니다.', code: e.code),
      );
    } catch (e) {
      await _deleteQuietly(user);
      return Failed(UnknownFailure('회원가입 중 알 수 없는 오류가 발생했습니다.', e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return Failed(UnknownFailure('로그아웃에 실패했습니다.', e));
    }
  }

  Future<void> _deleteQuietly(User user) async {
    try {
      await user.delete();
    } catch (_) {
      // 되돌리기 실패는 원래 실패 원인을 가리지 않도록 무시한다.
    }
  }

  Failure _mapAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'network-request-failed' => const NetworkFailure(),
      'invalid-email' => AuthFailure('올바른 메일 형식이 아닙니다.', code: e.code),
      'user-disabled' => AuthFailure('사용이 중지된 계정입니다.', code: e.code),
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        AuthFailure('메일 또는 비밀번호가 올바르지 않습니다.', code: e.code),
      'email-already-in-use' => AuthFailure('이미 가입된 메일입니다.', code: e.code),
      'weak-password' =>
        AuthFailure('비밀번호가 너무 약합니다. 6자리 이상 입력해 주세요.', code: e.code),
      'too-many-requests' =>
        AuthFailure('요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.', code: e.code),
      _ => AuthFailure('인증에 실패했습니다. (${e.code})', code: e.code),
    };
  }
}

class _NameAlreadyInUse implements Exception {
  const _NameAlreadyInUse();
}

extension on User {
  AuthUser toEntity() => AuthUser(uid: uid, email: email, displayName: displayName);
}
