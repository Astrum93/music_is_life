// 데이터 이전 전에 현황을 확인한다. (읽기 전용)
//
// 사용법:
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json npm run inspect
//
// 확인 항목
// 1. 컬렉션별 문서 수 (하위 컬렉션 포함)
// 2. user_info(가입 버그로 잘못 저장된 곳)에만 있는 사용자
// 3. Auth 계정과 UserInfo 문서의 연결 상태 (문서 ID = displayName)
// 4. displayName이 겹치는 Auth 계정 (이름을 문서 ID로 쓰면 데이터가 섞임)
// 5. 다른 문서 안에 이름으로 저장된 참조 (uid 전환 시 함께 바꿔야 하는 곳)
import { db, auth } from './lib/admin.mjs';

const line = (title) => console.log(`\n=== ${title} ===`);

// 1. 컬렉션별 문서 수
line('1. 컬렉션별 문서 수');
const topCollections = await db.listCollections();
for (const col of topCollections) {
  const refs = await col.listDocuments();
  const subCounts = {};
  for (const ref of refs) {
    for (const sub of await ref.listCollections()) {
      const n = (await sub.count().get()).data().count;
      subCounts[sub.id] = (subCounts[sub.id] ?? 0) + n;
    }
  }
  const subText = Object.entries(subCounts).map(([k, v]) => `${k}: ${v}`).join(', ');
  console.log(`${col.id}: ${refs.length} docs${subText ? `  (하위: ${subText})` : ''}`);
}

// Auth 사용자
const authUsers = [];
let pageToken;
do {
  const page = await auth.listUsers(1000, pageToken);
  authUsers.push(...page.users);
  pageToken = page.pageToken;
} while (pageToken);

const userInfoIds = new Set((await db.collection('UserInfo').listDocuments()).map((r) => r.id));
const legacyIds = new Set((await db.collection('user_info').listDocuments()).map((r) => r.id));

// 2. user_info에만 있는 사용자
line('2. user_info(잘못된 컬렉션)에 저장된 사용자');
if (legacyIds.size === 0) {
  console.log('없음');
} else {
  for (const id of legacyIds) {
    console.log(`- ${id}  ${userInfoIds.has(id) ? '(UserInfo에도 있음)' : '→ UserInfo에 없음, 이전 필요'}`);
  }
}

// 3. Auth ↔ UserInfo 연결
line('3. Auth 계정과 UserInfo 문서 연결 (문서 ID = displayName)');
console.log(`Auth 계정: ${authUsers.length}, UserInfo 문서: ${userInfoIds.size}`);
const noDisplayName = authUsers.filter((u) => !u.displayName);
const noUserInfo = authUsers.filter((u) => u.displayName && !userInfoIds.has(u.displayName));
const authNames = new Set(authUsers.map((u) => u.displayName).filter(Boolean));
const orphanDocs = [...userInfoIds].filter((id) => !authNames.has(id));
console.log(`displayName 없는 Auth 계정: ${noDisplayName.length}`);
for (const u of noDisplayName) console.log(`  - uid ${u.uid} (${u.providerData.map((p) => p.providerId).join(',') || 'no provider'})`);
console.log(`UserInfo 문서가 없는 Auth 계정: ${noUserInfo.length}`);
for (const u of noUserInfo) {
  console.log(`  - ${u.displayName}${legacyIds.has(u.displayName) ? '  (user_info에 있음)' : ''}`);
}
console.log(`Auth 계정과 이름이 맞지 않는 UserInfo 문서: ${orphanDocs.length}`);
for (const id of orphanDocs) console.log(`  - ${id}`);

// 4. displayName 중복
line('4. displayName이 겹치는 Auth 계정');
const byName = new Map();
for (const u of authUsers) {
  if (!u.displayName) continue;
  byName.set(u.displayName, [...(byName.get(u.displayName) ?? []), u.uid]);
}
const dupes = [...byName].filter(([, uids]) => uids.length > 1);
if (dupes.length === 0) console.log('없음');
for (const [name, uids] of dupes) console.log(`- ${name}: ${uids.length}개 계정 (${uids.join(', ')})`);

// 5. 이름으로 저장된 참조 필드 탐색
line('5. 다른 사용자 이름을 값으로 가진 필드 (uid 전환 시 함께 변경 대상)');
const names = new Set([...authNames, ...userInfoIds]);
const hits = new Map(); // "Collection.field" -> count
function scan(path, value, colPath) {
  if (typeof value === 'string' && names.has(value)) {
    hits.set(`${colPath}.${path}`, (hits.get(`${colPath}.${path}`) ?? 0) + 1);
  } else if (Array.isArray(value)) {
    value.forEach((v) => scan(`${path}[]`, v, colPath));
  } else if (value && typeof value === 'object' && !(value.constructor?.name === 'Timestamp')) {
    for (const [k, v] of Object.entries(value)) scan(path ? `${path}.${k}` : k, v, colPath);
  }
}
async function scanCollection(col, colPath) {
  const snap = await col.get();
  for (const doc of snap.docs) {
    scan('', doc.data(), colPath);
    for (const sub of await doc.ref.listCollections()) {
      await scanCollection(sub, `${colPath}/*/${sub.id}`);
    }
  }
  for (const ref of await col.listDocuments()) {
    if (snap.docs.some((d) => d.id === ref.id)) continue;
    for (const sub of await ref.listCollections()) {
      await scanCollection(sub, `${colPath}/*/${sub.id}`);
    }
  }
}
for (const col of topCollections) await scanCollection(col, col.id);
if (hits.size === 0) console.log('없음');
for (const [field, n] of [...hits].sort()) console.log(`- ${field}: ${n}건`);

console.log('\n(읽기 전용으로 실행했습니다. 데이터는 변경되지 않았습니다.)');
