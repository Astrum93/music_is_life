// 공개 프로필(UserInfo)의 메일·전화번호를 비공개 문서(UserPrivate/{uid})로 옮긴다.
//
// 사용법:
//   GOOGLE_APPLICATION_CREDENTIALS=... node move-private-fields.mjs           # dry-run (기본)
//   GOOGLE_APPLICATION_CREDENTIALS=... node move-private-fields.mjs --apply   # 실제 적용
//
// 반드시 먼저 `npm run backup`을 실행한다. 여러 번 실행해도 안전하다.
//
// UserInfo/{uid}.userMail        -> UserPrivate/{uid}.email
// UserInfo/{uid}.userPhoneNumber -> UserPrivate/{uid}.phoneNumber
// 옮긴 뒤 UserInfo에서 두 필드를 삭제한다.
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './lib/admin.mjs';

const APPLY = process.argv.includes('--apply');

const plans = [];
for (const doc of (await db.collection('UserInfo').get()).docs) {
  const d = doc.data();
  if (!('userMail' in d) && !('userPhoneNumber' in d)) continue;

  const privateRef = db.collection('UserPrivate').doc(doc.id);
  const existing = (await privateRef.get()).data() ?? {};
  const next = {
    ...existing,
    ...(d.userMail !== undefined && existing.email === undefined ? { email: d.userMail } : {}),
    ...(d.userPhoneNumber !== undefined && existing.phoneNumber === undefined
      ? { phoneNumber: d.userPhoneNumber }
      : {}),
  };
  plans.push({ uid: doc.id, name: d.userName, ref: doc.ref, privateRef, next });
}

console.log(`옮길 사용자 ${plans.length}명`);
for (const p of plans) {
  console.log(`- ${p.name} (${p.uid}): UserPrivate에 ${Object.keys(p.next).join(', ')} 저장, UserInfo에서 userMail·userPhoneNumber 삭제`);
}

if (!APPLY) {
  console.log('\n(dry-run) 아무것도 변경하지 않았습니다. 적용하려면 --apply를 붙이세요.');
  process.exit(0);
}

const batch = db.batch();
for (const p of plans) {
  batch.set(p.privateRef, p.next);
  batch.update(p.ref, {
    userMail: FieldValue.delete(),
    userPhoneNumber: FieldValue.delete(),
  });
}
await batch.commit();
console.log(`\n적용 완료: ${plans.length}명`);
