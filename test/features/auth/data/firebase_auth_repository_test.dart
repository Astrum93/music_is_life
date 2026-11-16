import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_is_life/core/error/failure.dart';
import 'package:music_is_life/core/result/result.dart';
import 'package:music_is_life/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:music_is_life/features/auth/domain/entities/sign_up_params.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late FirebaseAuthRepository repository;

  const params = SignUpParams(
    name: '뮤직러버',
    email: 'lover@example.com',
    password: 'secret123',
    phoneNumber: '010-1234-5678',
  );

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    repository = FirebaseAuthRepository(auth, firestore);
  });

  group('signIn', () {
    test('성공하면 AuthUser를 돌려준다', () async {
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u1', email: 'a@b.com', displayName: '홍길동'),
      );
      repository = FirebaseAuthRepository(auth, firestore);

      final result = await repository.signIn(email: 'a@b.com', password: 'pw1234');

      expect(result.valueOrNull?.uid, 'u1');
      expect(result.valueOrNull?.displayName, '홍길동');
    });

    test('잘못된 비밀번호는 AuthFailure로 바뀐다', () async {
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      final result = await repository.signIn(email: 'a@b.com', password: 'wrong1');

      expect(result, isA<Failed>());
      final failure = (result as Failed).failure;
      expect(failure, isA<AuthFailure>());
      expect(failure.message, '메일 또는 비밀번호가 올바르지 않습니다.');
    });

    test('네트워크 오류는 NetworkFailure로 바뀐다', () async {
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      final result = await repository.signIn(email: 'a@b.com', password: 'pw1234');

      expect((result as Failed).failure, isA<NetworkFailure>());
    });
  });

  group('signUp', () {
    test('UserInfo/{uid}에 저장한다 (user_info 아님, 이름이 아닌 uid가 문서 ID)', () async {
      final result = await repository.signUp(params);

      expect(result.isSuccess, isTrue);
      final uid = result.valueOrNull!.uid;
      final userInfo = await firestore.collection('UserInfo').doc(uid).get();
      expect(userInfo.exists, isTrue);
      expect(userInfo.data()!['uid'], uid);
      expect(userInfo.data()!['userName'], '뮤직러버');
      expect((await firestore.collection('UserInfo').doc('뮤직러버').get()).exists, isFalse);
      expect(userInfo.data()!['userMail'], 'lover@example.com');
      expect(userInfo.data()!['userPhoneNumber'], '010-1234-5678');

      final legacy = await firestore.collection('user_info').get();
      expect(legacy.docs, isEmpty);
    });

    test('UserFriends에 friends/follower/following 빈 배열을 만든다', () async {
      final result = await repository.signUp(params);

      final friends = await firestore
          .collection('UserFriends')
          .doc(result.valueOrNull!.uid)
          .get();
      expect(friends.data(), {
        'friends': <String>[],
        'follower': <String>[],
        'following': <String>[],
      });
    });

    test('displayName을 가입한 이름으로 설정한다', () async {
      final result = await repository.signUp(params);

      expect(result.valueOrNull?.displayName, '뮤직러버');
      expect(auth.currentUser?.displayName, '뮤직러버');
    });

    test('이미 사용 중인 이름이면 실패하고 기존 사용자 데이터를 덮어쓰지 않는다', () async {
      await firestore.collection('UserInfo').doc('existing-uid').set({
        'uid': 'existing-uid',
        'userName': '뮤직러버',
        'userMail': 'original@example.com',
      });

      final result = await repository.signUp(params);

      expect(result, isA<Failed>());
      final failure = (result as Failed).failure as AuthFailure;
      expect(failure.code, 'name-already-in-use');

      final userInfo = await firestore.collection('UserInfo').get();
      expect(userInfo.docs.map((d) => d.id), ['existing-uid']);
      expect(userInfo.docs.single.data()['userMail'], 'original@example.com');
      final friends = await firestore.collection('UserFriends').get();
      expect(friends.docs, isEmpty);
    });

    test('이미 가입된 메일이면 AuthFailure를 돌려주고 문서를 만들지 않는다', () async {
      whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await repository.signUp(params);

      expect((result as Failed).failure.message, '이미 가입된 메일입니다.');
      final userInfo = await firestore.collection('UserInfo').get();
      expect(userInfo.docs, isEmpty);
    });

    test('이름과 메일 앞뒤 공백을 제거해서 저장한다', () async {
      final result = await repository.signUp(
        params.copyWith(name: '  뮤직러버 ', email: ' lover@example.com '),
      );

      final userInfo = await firestore
          .collection('UserInfo')
          .doc(result.valueOrNull!.uid)
          .get();
      expect(userInfo.data()!['userName'], '뮤직러버');
      expect(userInfo.data()!['userMail'], 'lover@example.com');
    });
  });

  test('signOut 후 currentUser가 null이다', () async {
    auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u1'));
    repository = FirebaseAuthRepository(auth, firestore);

    final result = await repository.signOut();

    expect(result.isSuccess, isTrue);
    expect(repository.currentUser, isNull);
  });
}
