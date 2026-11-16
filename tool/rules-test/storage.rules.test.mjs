// Storage 보안 규칙 테스트. 실행: cd tool/rules-test && npm test
import { before, after, beforeEach, describe, test } from 'node:test';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { ref, uploadBytes, getBytes, deleteObject } from 'firebase/storage';

let env;
const ALICE = 'alice-uid';
const BOB = 'bob-uid';
const png = new Uint8Array([0x89, 0x50, 0x4e, 0x47]);
const image = { contentType: 'image/png' };

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-music-is-life',
    storage: { rules: readFileSync(new URL('../../firebase/storage.rules', import.meta.url), 'utf8') },
  });
});
after(() => env.cleanup());
beforeEach(async () => {
  await env.clearStorage();
  await env.withSecurityRulesDisabled((ctx) =>
    uploadBytes(ref(ctx.storage(), 'userProfileImage/NA😎_profile.png'), png, image));
});

const as = (uid) => env.authenticatedContext(uid).storage();

describe('Storage', () => {
  test('로그인하지 않으면 읽을 수 없다', async () => {
    await assertFails(getBytes(ref(env.unauthenticatedContext().storage(), 'userProfileImage/NA😎_profile.png')));
  });

  test('이전 전 이름 기반 경로 파일도 계속 읽을 수 있다', async () => {
    await assertSucceeds(getBytes(ref(as(BOB), 'userProfileImage/NA😎_profile.png')));
  });

  test('프로필 사진: 내 uid 파일 이름으로만 올릴 수 있다', async () => {
    await assertSucceeds(uploadBytes(ref(as(ALICE), `userProfileImage/${ALICE}_profile_1.png`), png, image));
    await assertFails(uploadBytes(ref(as(BOB), `userProfileImage/${ALICE}_profile_2.png`), png, image));
  });

  test('프로필 배경: 내 uid 파일 이름으로만 올릴 수 있다', async () => {
    await assertSucceeds(uploadBytes(ref(as(ALICE), `userProfileBG/${ALICE}_profileBG_1.png`), png, image));
    await assertFails(uploadBytes(ref(as(BOB), `userProfileBG/${ALICE}_profileBG_2.png`), png, image));
  });

  test('게시물 이미지: 내 uid 폴더에만 올릴 수 있다', async () => {
    await assertSucceeds(uploadBytes(ref(as(ALICE), `userContents/${ALICE}/post.png`), png, image));
    await assertFails(uploadBytes(ref(as(BOB), `userContents/${ALICE}/post.png`), png, image));
  });

  test('채팅 이미지: 로그인하면 올릴 수 있다', async () => {
    await assertSucceeds(uploadBytes(ref(as(BOB), 'userChatImage/1_chatImage.png'), png, image));
  });

  test('이미지가 아니거나 10MB 이상이면 거부한다', async () => {
    await assertFails(uploadBytes(ref(as(ALICE), 'userChatImage/x.txt'), png, { contentType: 'text/plain' }));
    const big = new Uint8Array(10 * 1024 * 1024 + 1);
    await assertFails(uploadBytes(ref(as(ALICE), 'userChatImage/big.png'), big, image));
  });

  test('기존 파일을 덮어쓸 수 없다', async () => {
    const path = `userProfileImage/${ALICE}_profile_overwrite.png`;
    await assertSucceeds(uploadBytes(ref(as(ALICE), path), png, image));
    await assertFails(uploadBytes(ref(as(ALICE), path), png, image));
  });

  test('파일을 삭제할 수 없다', async () => {
    const path = `userProfileImage/${ALICE}_profile_delete.png`;
    await assertSucceeds(uploadBytes(ref(as(ALICE), path), png, image));
    await assertFails(deleteObject(ref(as(ALICE), path)));
  });

  test('정해진 폴더 밖에는 올릴 수 없다', async () => {
    await assertFails(uploadBytes(ref(as(ALICE), 'random/file.png'), png, image));
  });
});
