# Architecture

Music is Life는 기능별 폴더 + 3계층(클린 아키텍처) 구조를 따른다.
상태 관리, 의존성 주입, 화면 이동은 GetX로 통일한다.

## 폴더 구조

```
lib/
├── core/                  # 기능에 속하지 않는 공통 코드
│   ├── di/                # InitialBinding: Firebase 인스턴스 등 전역 의존성
│   ├── error/             # Failure (sealed class)
│   ├── result/            # Result<T> = Success | Failed
│   ├── router/            # Routes, AppPages, AuthMiddleware
│   ├── theme/
│   ├── constant/
│   ├── extension/
│   ├── fcm/
│   └── widgets/           # 여러 기능에서 쓰는 공통 위젯
└── features/
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

1. **`Get.find`는 Binding에서만 호출한다.** Controller와 Repository는 필요한 의존성을 생성자로 받는다.
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

- Entity(domain)와 DTO(data)는 freezed로 만든다. DTO는 json_serializable로 Firestore 문서와 변환한다.
- 코드 생성: `dart run build_runner build --delete-conflicting-outputs`

## 마이그레이션 단계

기존 코드(`lib/main`, `lib/data`, `lib/spotify`)는 단계별로 `lib/features`로 옮긴다. 단계마다 `dev`에서 브랜치를 따고, 앱이 동작하는 상태로 `dev`에 머지한다.

| 단계 | 브랜치 | 내용 |
|---|---|---|
| 1 | `feature/ca-core` | GetX 4.7, freezed, `core/` 뼈대, GetMaterialApp 전환 |
| 2 | `feature/ca-auth` | 로그인·회원가입 이전, 가입 컬렉션 이름 버그와 로그아웃 크래시 수정 |
| 3 | `feature/ca-profile`, `feature/ca-contents` | 프로필·게시물 이전, Firestore 문서 ID를 uid로 변경 |
| 4 | `feature/ca-friends`, `feature/ca-messenger` | 친구·메신저 이전 |
| 5 | `feature/ca-music` | Spotify(PKCE 전환)·YouTube 이전 |
| 6 | `feature/ca-cleanup` | 옛 폴더와 안 쓰는 패키지 제거, Repository 테스트 |
