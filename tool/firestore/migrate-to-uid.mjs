// Firestore 사용자 식별자를 이름(displayName)에서 uid로 바꾼다.
//
// 사용법:
//   GOOGLE_APPLICATION_CREDENTIALS=... node migrate-to-uid.mjs           # dry-run (기본, 아무것도 안 바꿈)
//   GOOGLE_APPLICATION_CREDENTIALS=... node migrate-to-uid.mjs --apply   # 실제 적용
//
// 반드시 먼저 `npm run backup`을 실행한다. 되돌릴 때는 restore.mjs를 쓴다.
//
// 변경 내용
// - UserInfo/{name}      -> UserInfo/{uid}       (+ uid 필드, 하위 컬렉션 UserPlayList 포함) 후 옛 문서 삭제
// - UserFriends/{name}   -> UserFriends/{uid}    friends/follower/following 배열을 uid로, 없는 배열은 []로 채움
// - UserContents/*       authorUid 추가, likedMember를 uid로 (name은 화면 표시용으로 유지)
// - UserChats/*          member·likedMember를 uid로, memberNames {uid: name} 추가 (manager는 그대로)
// - UserChats/*/messages sender를 uid로, senderName 추가
//
// 이미 uid로 바뀐 값은 그대로 두므로 여러 번 실행해도 안전하다.
import { db, auth } from './lib/admin.mjs';

const APPLY = process.argv.includes('--apply');
const log = (...a) => console.log(...a);

// 1. 이름 -> uid 매핑 (Auth 기준)
const nameToUid = new Map();
const uids = new Set();
let pageToken;
do {
  const page = await auth.listUsers(1000, pageToken);
  for (const u of page.users) {
    uids.add(u.uid);
    if (!u.displayName) continue;
    if (nameToUid.has(u.displayName)) {
      console.error(`displayName 중복: ${u.displayName} — 이전할 수 없습니다.`);
      process.exit(1);
    }
    nameToUid.set(u.displayName, u.uid);
  }
  pageToken = page.pageToken;
} while (pageToken);

const uidToName = new Map([...nameToUid].map(([n, u]) => [u, n]));
const unknown = new Set();

/** 이름 또는 이미 uid인 값을 uid로 바꾼다. 모르는 이름은 기록하고 그대로 둔다. */
function toUid(value) {
  if (uids.has(value)) return value;
  const uid = nameToUid.get(value);
  if (uid) return uid;
  unknown.add(value);
  return value;
}
// 빈 문자열 같은 쓰레기 값은 버리고, 중복은 합친다.
const mapArray = (arr) =>
  Array.isArray(arr) ? [...new Set(arr.filter((v) => typeof v === 'string' && v.trim() !== '').map(toUid))] : [];
const sameJson = (a, b) => JSON.stringify(a) === JSON.stringify(b);

const ops = []; // { desc, run: (batch) => void }
const op = (desc, run) => ops.push({ desc, run });

// 2. UserInfo, UserFriends: 문서 ID 변경
for (const [name, uid] of nameToUid) {
  const oldInfo = db.collection('UserInfo').doc(name);
  const newInfo = db.collection('UserInfo').doc(uid);
  const oldSnap = await oldInfo.get();
  if (oldSnap.exists) {
    op(`UserInfo/${name} -> UserInfo/${uid}`, (b) => {
      b.set(newInfo, { ...oldSnap.data(), uid });
    });
    for (const sub of await oldInfo.listCollections()) {
      const subSnap = await sub.get();
      for (const d of subSnap.docs) {
        op(`  ${sub.id}/${d.id} 복사`, (b) => b.set(newInfo.collection(sub.id).doc(d.id), d.data()));
        op(`  ${sub.id}/${d.id} (옛 경로) 삭제`, (b) => b.delete(d.ref));
      }
    }
    op(`UserInfo/${name} (옛 문서) 삭제`, (b) => b.delete(oldInfo));
  } else if (!(await newInfo.get()).exists) {
    log(`! UserInfo 문서가 없습니다: ${name} (${uid})`);
  }

  const oldFriends = db.collection('UserFriends').doc(name);
  const newFriends = db.collection('UserFriends').doc(uid);
  const fSnap = (await oldFriends.get()).exists ? await oldFriends.get() : await newFriends.get();
  if (fSnap.exists) {
    const d = fSnap.data();
    const next = {
      ...d,
      friends: mapArray(d.friends),
      follower: mapArray(d.follower),
      following: mapArray(d.following),
    };
    const moved = fSnap.ref.id !== uid;
    if (moved || !sameJson(d, next)) {
      op(`UserFriends/${fSnap.ref.id} -> UserFriends/${uid}  friends${JSON.stringify(d.friends ?? null)}→${next.friends.length}, follower${JSON.stringify(d.follower ?? null)}→${next.follower.length}, following${JSON.stringify(d.following ?? null)}→${next.following.length}`,
        (b) => {
          b.set(newFriends, next);
          if (moved) b.delete(oldFriends);
        });
    }
  }
}

