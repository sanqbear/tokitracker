# Captcha Implementation Plan for tokitracker

## 문제 분석

### 현재 상황
- 타이틀 상세 페이지 접근 시 403 에러 발생
- `https://manatoki468.net/comic/23927390` 접근 시 Captcha 인증 필요
- 현재는 `CaptchaInterceptor`가 302 redirect만 감지하지만, 403은 처리하지 못함

### Android 참조 앱 분석
**CaptchaActivity.java 주요 동작:**
1. WebView로 Captcha 페이지 로드
2. JavaScript 활성화 및 DOM Storage 활성화
3. 기존 쿠키 삭제 후 새로 시작
4. User-Agent를 WebView의 요청에서 추출하여 HttpClient에 설정
5. `bootstrap` 또는 `jquery` 리소스 로드 감지 시 = Captcha 통과로 판단
6. WebView 쿠키를 추출하여 HttpClient에 저장
7. Activity 종료 및 결과 반환

**핵심 로직:**
```java
// 95-114번째 줄: Captcha 통과 감지
if (url.contains("bootstrap") || url.contains("jquery")) {
    // read cookies and finish
    String cookieStr = cookiem.getCookie(purl);
    if (cookieStr != null && cookieStr.length() > 0) {
        for (String s : cookieStr.split("; ")) {
            String k = s.substring(0, s.indexOf("="));
            String v = s.substring(s.indexOf("=") + 1);
            httpClient.setCookie(k, v);
        }
    }
    setResult(RESULT_CAPTCHA, resultIntent);
    finish();
}
```

## Flutter 구현 계획

### 1. Architecture

#### Feature Structure
```
lib/features/captcha/
├── domain/
│   ├── entities/
│   │   └── captcha_result.dart          # Captcha 인증 결과
│   ├── repositories/
│   │   └── captcha_repository.dart      # Repository 인터페이스
│   └── usecases/
│       └── verify_captcha.dart          # Captcha 인증 UseCase
├── data/
│   └── repositories/
│       └── captcha_repository_impl.dart # Repository 구현
└── presentation/
    ├── bloc/
    │   ├── captcha_event.dart           # BLoC 이벤트
    │   ├── captcha_state.dart           # BLoC 상태
    │   └── captcha_bloc.dart            # BLoC 로직
    ├── pages/
    │   └── captcha_page.dart            # Captcha 페이지
    └── widgets/
        └── captcha_webview.dart         # WebView 위젯
```

### 2. Domain Layer

#### 2.1. Entity: CaptchaResult

**lib/features/captcha/domain/entities/captcha_result.dart**
```dart
import 'package:equatable/equatable.dart';

class CaptchaResult extends Equatable {
  final bool success;
  final Map<String, String> cookies;
  final String? userAgent;
  final String? errorMessage;

  const CaptchaResult({
    required this.success,
    this.cookies = const {},
    this.userAgent,
    this.errorMessage,
  });

  const CaptchaResult.success({
    required Map<String, String> cookies,
    String? userAgent,
  }) : this(
          success: true,
          cookies: cookies,
          userAgent: userAgent,
        );

  const CaptchaResult.failure(String errorMessage)
      : this(
          success: false,
          errorMessage: errorMessage,
        );

  @override
  List<Object?> get props => [success, cookies, userAgent, errorMessage];
}
```

#### 2.2. Repository Interface

**lib/features/captcha/domain/repositories/captcha_repository.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/captcha/domain/entities/captcha_result.dart';

abstract class CaptchaRepository {
  /// Save cookies from captcha verification
  Future<Either<Failure, void>> saveCookies(Map<String, String> cookies);

  /// Update user agent
  Future<Either<Failure, void>> updateUserAgent(String userAgent);
}
```

#### 2.3. UseCase: VerifyCaptcha

**lib/features/captcha/domain/usecases/verify_captcha.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/captcha/domain/entities/captcha_result.dart';
import 'package:tokitracker/features/captcha/domain/repositories/captcha_repository.dart';

@injectable
class VerifyCaptcha {
  final CaptchaRepository repository;

  VerifyCaptcha(this.repository);

  Future<Either<Failure, void>> call(CaptchaResult result) async {
    if (!result.success) {
      return Left(ServerFailure(result.errorMessage ?? 'Captcha verification failed'));
    }

    // Save cookies
    final cookieResult = await repository.saveCookies(result.cookies);
    if (cookieResult.isLeft()) {
      return cookieResult;
    }

    // Update user agent if provided
    if (result.userAgent != null && result.userAgent!.isNotEmpty) {
      final uaResult = await repository.updateUserAgent(result.userAgent!);
      if (uaResult.isLeft()) {
        return uaResult;
      }
    }

    return const Right(null);
  }
}
```

