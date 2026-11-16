// Firestore 전체와 Auth 사용자 목록을 JSON 파일로 백업한다. (읽기 전용)
//
// 사용법:
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json npm run backup
//
// 결과는 tool/firestore/backups/에 저장된다. 개인정보가 들어 있으므로 git에 올리지 않는다.
import { mkdirSync, writeFileSync, chmodSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { db, auth, dumpCollection } from './lib/admin.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const outDir = join(here, 'backups');
mkdirSync(outDir, { recursive: true, mode: 0o700 });

const stamp = new Date().toISOString().replace(/[:.]/g, '-');

const firestore = {};
for (const col of await db.listCollections()) {
  process.stdout.write(`- ${col.id} ... `);
  firestore[col.id] = await dumpCollection(col);
  console.log(`${Object.keys(firestore[col.id]).length} docs`);
}

const users = [];
let pageToken;
do {
  const page = await auth.listUsers(1000, pageToken);
  for (const u of page.users) {
    users.push({
      uid: u.uid,
      email: u.email ?? null,
      displayName: u.displayName ?? null,
      phoneNumber: u.phoneNumber ?? null,
      providers: u.providerData.map((p) => p.providerId),
      createdAt: u.metadata.creationTime,
      lastSignInAt: u.metadata.lastSignInTime,
      disabled: u.disabled,
    });
  }
  pageToken = page.pageToken;
} while (pageToken);
console.log(`- Auth users: ${users.length}`);

const file = join(outDir, `backup-${stamp}.json`);
writeFileSync(file, JSON.stringify({ createdAt: new Date().toISOString(), firestore, authUsers: users }, null, 2));
chmodSync(file, 0o600);
console.log(`\n백업 완료: ${file}`);
