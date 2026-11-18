// firebase-admin 초기화 공통 모듈.
//
// 서비스 계정 키 경로는 환경 변수 GOOGLE_APPLICATION_CREDENTIALS로 넘긴다.
// 키 파일은 관리자 권한이므로 절대 저장소 안에 두지 않는다.
import { cert, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp, GeoPoint, DocumentReference } from 'firebase-admin/firestore';
import { readFileSync } from 'node:fs';

const EXPECTED_PROJECT_ID = 'musicislife-naspace';

const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
if (!keyPath) {
  console.error('GOOGLE_APPLICATION_CREDENTIALS에 서비스 계정 키 경로를 지정하세요.');
  process.exit(1);
}

const key = JSON.parse(readFileSync(keyPath, 'utf8'));
if (key.project_id !== EXPECTED_PROJECT_ID) {
  console.error(`키의 프로젝트(${key.project_id})가 ${EXPECTED_PROJECT_ID}가 아닙니다.`);
  process.exit(1);
}

initializeApp({ credential: cert(key), projectId: key.project_id });

export const db = getFirestore();
export const auth = getAuth();

/**
 * Firestore 값을 JSON으로 저장할 수 있게 바꾼다.
 * Timestamp 등 특수 타입은 { __type } 태그를 붙여서 나중에 복원할 수 있게 한다.
 */
export function serialize(value) {
  if (value === null || value === undefined) return value ?? null;
  if (value instanceof Timestamp) {
    return { __type: 'timestamp', seconds: value.seconds, nanoseconds: value.nanoseconds };
  }
  if (value instanceof GeoPoint) {
    return { __type: 'geopoint', latitude: value.latitude, longitude: value.longitude };
  }
  if (value instanceof DocumentReference) {
    return { __type: 'reference', path: value.path };
  }
  if (Buffer.isBuffer(value) || value instanceof Uint8Array) {
    return { __type: 'bytes', base64: Buffer.from(value).toString('base64') };
  }
  if (Array.isArray(value)) return value.map(serialize);
  if (typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, serialize(v)]));
  }
  return value;
}

/**
 * 컬렉션과 모든 하위 컬렉션을 재귀적으로 읽는다.
 * 결과: { [docId]: { data, subcollections: { [name]: {...} } } }
 */
export async function dumpCollection(collectionRef) {
  const snapshot = await collectionRef.get();
  const result = {};
  for (const doc of snapshot.docs) {
    const subcollections = {};
    for (const sub of await doc.ref.listCollections()) {
      subcollections[sub.id] = await dumpCollection(sub);
    }
    result[doc.id] = { data: serialize(doc.data()), subcollections };
  }
  // 문서는 없고 하위 컬렉션만 있는 "빈 부모 문서"도 놓치지 않는다.
  for (const ref of await collectionRef.listDocuments()) {
    if (result[ref.id]) continue;
    const subcollections = {};
    for (const sub of await ref.listCollections()) {
      subcollections[sub.id] = await dumpCollection(sub);
    }
    if (Object.keys(subcollections).length > 0) {
      result[ref.id] = { data: null, subcollections };
    }
  }
  return result;
}
