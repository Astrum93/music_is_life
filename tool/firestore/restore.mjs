// backup.mjs로 만든 백업 파일로 Firestore를 되돌린다.
//
// 사용법:
//   GOOGLE_APPLICATION_CREDENTIALS=... node restore.mjs backups/backup-XXXX.json            # dry-run
//   GOOGLE_APPLICATION_CREDENTIALS=... node restore.mjs backups/backup-XXXX.json --apply    # 실제 복원
//
// 동작: 백업에 있는 컬렉션(UserInfo 등)의 현재 문서를 모두 지운 뒤 백업 내용을 그대로 다시 쓴다.
// 백업 이후 새로 생긴 문서도 지워지므로 주의한다. Auth 계정은 복원하지 않는다.
import { readFileSync } from 'node:fs';
import { db } from './lib/admin.mjs';
import { Timestamp, GeoPoint } from 'firebase-admin/firestore';

const file = process.argv[2];
const APPLY = process.argv.includes('--apply');
if (!file || file.startsWith('--')) {
  console.error('백업 파일 경로를 지정하세요.');
  process.exit(1);
}
const backup = JSON.parse(readFileSync(file, 'utf8'));

function deserialize(v) {
  if (v === null || typeof v !== 'object') return v;
  if (Array.isArray(v)) return v.map(deserialize);
  switch (v.__type) {
    case 'timestamp': return new Timestamp(v.seconds, v.nanoseconds);
    case 'geopoint': return new GeoPoint(v.latitude, v.longitude);
    case 'reference': return db.doc(v.path);
    case 'bytes': return Buffer.from(v.base64, 'base64');
  }
  return Object.fromEntries(Object.entries(v).map(([k, x]) => [k, deserialize(x)]));
}

const writes = [];
function collectWrites(colRef, docs) {
  for (const [id, { data, subcollections }] of Object.entries(docs)) {
    const ref = colRef.doc(id);
    if (data) writes.push((b) => b.set(ref, deserialize(data)));
    for (const [sub, subDocs] of Object.entries(subcollections ?? {})) {
      collectWrites(ref.collection(sub), subDocs);
    }
  }
}

const deletes = [];
async function collectDeletes(colRef) {
  for (const ref of await colRef.listDocuments()) {
    for (const sub of await ref.listCollections()) await collectDeletes(sub);
    deletes.push((b) => b.delete(ref));
  }
}

for (const [name, docs] of Object.entries(backup.firestore)) {
  await collectDeletes(db.collection(name));
  collectWrites(db.collection(name), docs);
}

console.log(`백업 시각: ${backup.createdAt}`);
console.log(`삭제 ${deletes.length}건, 쓰기 ${writes.length}건 예정`);
if (!APPLY) {
  console.log('(dry-run) 아무것도 변경하지 않았습니다. 복원하려면 --apply를 붙이세요.');
  process.exit(0);
}
for (const group of [deletes, writes]) {
  for (let i = 0; i < group.length; i += 400) {
    const batch = db.batch();
    group.slice(i, i + 400).forEach((fn) => fn(batch));
    await batch.commit();
  }
}
console.log('복원 완료');