### 3. Data Layer

#### 3.1. Repository Implementation

**lib/features/captcha/data/repositories/captcha_repository_impl.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/core/network/http_client.dart';
import 'package:tokitracker/core/storage/local_storage.dart';
import 'package:tokitracker/features/captcha/domain/repositories/captcha_repository.dart';

@Injectable(as: CaptchaRepository)
class CaptchaRepositoryImpl implements CaptchaRepository {
  final HttpClient httpClient;
  final LocalStorage localStorage;

  CaptchaRepositoryImpl(this.httpClient, this.localStorage);

  @override
  Future<Either<Failure, void>> saveCookies(Map<String, String> cookies) async {
    try {
      final baseUrl = localStorage.getBaseUrl();
      if (baseUrl == null || baseUrl.isEmpty) {
        return const Left(CacheFailure('Base URL not configured'));
      }

      final uri = Uri.parse(baseUrl);
      final cookieList = cookies.entries
          .map((e) => Cookie(e.key, e.value))
          .toList();

      await httpClient.setCookies(uri, cookieList);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save cookies: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserAgent(String userAgent) async {
    try {
      // Store user agent for future use
      // TODO: Implement user agent storage and update in HttpClient
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update user agent: $e'));
    }
  }
}
```

### 4. Presentation Layer

#### 4.1. BLoC Events

**lib/features/captcha/presentation/bloc/captcha_event.dart**
```dart
import 'package:equatable/equatable.dart';

sealed class CaptchaEvent extends Equatable {
  const CaptchaEvent();

  @override
  List<Object?> get props => [];
}

class CaptchaLoadRequested extends CaptchaEvent {
  final String url;

  const CaptchaLoadRequested(this.url);

  @override
  List<Object?> get props => [url];
}

class CaptchaResourceLoaded extends CaptchaEvent {
  final String resourceUrl;

  const CaptchaResourceLoaded(this.resourceUrl);

  @override
  List<Object?> get props => [resourceUrl];
}

class CaptchaVerified extends CaptchaEvent {
  final Map<String, String> cookies;
  final String? userAgent;

  const CaptchaVerified({
    required this.cookies,
    this.userAgent,
  });

  @override
  List<Object?> get props => [cookies, userAgent];
}

class CaptchaErrorOccurred extends CaptchaEvent {
  final String message;

  const CaptchaErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### 4.2. BLoC States

**lib/features/captcha/presentation/bloc/captcha_state.dart**
```dart
import 'package:equatable/equatable.dart';

sealed class CaptchaState extends Equatable {
  const CaptchaState();

  @override
  List<Object?> get props => [];
}

class CaptchaInitial extends CaptchaState {
  const CaptchaInitial();
}

class CaptchaLoading extends CaptchaState {
  final String url;

  const CaptchaLoading(this.url);

  @override
  List<Object?> get props => [url];
}

class CaptchaInProgress extends CaptchaState {
  final String url;
  final String message;

  const CaptchaInProgress({
    required this.url,
    this.message = 'CAPTCHA 인증중..',
  });

  @override
  List<Object?> get props => [url, message];
}

class CaptchaSuccess extends CaptchaState {
  const CaptchaSuccess();
}

class CaptchaError extends CaptchaState {
  final String message;

  const CaptchaError(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### 4.3. BLoC

**lib/features/captcha/presentation/bloc/captcha_bloc.dart**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/features/captcha/domain/entities/captcha_result.dart';
import 'package:tokitracker/features/captcha/domain/usecases/verify_captcha.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_event.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_state.dart';

@injectable
class CaptchaBloc extends Bloc<CaptchaEvent, CaptchaState> {
  final VerifyCaptcha verifyCaptcha;

  CaptchaBloc(this.verifyCaptcha) : super(const CaptchaInitial()) {
    on<CaptchaLoadRequested>(_onLoadRequested);
    on<CaptchaResourceLoaded>(_onResourceLoaded);
    on<CaptchaVerified>(_onVerified);
    on<CaptchaErrorOccurred>(_onErrorOccurred);
  }

  Future<void> _onLoadRequested(
    CaptchaLoadRequested event,
    Emitter<CaptchaState> emit,
  ) async {
    emit(CaptchaLoading(event.url));
    // Wait a bit for WebView to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    emit(CaptchaInProgress(url: event.url));
  }

  Future<void> _onResourceLoaded(
    CaptchaResourceLoaded event,
    Emitter<CaptchaState> emit,
  ) async {
    // Check if resource indicates captcha passed
    if (event.resourceUrl.contains('bootstrap') ||
        event.resourceUrl.contains('jquery')) {
      // Captcha likely passed, but actual verification happens in CaptchaVerified event
      emit(CaptchaInProgress(
        url: (state as CaptchaInProgress).url,
        message: 'CAPTCHA 인증 완료 중...',
      ));
    }
  }

  Future<void> _onVerified(
    CaptchaVerified event,
    Emitter<CaptchaState> emit,
  ) async {
    final result = CaptchaResult.success(
      cookies: event.cookies,
      userAgent: event.userAgent,
    );

    final saveResult = await verifyCaptcha(result);

    saveResult.fold(
      (failure) => emit(CaptchaError(failure.toString())),
      (_) => emit(const CaptchaSuccess()),
    );
  }

  Future<void> _onErrorOccurred(
    CaptchaErrorOccurred event,
    Emitter<CaptchaState> emit,
  ) async {
    emit(CaptchaError(event.message));
  }
}
```

#### 4.4. Captcha Page

**lib/features/captcha/presentation/pages/captcha_page.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_bloc.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_event.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_state.dart';
import 'package:tokitracker/features/captcha/presentation/widgets/captcha_webview.dart';
import 'package:tokitracker/injection_container.dart';

class CaptchaPage extends StatelessWidget {
  final String captchaUrl;

  const CaptchaPage({
    super.key,
    required this.captchaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CaptchaBloc>()
        ..add(CaptchaLoadRequested(captchaUrl)),
      child: BlocListener<CaptchaBloc, CaptchaState>(
        listener: (context, state) {
          if (state is CaptchaSuccess) {
            // Return success and pop
            context.pop(true);
          } else if (state is CaptchaError) {
            // Show error and stay on page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('CAPTCHA 인증'),
            backgroundColor: Colors.black,
          ),
          body: BlocBuilder<CaptchaBloc, CaptchaState>(
            builder: (context, state) {
              if (state is CaptchaLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is CaptchaInProgress) {
                return Column(
                  children: [
                    // WebView
                    Expanded(
                      child: CaptchaWebView(
                        url: state.url,
                        onResourceLoaded: (url) {
                          context.read<CaptchaBloc>().add(
                                CaptchaResourceLoaded(url),
                              );
                        },
                        onCookiesExtracted: (cookies, userAgent) {
                          context.read<CaptchaBloc>().add(
                                CaptchaVerified(
                                  cookies: cookies,
                                  userAgent: userAgent,
                                ),
                              );
                        },
                        onError: (message) {
                          context.read<CaptchaBloc>().add(
                                CaptchaErrorOccurred(message),
                              );
                        },
                      ),
                    ),
                    // Status bar
                    Container(
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(
                            backgroundColor: Color(0x80000000),
                          ),
                        ],
                      ),
                    ),
                    // Info text (shows after 3 seconds)
                    _InfoText(
                      delay: const Duration(seconds: 3),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _InfoText extends StatefulWidget {
  final Duration delay;

  const _InfoText({required this.delay});

  @override
  State<_InfoText> createState() => _InfoTextState();
}

class _InfoTextState extends State<_InfoText> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(40),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xD3292929),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '정상적인 웹 페이지가 나올 때까지 자동으로 종료되지 않을 경우, '
        'CAPTCHA 문제가 아니므로 다른 방법(URL 변경, 앱 재시작)을 시도해 보세요.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0x80FFFFFF),
          fontSize: 13,
        ),
      ),
    );
  }
}
```

#### 4.5. Captcha WebView Widget

**lib/features/captcha/presentation/widgets/captcha_webview.dart**
```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class CaptchaWebView extends StatefulWidget {
  final String url;
  final Function(String) onResourceLoaded;
  final Function(Map<String, String>, String?) onCookiesExtracted;
  final Function(String) onError;

  const CaptchaWebView({
    super.key,
    required this.url,
    required this.onResourceLoaded,
    required this.onCookiesExtracted,
    required this.onError,
  });

  @override
  State<CaptchaWebView> createState() => _CaptchaWebViewState();
}

class _CaptchaWebViewState extends State<CaptchaWebView> {
  late final WebViewController _controller;
  bool _captchaCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Platform-specific parameters
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Track page navigation
          },
          onPageFinished: (String url) async {
            // Page loaded, check for resources
            _checkForCaptchaCompletion(url);
          },
          onWebResourceError: (WebResourceError error) {
            widget.onError('연결에 실패했습니다. URL을 확인해 주세요');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      )
      ..loadRequest(Uri.parse(widget.url));

    // Platform-specific setup
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  Future<void> _checkForCaptchaCompletion(String url) async {
    if (_captchaCompleted) return;

    // Check if URL contains indicators of successful captcha completion
    if (url.contains('bootstrap') || url.contains('jquery')) {
      _captchaCompleted = true;
      widget.onResourceLoaded(url);

      // Extract cookies
      try {
        final cookieManager = WebViewCookieManager();
        final baseUri = Uri.parse(widget.url);
        final baseUrl = '${baseUri.scheme}://${baseUri.host}';

        // Get cookies for the domain
        final cookies = await _extractCookies(cookieManager, baseUrl);

        if (cookies.isNotEmpty) {
          // Get user agent
          final userAgent = await _controller.runJavaScriptReturningResult(
            'navigator.userAgent',
          ) as String?;

          widget.onCookiesExtracted(cookies, userAgent);
        } else {
          widget.onError('쿠키를 추출할 수 없습니다');
        }
      } catch (e) {
        widget.onError('인증 도중 오류가 발생했습니다: $e');
      }
    }
  }

  Future<Map<String, String>> _extractCookies(
    WebViewCookieManager cookieManager,
    String url,
  ) async {
    final cookies = <String, String>{};

    try {
      // Note: WebView cookie extraction is platform-specific
      // This is a simplified version - actual implementation may vary

      // For now, we'll use JavaScript to extract cookies
      final cookieString = await _controller.runJavaScriptReturningResult(
        'document.cookie',
      ) as String?;

      if (cookieString != null && cookieString.isNotEmpty) {
        // Parse cookie string
        for (final cookie in cookieString.split('; ')) {
          final parts = cookie.split('=');
          if (parts.length == 2) {
            cookies[parts[0]] = parts[1];
          }
        }
      }
    } catch (e) {
      // Fallback: try to extract cookies another way if needed
    }

    return cookies;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
```

### 5. Integration with Existing Code

#### 5.1. Update CaptchaInterceptor

**lib/core/network/interceptors/captcha_interceptor.dart**
```dart
import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

class CaptchaInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check for 302 redirect to captcha page
    if (response.statusCode == 302) {
      final location = response.headers.value('location');
      if (location != null && location.contains('captcha.php')) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: CaptchaRequiredException(location),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }
    }

    // Check for 403 Forbidden (may also indicate captcha)
    if (response.statusCode == 403) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: CaptchaRequiredException('Captcha required (403)'),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    // Check response body for captcha indicators
    if (response.data is String) {
      final body = response.data as String;
      if (body.contains('captcha') &&
          (body.contains('verification') || body.contains('recaptcha'))) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: CaptchaRequiredException(),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }
    }

    super.onResponse(response, handler);
  }
}
```

#### 5.2. Update TitleDetailPage to Handle Captcha

**lib/features/manga/presentation/pages/title_detail_page.dart**
```dart
// In the CaptchaRequired state builder:
} else if (state is TitleDetailCaptchaRequired) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.security, size: 64, color: Colors.orange),
        const SizedBox(height: 16),
        const Text(
          '캡차 인증이 필요합니다',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            // Navigate to captcha page
            final baseUrl = sl<LocalStorage>().getBaseUrl() ?? '';
            final result = await context.push<bool>(
              '/captcha?url=$baseUrl',
            );

            // If captcha succeeded, retry loading
            if (result == true) {
              context.read<TitleDetailBloc>().add(
                const TitleDetailRefreshRequested(),
              );
            }
          },
          child: const Text('캡차 인증하기'),
        ),
      ],
    ),
  );
}
```

#### 5.3. Update Router

**lib/config/routes/route_paths.dart**
```dart
class RoutePaths {
  // ... existing routes ...

