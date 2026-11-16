// Firestore 보안 규칙 테스트. 앱이 실제로 하는 읽기/쓰기를 그대로 흉내 낸다.
// 실행: cd tool/rules-test && npm test   (에뮬레이터에서만 실행, 운영 데이터와 무관)
import { before, after, beforeEach, describe, test } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc, collection, query, where,
  arrayUnion, arrayRemove, writeBatch,
} from 'firebase/firestore';

let env;
const ALICE = 'alice-uid';
const BOB = 'bob-uid';
const EVE = 'eve-uid';

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-music-is-life',
    firestore: { rules: readFileSync(new URL('../../firebase/firestore.rules', import.meta.url), 'utf8') },
  });
});
after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'UserInfo', ALICE), { uid: ALICE, userName: 'alice', userProfileInfo: '' });
    await setDoc(doc(db, 'UserInfo', BOB), { uid: BOB, userName: 'bob', userProfileInfo: '' });
    await setDoc(doc(db, 'UserFriends', ALICE), { friends: [], follower: [], following: [] });
    await setDoc(doc(db, 'UserFriends', BOB), { friends: [], follower: [], following: [] });
    await setDoc(doc(db, 'UserContents', 'post1'), { authorUid: ALICE, name: 'alice', title: '글', likedMember: [] });
    await setDoc(doc(db, 'UserChats', 'chat1'), { member: [ALICE, BOB], memberNames: {}, likedMember: [], chatName: '방' });
    await setDoc(doc(db, 'UserChats', 'chat1', 'messages', 'm1'), { sender: ALICE, senderName: 'alice', text: 'hi' });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

describe('공통', () => {
  test('로그인하지 않으면 아무것도 읽을 수 없다', async () => {
    await assertFails(getDoc(doc(anon(), 'UserInfo', ALICE)));
    await assertFails(getDocs(collection(anon(), 'UserContents')));
  });
});

describe('UserInfo', () => {
  test('로그인하면 모든 프로필을 읽을 수 있다 (검색·홈)', async () => {
    await assertSucceeds(getDocs(collection(as(BOB), 'UserInfo')));
  });

  test('회원가입: 내 uid 문서를 만들 수 있다 (UserInfo + UserFriends 배치)', async () => {
    const db = as(EVE);
    const batch = writeBatch(db);
    batch.set(doc(db, 'UserInfo', EVE), { uid: EVE, userName: 'eve' });
    batch.set(doc(db, 'UserFriends', EVE), { friends: [], follower: [], following: [] });
    await assertSucceeds(batch.commit());
  });

  test('회원가입: 다른 uid로는 만들 수 없다', async () => {
    await assertFails(setDoc(doc(as(EVE), 'UserInfo', 'someone-else'), { uid: 'someone-else', userName: 'x' }));
  });

  test('회원가입 전 이름 중복 확인 쿼리를 할 수 있다', async () => {
    await assertSucceeds(getDocs(query(collection(as(EVE), 'UserInfo'), where('userName', '==', 'alice'))));
  });

  test('내 프로필 소개를 수정할 수 있다', async () => {
    await assertSucceeds(updateDoc(doc(as(ALICE), 'UserInfo', ALICE), { userProfileInfo: '안녕' }));
  });

  test('다른 사람 프로필은 수정할 수 없다', async () => {
    await assertFails(updateDoc(doc(as(BOB), 'UserInfo', ALICE), { userProfileInfo: '해킹' }));
  });

  test('내 문서의 uid 필드를 바꿀 수 없다', async () => {
    await assertFails(updateDoc(doc(as(ALICE), 'UserInfo', ALICE), { uid: BOB }));
  });

  test('프로필은 삭제할 수 없다', async () => {
    await assertFails(deleteDoc(doc(as(ALICE), 'UserInfo', ALICE)));
  });

  test('내 플레이리스트에 곡을 추가·삭제할 수 있고, 남의 것은 안 된다', async () => {
    await assertSucceeds(setDoc(doc(as(ALICE), 'UserInfo', ALICE, 'UserPlayList', 'song'), { trackName: 'song' }));
    await assertSucceeds(deleteDoc(doc(as(ALICE), 'UserInfo', ALICE, 'UserPlayList', 'song')));
    await assertFails(setDoc(doc(as(BOB), 'UserInfo', ALICE, 'UserPlayList', 'song'), { trackName: 'song' }));
  });
});

describe('UserFriends', () => {
  test('팔로우: 상대 follower에 내 uid 추가 + 내 following에 상대 추가', async () => {
    const db = as(BOB);
    await assertSucceeds(updateDoc(doc(db, 'UserFriends', ALICE), { follower: arrayUnion(BOB) }));
    await assertSucceeds(updateDoc(doc(db, 'UserFriends', BOB), { following: arrayUnion(ALICE) }));
  });

  test('언팔로우: 상대 follower에서 내 uid 제거', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      updateDoc(doc(ctx.firestore(), 'UserFriends', ALICE), { follower: [BOB] }));
    await assertSucceeds(updateDoc(doc(as(BOB), 'UserFriends', ALICE), { follower: arrayRemove(BOB) }));
  });

  test('남의 follower에 다른 사람 uid를 넣을 수 없다', async () => {
    await assertFails(updateDoc(doc(as(BOB), 'UserFriends', ALICE), { follower: arrayUnion(EVE) }));
  });

  test('남의 follower를 통째로 지울 수 없다', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      updateDoc(doc(ctx.firestore(), 'UserFriends', ALICE), { follower: [BOB, EVE] }));
    await assertFails(updateDoc(doc(as(BOB), 'UserFriends', ALICE), { follower: [] }));
  });

  test('남의 friends/following은 바꿀 수 없다', async () => {
    await assertFails(updateDoc(doc(as(BOB), 'UserFriends', ALICE), { friends: arrayUnion(BOB) }));
    await assertFails(updateDoc(doc(as(BOB), 'UserFriends', ALICE), { following: arrayUnion(BOB) }));
  });

  test('친구 추가: 내 friends에 상대 uid 추가', async () => {
    await assertSucceeds(updateDoc(doc(as(ALICE), 'UserFriends', ALICE), { friends: arrayUnion(BOB) }));
  });
});

