import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// WebView widget for captcha verification
/// Corresponds to WebView in activity_captcha.xml and CaptchaActivity.java
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
            debugPrint('CaptchaWebView: Page started loading: $url');
          },
          onPageFinished: (String url) async {
            // Page loaded, check for resources
            debugPrint('CaptchaWebView: Page finished loading: $url');
            _checkForCaptchaCompletion(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('CaptchaWebView: Resource error: ${error.description}');
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.timeout) {
              widget.onError('연결에 실패했습니다. URL을 확인해 주세요');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            debugPrint('CaptchaWebView: Navigation request: ${request.url}');
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
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  Future<void> _checkForCaptchaCompletion(String url) async {
    if (_captchaCompleted) return;

    // Android logic: if (url.contains("bootstrap") || url.contains("jquery"))
    // Check if URL contains indicators of successful captcha completion
    if (url.contains('bootstrap') || url.contains('jquery')) {
      _captchaCompleted = true;
      widget.onResourceLoaded(url);

      // Extract cookies
      try {
        // Get cookies from WebView
        final cookies = await _extractCookies();

        if (cookies.isNotEmpty) {
          // Get user agent
          final userAgent =
              await _controller.runJavaScriptReturningResult(
            'navigator.userAgent',
          ) as String?;

          // Clean up user agent string (remove quotes if present)
          final cleanUserAgent = userAgent?.replaceAll('"', '');

          widget.onCookiesExtracted(cookies, cleanUserAgent);
        } else {
          widget.onError('쿠키를 추출할 수 없습니다');
        }
      } catch (e) {
        debugPrint('CaptchaWebView: Error extracting cookies: $e');
        widget.onError('인증 도중 오류가 발생했습니다: $e');
      }
    }
  }

  Future<Map<String, String>> _extractCookies() async {
    final cookies = <String, String>{};

    try {
      // Use JavaScript to extract cookies from document.cookie
      // Android equivalent: cookiem.getCookie(purl)
      final cookieString = await _controller.runJavaScriptReturningResult(
        'document.cookie',
      ) as String?;

      if (cookieString != null && cookieString.isNotEmpty) {
        // Remove surrounding quotes if present
        final cleanCookieString = cookieString.replaceAll('"', '');

        // Parse cookie string: "key1=value1; key2=value2; ..."
        // Android equivalent: for (String s : cookieStr.split("; "))
        for (final cookie in cleanCookieString.split('; ')) {
          if (cookie.contains('=')) {
            final parts = cookie.split('=');
            if (parts.length >= 2) {
              final key = parts[0].trim();
              final value = parts.sublist(1).join('=').trim(); // Handle '=' in value
              if (key.isNotEmpty && value.isNotEmpty) {
                cookies[key] = value;
              }
            }
          }
        }
      }

      debugPrint('CaptchaWebView: Extracted ${cookies.length} cookies');
    } catch (e) {
      debugPrint('CaptchaWebView: Error extracting cookies: $e');
    }

    return cookies;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