  static const String captcha = '/captcha';
}
```

**lib/config/routes/route_names.dart**
```dart
class RouteNames {
  // ... existing routes ...

  static const String captcha = 'captcha';
}
```

**lib/config/routes/app_router.dart**
```dart
// Add route:
GoRoute(
  path: RoutePaths.captcha,
  name: RouteNames.captcha,
  builder: (context, state) {
    final url = state.uri.queryParameters['url'] ?? '';
    return CaptchaPage(captchaUrl: url);
  },
),
```

### 6. Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  webview_flutter: ^4.4.2
  webview_flutter_android: ^3.12.1
  webview_flutter_wkwebview: ^3.9.4
```

### 7. Implementation Steps

1. **Phase 1: Domain Layer** (30분)
   - Create entities, repository interface, usecase
   - Update exceptions if needed

2. **Phase 2: Data Layer** (30분)
   - Implement repository
   - Update cookie handling in HttpClient

3. **Phase 3: Presentation - BLoC** (45분)
   - Create events, states, bloc
   - Test bloc logic

4. **Phase 4: Presentation - UI** (1시간)
   - Create CaptchaPage
   - Create CaptchaWebView widget
   - Handle platform-specific WebView setup

5. **Phase 5: Integration** (45분)
   - Update CaptchaInterceptor for 403 handling
   - Update TitleDetailPage to navigate to captcha
   - Update router with captcha route
   - Test end-to-end flow