describe('UserContents', () => {
  test('내 이름(authorUid)으로 게시물을 쓸 수 있다', async () => {
    await assertSucceeds(setDoc(doc(as(BOB), 'UserContents', 'new'), { authorUid: BOB, name: 'bob', likedMember: [] }));
  });

  test('다른 사람 이름으로 게시물을 쓸 수 없다', async () => {
    await assertFails(setDoc(doc(as(BOB), 'UserContents', 'new'), { authorUid: ALICE, name: 'alice', likedMember: [] }));
  });

  test('좋아요: 남의 게시물에 내 uid를 추가·제거할 수 있다', async () => {
    const ref = doc(as(BOB), 'UserContents', 'post1');
    await assertSucceeds(updateDoc(ref, { likedMember: arrayUnion(BOB) }));
    await assertSucceeds(updateDoc(ref, { likedMember: arrayRemove(BOB) }));
  });

  test('작성자도 자기 글에 좋아요를 누를 수 있다', async () => {
    await assertSucceeds(updateDoc(doc(as(ALICE), 'UserContents', 'post1'), { likedMember: arrayUnion(ALICE) }));
  });

  test('남의 게시물 내용·작성자는 바꿀 수 없고, 남의 uid로 좋아요도 안 된다', async () => {
    const ref = doc(as(BOB), 'UserContents', 'post1');
    await assertFails(updateDoc(ref, { title: '해킹' }));
    await assertFails(updateDoc(ref, { authorUid: BOB }));
    await assertFails(updateDoc(ref, { likedMember: arrayUnion(EVE) }));
  });

  test('작성자는 작성자를 바꿀 수 없다', async () => {
    await assertFails(updateDoc(doc(as(ALICE), 'UserContents', 'post1'), { authorUid: BOB }));
  });

  test('게시물 삭제는 작성자만 가능하다', async () => {
    await assertFails(deleteDoc(doc(as(BOB), 'UserContents', 'post1')));
    await assertSucceeds(deleteDoc(doc(as(ALICE), 'UserContents', 'post1')));
  });
});

describe('UserChats', () => {
  test('메신저 목록: member에 내 uid가 있는 방만 쿼리할 수 있다', async () => {
    await assertSucceeds(getDocs(query(collection(as(BOB), 'UserChats'), where('member', 'array-contains', BOB))));
  });

  test('멤버가 아니면 채팅방을 읽을 수 없다', async () => {
    await assertFails(getDoc(doc(as(EVE), 'UserChats', 'chat1')));
    await assertFails(getDocs(collection(as(EVE), 'UserChats')));
  });

  test('채팅방 생성: 내가 멤버에 포함돼야 한다', async () => {
    await assertSucceeds(setDoc(doc(as(EVE), 'UserChats', 'new'), { member: [EVE, ALICE], likedMember: [] }));
    await assertFails(setDoc(doc(as(EVE), 'UserChats', 'new2'), { member: [ALICE, BOB], likedMember: [] }));
  });

  test('멤버는 채팅방 좋아요를 누를 수 있고, 멤버가 아니면 못 한다', async () => {
    await assertSucceeds(updateDoc(doc(as(BOB), 'UserChats', 'chat1'), { likedMember: arrayUnion(BOB) }));
    await assertFails(updateDoc(doc(as(EVE), 'UserChats', 'chat1'), { likedMember: arrayUnion(EVE) }));
  });

  test('멤버는 자기 자신을 멤버에서 빼서 방을 못 쓰게 만들 수 없다 (수정 후에도 멤버여야 함)', async () => {
    await assertFails(updateDoc(doc(as(BOB), 'UserChats', 'chat1'), { member: [ALICE] }));
  });

  test('메시지: 멤버만 읽고, 내 uid로만 보낼 수 있다', async () => {
    await assertSucceeds(getDocs(collection(as(BOB), 'UserChats', 'chat1', 'messages')));
    await assertSucceeds(setDoc(doc(as(BOB), 'UserChats', 'chat1', 'messages', 'm2'), { sender: BOB, senderName: 'bob', text: 'yo' }));
    await assertFails(setDoc(doc(as(BOB), 'UserChats', 'chat1', 'messages', 'm3'), { sender: ALICE, text: '사칭' }));
    await assertFails(getDocs(collection(as(EVE), 'UserChats', 'chat1', 'messages')));
    await assertFails(setDoc(doc(as(EVE), 'UserChats', 'chat1', 'messages', 'm4'), { sender: EVE, text: '침입' }));
  });

  test('메시지는 수정·삭제할 수 없다', async () => {
    await assertFails(updateDoc(doc(as(ALICE), 'UserChats', 'chat1', 'messages', 'm1'), { text: '수정' }));
    await assertFails(deleteDoc(doc(as(ALICE), 'UserChats', 'chat1', 'messages', 'm1')));
  });
});