// 3. UserContents: authorUid 추가, likedMember -> uid
for (const doc of (await db.collection('UserContents').get()).docs) {
  const d = doc.data();
  const authorUid = d.authorUid ?? toUid(d.name);
  const likedMember = mapArray(d.likedMember);
  if (d.authorUid !== authorUid || !sameJson(d.likedMember, likedMember)) {
    op(`UserContents/${doc.id}: authorUid=${authorUid}, likedMember ${d.likedMember?.length ?? 0}명`, (b) =>
      b.update(doc.ref, { authorUid, likedMember }));
  }
}

// 4. UserChats + messages
for (const chat of (await db.collection('UserChats').get()).docs) {
  const d = chat.data();
  const member = mapArray(d.member);
  const likedMember = mapArray(d.likedMember);
  const memberNames = Object.fromEntries(member.map((u) => [u, d.memberNames?.[u] ?? uidToName.get(u) ?? u]));
  if (!sameJson(d.member, member) || !sameJson(d.likedMember, likedMember) || !sameJson(d.memberNames, memberNames)) {
    op(`UserChats/${chat.id}: member ${member.length}명 -> uid, memberNames 추가`, (b) =>
      b.update(chat.ref, { member, likedMember, memberNames }));
  }
  for (const m of (await chat.ref.collection('messages').get()).docs) {
    const md = m.data();
    const sender = toUid(md.sender);
    const senderName = md.senderName ?? uidToName.get(sender) ?? md.sender;
    if (md.sender !== sender || md.senderName !== senderName) {
      op(`  messages/${m.id}: sender -> uid`, (b) => b.update(m.ref, { sender, senderName }));
    }
  }
}

// 5. 결과
log(`\n이름 → uid 매핑 ${nameToUid.size}명`);
for (const [n, u] of nameToUid) log(`  ${n} → ${u}`);
log(`\n변경 예정 작업 ${ops.length}건`);
for (const o of ops) log(`- ${o.desc}`);
if (unknown.size > 0) {
  log(`\n! Auth에 없는 이름 ${unknown.size}개: ${[...unknown].join(', ')}`);
  log('  이 값들은 uid로 바꿀 수 없어서 그대로 남습니다.');
  if (APPLY) {
    console.error('모르는 이름이 있어 적용을 중단합니다.');
    process.exit(1);
  }
}

if (!APPLY) {
  log('\n(dry-run) 아무것도 변경하지 않았습니다. 적용하려면 --apply를 붙이세요.');
  process.exit(0);
}

// Firestore batch는 500개 제한이 있으므로 나눠서 커밋한다.
// 복사(set/update)가 모두 끝난 뒤 삭제하도록 순서를 나눈다.
const writes = [];
const deletes = [];
for (const o of ops) {
  const recorder = {
    set: (...a) => writes.push((b) => b.set(...a)),
    update: (...a) => writes.push((b) => b.update(...a)),
    delete: (...a) => deletes.push((b) => b.delete(...a)),
  };
  o.run(recorder);
}
for (const group of [writes, deletes]) {
  for (let i = 0; i < group.length; i += 400) {
    const batch = db.batch();
    group.slice(i, i + 400).forEach((fn) => fn(batch));
    await batch.commit();
  }
}
log(`\n적용 완료: 쓰기 ${writes.length}건, 삭제 ${deletes.length}건`);