6. **Phase 6: Testing** (30분)
   - Test captcha detection
   - Test cookie extraction
   - Test navigation flow
   - Test error handling

**Total Estimated Time: 4 hours**

### 8. Testing Checklist

- [ ] 403 응답 시 CaptchaInterceptor가 예외를 발생시키는지 확인
- [ ] TitleDetailPage에서 캡차 필요 상태가 올바르게 표시되는지 확인
- [ ] 캡차 페이지로 네비게이션이 작동하는지 확인
- [ ] WebView가 올바르게 로드되는지 확인
- [ ] bootstrap/jquery 리소스 로드 시 감지되는지 확인
- [ ] 쿠키가 올바르게 추출되는지 확인
- [ ] 쿠키가 HttpClient에 저장되는지 확인
- [ ] 캡차 완료 후 타이틀 상세 페이지로 돌아가는지 확인
- [ ] 캡차 완료 후 재시도 시 페이지가 로드되는지 확인
- [ ] 에러 처리가 올바르게 작동하는지 확인

### 9. Known Issues and Limitations

1. **WebView Cookie Extraction**:
   - Flutter의 WebView 쿠키 추출은 플랫폼별로 다를 수 있음
   - JavaScript를 통한 `document.cookie` 접근으로 대체

2. **User Agent Handling**:
   - WebView의 User-Agent를 HttpClient에 동기화 필요
   - LocalStorage에 저장하여 앱 재시작 시에도 유지

