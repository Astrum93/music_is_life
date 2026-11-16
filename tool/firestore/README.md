# Firestore 관리 스크립트

운영 Firestore 데이터를 백업하고, 클린 아키텍처 전환에 필요한 데이터 이전 전후 상태를 확인하는 로컬 전용 스크립트다.

## 준비

1. Firebase Console → 프로젝트 설정 → 서비스 계정 → **새 비공개 키 생성**
2. 키 파일은 **저장소 밖**에 두고 권한을 `chmod 600`으로 제한한다. (관리자 권한 키)
3. 의존성 설치

   ```bash
   cd tool/firestore
   npm install
   export GOOGLE_APPLICATION_CREDENTIALS=/path/outside/repo/key.json
   ```

## 명령

| 명령 | 내용 | 데이터 변경 |
|---|---|---|
| `npm run backup` | Firestore 전체(하위 컬렉션 포함)와 Auth 사용자 목록을 `backups/`에 JSON으로 저장 | 없음 |
| `npm run inspect` | 컬렉션별 문서 수, Auth↔UserInfo 연결, 이름 중복, 이름으로 저장된 참조 필드 확인 | 없음 |
| `node migrate-to-uid.mjs [--apply]` | 사용자 식별자를 이름에서 uid로 이전 (기본 dry-run, 여러 번 실행해도 안전) | `--apply` 시 |
| `node restore.mjs <백업파일> [--apply]` | 백업 파일로 Firestore 컬렉션을 되돌림 (기본 dry-run) | `--apply` 시 |

- `backups/`에는 개인정보가 들어 있으므로 git에 올리지 않는다 (`.gitignore` 처리됨).
- 데이터를 바꾸는 이전 스크립트는 기본이 dry-run이어야 하고, 실행 전에 반드시 `npm run backup`을 먼저 돌린다.
