# Architecture

Music is Life는 기능별 폴더 + 3계층(클린 아키텍처) 구조를 따른다.
상태 관리, 의존성 주입, 화면 이동은 GetX로 통일한다.

## 폴더 구조

```
lib/
├── main.dart              # Firebase·.env 초기화, 로그인 상태에 따라 첫 화면 결정
├── app.dart               # MusicIsLifeApp: 테마, InitialBinding, AppPages
├── core/                  # 기능에 속하지 않는 공통 코드
│   ├── di/                # InitialBinding: Firebase 인스턴스 등 전역 의존성
│   ├── error/             # Failure (sealed class)
│   ├── result/            # Result<T> = Success | Failed
│   ├── router/            # Routes, AppPages, AuthMiddleware
│   ├── theme/
│   ├── constant/
│   ├── extension/
│   ├── fcm/
│   ├── utils/             # 이미지 업로드 메타데이터 등
│   └── widgets/           # 여러 기능에서 쓰는 공통 위젯
└── features/
    ├── auth/              # 로그인·회원가입·세션
    ├── profile/           # 마이페이지·프로필 편집
    ├── contents/          # 게시물·홈 피드·라운지
    ├── friends/           # 친구·팔로우
    ├── messenger/         # 채팅
    ├── music/             # Spotify(PKCE)·마이 뮤직·유튜브
    ├── home/              # 홈 탭 셸·드로어·미니 프로필
    ├── search/            # 상단 검색
    └── <feature>/
        ├── domain/        # Entity, Repository 인터페이스, (필요할 때만) UseCase
        ├── data/          # Repository 구현체, DTO, Firebase/HTTP 호출
        └── presentation/  # Binding, Controller, 화면, 위젯
```

## 계층 규칙

| 계층 | 할 수 있는 것 | 하면 안 되는 것 |
|---|---|---|
| domain | 순수 Dart 코드, `core/error`, `core/result` | Flutter, Firebase, GetX import |
| data | domain 구현, Firebase·HTTP 호출, 예외를 `Failure`로 변환 | presentation import, `Get.find` 호출 |
| presentation | domain 사용, GetX Controller·화면 | Firebase 직접 호출, data 계층 import (Binding 제외) |

## GetX 규칙

1. **Controller·Repository 안에서는 `Get.find`를 호출하지 않는다.** 필요한 의존성은 생성자로 받고, 조립은 Binding에서 한다. 화면은 `Get.find<XxxController>()`(또는 `GetView`)로 자기 Controller만 받는다.
   ```dart
   class ProfileBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<ProfileRepository>(
         () => FirebaseProfileRepository(Get.find<FirebaseFirestore>()),
       );
       Get.lazyPut(() => ProfileController(Get.find<ProfileRepository>()));
     }
   }
   ```
2. **Controller는 UI를 직접 띄우지 않는다.** `Get.snackbar`, `Get.dialog`는 화면에서 호출하고, Controller는 상태(Rx 변수)만 바꾼다.
3. **화면 이동은 GetX로 통일한다.** 새 화면은 `Routes`에 이름을 추가하고 `AppPages`에 `GetPage` + Binding으로 등록한다. 로그인이 필요한 화면에는 `AuthMiddleware`를 붙인다.
4. **화면 상태는 Controller로 옮긴다.** `setState`는 입력 중인 값처럼 그 위젯 안에서만 쓰는 상태에만 남긴다.

## 에러 처리

- Repository는 예외를 던지지 않고 `Result<T>`를 돌려준다.
- data 계층에서 `FirebaseException` 등을 잡아 `AuthFailure`, `ServerFailure` 같은 `Failure`로 바꾼다.
- Controller는 `switch (result)` 또는 `result.fold(...)`로 성공과 실패를 처리한다.

## 모델

- Entity(domain)는 freezed로 만든다.
- Firestore 문서와의 변환은 data 계층의 mapper 함수(`*_mapper.dart`, `*FromFirestore`)가 한다. 기존 문서의 필드 이름(`userName`, `likedMember` 등)을 그대로 유지하고, 없는 필드는 기본값으로 채운다.
- 코드 생성: `dart run build_runner build --delete-conflicting-outputs`

## 마이그레이션 단계

기존 코드(`lib/main`, `lib/data`, `lib/spotify`)를 단계별로 `lib/features`로 옮겼다. 단계마다 `dev`에서 브랜치를 따고, 앱이 동작하는 상태로 `dev`에 머지했다. (2026-11 완료)

| 단계 | 브랜치 | 내용 | 상태 |
|---|---|---|---|
| 1 | `feature/ca-core` | GetX 4.7, freezed, `core/` 뼈대, GetMaterialApp 전환 | ✅ |
| 2 | `feature/ca-auth` | 로그인·회원가입 이전, 가입 컬렉션 이름 버그와 로그아웃 크래시 수정 | ✅ |
| 3a | `feature/ca-uid-migration` | Firestore 사용자 식별자를 이름에서 uid로 전환 (데이터 이전 포함) | ✅ |
| 3b | `feature/ca-profile` | 프로필 이전, 메일·전화번호를 UserPrivate로 분리 | ✅ |
| 3c | `feature/ca-contents` | 게시물(작성·피드·좋아요·내 게시물·라운지) 이전 | ✅ |
| 4 | `feature/ca-friends`, `feature/ca-messenger` | 친구·팔로우, 메신저 이전 | ✅ |
| 5 | `feature/ca-music` | Spotify(PKCE 전환, CLIENT_SECRET 제거)·YouTube·마이 뮤직 이전 | ✅ |
| 6 | `feature/ca-cleanup` | 홈·검색 이전, `lib/main`·`lib/data` 삭제, 안 쓰는 패키지 9개 제거 | ✅ |

## Firebase 운영

- 보안 규칙: `firebase/firestore.rules`, `firebase/storage.rules`
  - 수정 후 `cd tool/rules-test && npm test` (에뮬레이터 테스트) → `firebase deploy --only firestore:rules,storage`
- 운영 데이터 백업·이전 스크립트: `tool/firestore/` (README 참고). 데이터를 바꾸는 스크립트는 기본이 dry-run이고, 실행 전에 반드시 백업한다.