3. **Platform Differences**:
   - Android와 iOS에서 WebView 동작이 다를 수 있음
   - 각 플랫폼별 테스트 필요

4. **Captcha Detection Logic**:
   - bootstrap/jquery 로드 감지가 완벽하지 않을 수 있음
   - 필요시 다른 감지 로직 추가 (예: DOM 구조 확인)

### 10. Future Enhancements

1. **자동 재시도**: 캡차 완료 후 자동으로 원래 페이지 재시도
2. **캡차 우회**: 특정 조건에서 캡차 없이 접근 가능한 경로 탐색
3. **쿠키 만료 처리**: 쿠키 만료 시 자동으로 캡차 페이지 표시
4. **진행 상태 표시**: WebView 로딩 진행률 표시
5. **타임아웃 처리**: 일정 시간 후 자동 취소 또는 재시도 제안

## Summary

이 구현 계획은 Android 참조 앱의 CaptchaActivity 로직을 Flutter로 포팅한 것입니다.
핵심은 WebView를 사용하여 실제 브라우저처럼 Captcha를 처리하고, 성공 시 쿠키를 추출하여
HttpClient에 저장하는 것입니다.

Clean Architecture를 따르며, 기존 코드와의 통합을 최소화하면서도
확장 가능한 구조를 제공합니다.
