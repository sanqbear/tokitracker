# PROJECT.md

## 프로젝트 개요

**tokitracker**는 레거시 Android 앱 [MangaViewAndroid](https://github.com/sanqbear/MangaViewAndroid)를 Flutter로 재작성하는 크로스 플랫폼 만화 뷰어/다운로더 애플리케이션입니다.

### 목적
- 마나토끼 전용 뷰어/다운로더의 멀티플랫폼 지원
- Clean Architecture 기반의 유지보수 가능한 코드베이스 구축
- 레거시 앱의 핵심 기능을 Flutter로 이식

---

## 아키텍처 설계

### Clean Architecture + BLoC Pattern

```
lib/
├── core/                          # 공통 기능 및 유틸리티
│   ├── constants/                 # 상수 (URLs, 설정값)
│   ├── error/                     # 에러 처리
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                   # 네트워크 클라이언트
│   │   ├── http_client.dart      # CustomHttpClient 대응
│   │   └── interceptors.dart     # 쿠키, 캡차 처리
│   ├── storage/                   # 로컬 저장소
│   │   ├── local_storage.dart    # SharedPreferences 래퍼
│   │   └── file_manager.dart     # 파일 시스템 관리
│   └── utils/                     # 유틸리티 함수
│       ├── decoder.dart           # 이미지 디코딩
│       └── validators.dart
│
├── features/                      # 기능별 모듈 (Feature-first)
│   ├── authentication/            # 로그인/로그아웃
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       └── logout.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   └── login_page.dart
│   │       └── widgets/
│   │
│   ├── home/                      # 메인 화면 (MainMain, MainSearch)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── home_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── main_page_model.dart
│   │   │   │   └── ranking_model.dart
│   │   │   └── repositories/
│   │   │       └── home_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── main_page.dart
│   │   │   │   └── ranking.dart
│   │   │   ├── repositories/
│   │   │   │   └── home_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_main_page.dart
│   │   │       ├── get_updated_manga.dart
│   │   │       └── get_ranking.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   ├── home_page.dart
│   │       │   └── tabs/
│   │       │       ├── main_tab.dart
│   │       │       └── search_tab.dart
│   │       └── widgets/
│   │
│   ├── manga/                     # 만화 상세 정보 (Title, Manga)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── manga_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── title_model.dart        # Title.java 대응
│   │   │   │   └── manga_model.dart        # Manga.java 대응
│   │   │   └── repositories/
│   │   │       └── manga_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── title.dart              # 만화 제목 정보
│   │   │   │   ├── manga.dart              # 에피소드 정보
│   │   │   │   └── comment.dart
│   │   │   ├── repositories/
│   │   │   │   └── manga_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_title_detail.dart
│   │   │       ├── get_episodes.dart
│   │   │       ├── toggle_bookmark.dart
│   │   │       └── get_comments.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   ├── episode_page.dart       # EpisodeActivity 대응
│   │       │   └── comments_page.dart      # CommentsActivity 대응
│   │       └── widgets/
│   │
│   ├── viewer/                    # 만화 뷰어 (ViewerActivity)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── viewer_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── page_item_model.dart
│   │   │   └── repositories/
│   │   │       └── viewer_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── page_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── viewer_repository.dart
│   │   │   └── usecases/
│   │   │       ├── load_pages.dart
│   │   │       └── decode_image.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   ├── viewer_page.dart
│   │       │   ├── strip_viewer_page.dart  # ViewerActivity2 대응
│   │       │   └── webtoon_viewer_page.dart # ViewerActivity3 대응
│   │       └── widgets/
│   │           ├── page_viewer.dart
│   │           └── viewer_controls.dart
│   │
│   ├── search/                    # 검색 기능 (Search.java)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── search_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── search_result_model.dart
│   │   │   └── repositories/
│   │   │       └── search_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── search_result.dart
│   │   │   ├── repositories/
│   │   │   │   └── search_repository.dart
│   │   │   └── usecases/
│   │   │       ├── search_by_title.dart
│   │   │       ├── search_by_author.dart
│   │   │       └── search_by_tag.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   ├── search_page.dart
│   │       │   └── advanced_search_page.dart # AdvSearchActivity 대응
│   │       └── widgets/
│   │
│   ├── download/                  # 다운로드 기능 (Downloader.java)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── download_remote_datasource.dart
│   │   │   │   └── download_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── download_title_model.dart
│   │   │   └── repositories/
│   │   │       └── download_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── download_title.dart
│   │   │   ├── repositories/
│   │   │   │   └── download_repository.dart
│   │   │   └── usecases/
│   │   │       ├── download_manga.dart
│   │   │       ├── queue_download.dart
│   │   │       └── cancel_download.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       │   └── download_page.dart      # DownloadActivity 대응
│   │       └── widgets/
│   │           └── download_progress_card.dart
│   │
│   ├── favorites/                 # 즐겨찾기/북마크 (Bookmark.java)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── favorites_remote_datasource.dart
│   │   │   │   └── favorites_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── favorite_model.dart
│   │   │   └── repositories/
│   │   │       └── favorites_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── favorite.dart
│   │   │   ├── repositories/
│   │   │   │   └── favorites_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_favorites.dart
│   │   │       ├── add_favorite.dart
│   │   │       └── remove_favorite.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── widgets/
│   │
│   └── settings/                  # 설정 (SettingsActivity, Preference)
│       ├── data/
│       │   ├── datasources/
│       │   │   └── settings_local_datasource.dart
│       │   ├── models/
│       │   │   └── app_settings_model.dart
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── app_settings.dart
│       │   ├── repositories/
│       │   │   └── settings_repository.dart
│       │   └── usecases/
│       │       ├── get_settings.dart
│       │       └── update_settings.dart
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           │   └── settings_page.dart
│           └── widgets/
│
├── config/                        # 앱 설정
│   ├── routes/
│   │   └── app_router.dart        # GoRouter 설정
│   └── themes/
│       ├── app_theme.dart         # 다크모드 지원
│       └── app_colors.dart
│
└── main.dart                      # 앱 진입점
```

---

## 핵심 설계 원칙

### 1. Clean Architecture 3계층 분리

- **Presentation Layer**: UI (Pages, Widgets) + BLoC (State Management)
- **Domain Layer**: Business Logic (Entities, Use Cases, Repository Interfaces)
- **Data Layer**: 데이터 소스 (API, Local DB, Models, Repository Implementations)

### 2. 의존성 방향

```
Presentation → Domain ← Data
```

- Domain은 다른 레이어에 의존하지 않음 (순수 Dart 코드)
- Presentation과 Data는 Domain에 의존

### 3. State Management: BLoC Pattern

- **flutter_bloc** 패키지 사용
- 각 Feature마다 독립적인 BLoC 관리
- 이벤트 기반 상태 관리로 테스트 용이성 확보

---

## 기술 스택

### 필수 패키지 (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Network
  dio: ^5.4.0                      # CustomHttpClient 대체
  cookie_jar: ^4.0.8               # 쿠키 관리
  dio_cookie_manager: ^3.1.1

  # Local Storage
  shared_preferences: ^2.2.2       # Preference 대체
  path_provider: ^2.1.1
  hive: ^2.2.3                     # 오프라인 데이터
  hive_flutter: ^1.1.0

  # HTML Parsing
  html: ^0.15.4                    # JSoup 대체

  # Image
  cached_network_image: ^3.3.0     # Glide 대체
  photo_view: ^0.14.0              # 이미지 뷰어

  # Navigation
  go_router: ^12.1.3

  # DI (Dependency Injection)
  get_it: ^7.6.4
  injectable: ^2.3.2

  # JSON
  json_annotation: ^4.8.1

  # Utils
  dartz: ^0.10.1                   # Either for error handling
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # Code Generation
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  hive_generator: ^2.0.1

  # Testing
  mockito: ^5.4.4
  bloc_test: ^9.1.5
```

---

## 레거시 앱 매핑

| 레거시 Android | Flutter 아키텍처 |
|---------------|-----------------|
| `MainActivity.java` | `features/home/presentation/pages/home_page.dart` |
| `Title.java`, `Manga.java` | `features/manga/domain/entities/` |
| `Search.java` | `features/search/` |
| `Downloader.java` (Service) | `features/download/domain/usecases/` + Background Service |
| `ViewerActivity.java` | `features/viewer/presentation/pages/viewer_page.dart` |
| `CustomHttpClient.java` | `core/network/http_client.dart` (Dio 사용) |
| `Preference.java` | `features/settings/data/datasources/` (SharedPreferences) |
| `Bookmark.java` | `features/favorites/` |
| Adapters | `presentation/widgets/` (ListView.builder) |
| Fragments | `presentation/pages/tabs/` |

---

## 구현 로드맵

### Phase 1: Core Infrastructure

1. 프로젝트 구조 생성
2. 네트워크 클라이언트 구현 (Dio + Cookie)
3. 로컬 스토리지 구현 (Hive + SharedPreferences)
4. 라우팅 설정 (GoRouter)
5. 의존성 주입 (GetIt)

### Phase 2: 핵심 기능

1. 인증 (Login)
2. 홈 화면 (메인 페이지, 업데이트, 랭킹)
3. 만화 상세 (Title, Episodes)
4. 뷰어 (기본 뷰어)

### Phase 3: 추가 기능

1. 검색
2. 즐겨찾기
3. 다운로드
4. 설정

---

## 특별 고려사항

### 1. 캡차 처리

```dart
// core/network/interceptors.dart
class CaptchaInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 302 &&
        response.headers['location']?.contains('captcha.php') == true) {
      // CaptchaActivity로 리다이렉트
      throw CaptchaRequiredException();
    }
    handler.next(response);
  }
}
```

### 2. 오프라인 모드 지원

레거시 앱의 mode 값 시스템 유지:
```
mode:
0 = online
1 = offline - old
2 = offline - old(moa) (title.data)
3 = offline - latest(toki) (title.gson)
4 = offline - new(moa) (title.gson)
```

- Hive를 사용해 다운로드한 만화 메타데이터 저장
- `mode` 값으로 온라인/오프라인 구분

### 3. 다운로드 서비스

- `workmanager` 패키지로 백그라운드 다운로드 구현
- Notification으로 진행률 표시
- 레거시의 `Downloader.java` Service 로직 참고

### 4. 멀티 뷰어 지원

- **일반 뷰어** (`ViewerActivity`): `PageView.builder` 사용
- **스트립 뷰어** (`ViewerActivity2`): `SingleChildScrollView` 사용
- **웹툰 뷰어** (`ViewerActivity3`): `ListView.builder` 사용

### 5. 검색 모드

레거시 앱의 검색 모드 시스템 유지:
```
0  : 제목
1  : 작가
2  : 태그
3  : 글자
4  : 발행
6  : 종합
7  : (웹툰)제목
8  : (웹툰)작가
9  : (웹툰)태그
10 : (웹툰)글자
11 : (웹툰)발행
13 : (웹툰)종합
```

### 6. Base Mode

만화/웹툰 구분:
```dart
enum BaseMode {
  comic,   // base_comic
  webtoon, // base_webtoon
}
```

---

## 코딩 컨벤션

### 파일 명명 규칙

- **Entities**: `title.dart`, `manga.dart` (소문자, snake_case)
- **Models**: `title_model.dart` (Entity + _model)
- **Use Cases**: `get_title_detail.dart` (동사 + 명사)
- **Pages**: `home_page.dart` (화면명 + _page)
- **Widgets**: `manga_card.dart` (위젯명)
- **BLoC**: `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`

### 클래스 명명 규칙

- **Entities**: `Title`, `Manga` (PascalCase)
- **Models**: `TitleModel`, `MangaModel`
- **Use Cases**: `GetTitleDetail`, `ToggleBookmark`
- **BLoC**: `AuthBloc`, `AuthEvent`, `AuthState`

### 디렉토리 구조

- Feature-first 구조 (기능별로 묶음)
- 각 Feature는 `data`, `domain`, `presentation` 포함
- 공통 기능은 `core/`에 배치

---

## 테스트 전략

### 1. Unit Tests

- **Domain Layer**: Use Cases, Entities 로직 테스트
- **Data Layer**: Repository 구현, Model 변환 테스트

### 2. Widget Tests

- **Presentation Layer**: 개별 Widget 테스트

### 3. Integration Tests

- 전체 Flow 테스트 (로그인 → 만화 보기 → 뷰어)

### 4. BLoC Tests

- `bloc_test` 패키지 사용
- 이벤트 발생 시 상태 변화 검증

---

## 아키텍처 장점

- ✅ **확장성**: 새 기능 추가 용이 (Feature 단위 추가)
- ✅ **테스트 가능**: 각 레이어 독립 테스트
- ✅ **유지보수성**: 관심사 분리로 코드 이해 쉬움
- ✅ **재사용성**: Domain 로직은 플랫폼 독립적
- ✅ **의존성 역전**: 상위 레벨이 하위 레벨에 의존하지 않음

---

## 참고 문서

- [레거시 Android 앱](./references/MangaViewAndroid)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Pattern](https://bloclibrary.dev/)
- [Flutter 개발 가이드](./CLAUDE.md)
