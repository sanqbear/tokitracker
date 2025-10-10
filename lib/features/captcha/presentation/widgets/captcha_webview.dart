import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// WebView widget for captcha verification
/// Corresponds to WebView in activity_captcha.xml and CaptchaActivity.java
/// Now using flutter_inappwebview for cross-platform support (Windows, iOS, Android, macOS)
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
  InAppWebViewController? _controller;
  bool _captchaCompleted = false;
  late final String _initialUrl;
  Timer? _contentCheckTimer;

  @override
  void initState() {
    super.initState();
    _initialUrl = widget.url;
    _startPeriodicContentCheck();
  }

  @override
  void dispose() {
    _contentCheckTimer?.cancel();
    super.dispose();
  }

  /// Start periodic content verification
  /// This helps detect captcha completion when resource loading doesn't trigger
  /// Useful for image captcha where bootstrap/jquery may not load
  void _startPeriodicContentCheck() {
    _contentCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_captchaCompleted) {
        timer.cancel();
        return;
      }

      try {
        if (_controller != null) {
          final currentUrl = await _controller!.getUrl();
          if (currentUrl != null && !currentUrl.toString().contains('challenges.cloudflare.com')) {
            debugPrint('CaptchaWebView: Periodic check for URL: $currentUrl');
            await _verifyPageContent(currentUrl.toString());
          }
        }
      } catch (e) {
        debugPrint('CaptchaWebView: Error in periodic content check: $e');
      }
    });
  }

  /// Verify that the page actually contains content (not just a challenge page)
  Future<void> _verifyPageContent(String url) async {
    if (_captchaCompleted || _controller == null) return;

    try {
      // Check if the page has typical manga site content
      // by looking for specific elements that indicate a successful load
      final result = await _controller!.evaluateJavascript(source: '''
        (function() {
          // Check for common manga site elements
          var hasViewTitle = document.querySelector('.view-title') !== null;
          var hasListBody = document.querySelector('.list-body') !== null;
          var hasViewContent = document.querySelector('.view-content') !== null;

          // Check that we're not on a Cloudflare challenge page
          var isCfChallenge = document.title.toLowerCase().includes('just a moment') ||
                              document.title.toLowerCase().includes('checking') ||
                              document.body.innerHTML.includes('cf-challenge');

          // Check that we're not on a captcha input page (image captcha)
          var isCaptchaInput = document.querySelector('input[name="captcha"]') !== null ||
                               document.querySelector('input[name*="captcha"]') !== null ||
                               (document.querySelector('img') !== null &&
                                document.querySelector('img').src.includes('captcha')) ||
                               window.location.href.includes('captcha.php');

          return (hasViewTitle || hasListBody || hasViewContent) && !isCfChallenge && !isCaptchaInput;
        })();
      ''');

      final hasContent = result == true;
      debugPrint('CaptchaWebView: Page has valid content: $hasContent');

      if (hasContent) {
        debugPrint('CaptchaWebView: Detected successful page load with content verification');
        _handleCaptchaCompletion(url);
      }
    } catch (e) {
      debugPrint('CaptchaWebView: Error verifying page content: $e');
    }
  }

  Future<void> _handleCaptchaCompletion(String url) async {
    if (_captchaCompleted || _controller == null) return;

    _captchaCompleted = true;
    debugPrint('CaptchaWebView: Captcha completed, extracting cookies');
    widget.onResourceLoaded(url);

    // Small delay to ensure cookies are set
    await Future.delayed(const Duration(milliseconds: 1000));

    // Extract cookies
    try {
      final cookies = await _extractCookies();

      debugPrint('CaptchaWebView: Successfully extracted ${cookies.length} cookies');

      // Get user agent
      final userAgent = await _controller!.evaluateJavascript(
        source: 'navigator.userAgent',
      ) as String?;

      debugPrint('CaptchaWebView: User agent: $userAgent');

      // Always call onCookiesExtracted even if cookies map is empty
      // The cookies are stored in the CookieManager
      widget.onCookiesExtracted(cookies, userAgent);
    } catch (e) {
      debugPrint('CaptchaWebView: Error extracting cookies: $e');
      widget.onError('인증 도중 오류가 발생했습니다: $e');
    }
  }

  Future<Map<String, String>> _extractCookies() async {
    final cookies = <String, String>{};

    try {
      if (_controller == null) return cookies;

      final currentUrl = await _controller!.getUrl();
      if (currentUrl == null) return cookies;

      debugPrint('CaptchaWebView: Extracting cookies for URL: $currentUrl');

      // Use CookieManager to get all cookies (includes HttpOnly cookies)
      // This works on all platforms: Android, iOS, Windows, macOS
      final cookieManager = CookieManager.instance();
      final webCookies = await cookieManager.getCookies(url: WebUri.uri(currentUrl));

      for (final cookie in webCookies) {
        cookies[cookie.name] = cookie.value.toString();
        debugPrint('CaptchaWebView: Extracted cookie: ${cookie.name} (HttpOnly: ${cookie.isHttpOnly})');
      }

      debugPrint('CaptchaWebView: Extracted ${cookies.length} cookies total');
    } catch (e) {
      debugPrint('CaptchaWebView: Error extracting cookies: $e');
    }

    return cookies;
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        // Allow all mixed content for captcha pages
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
        debugPrint('CaptchaWebView: WebView created');
      },
      onLoadStart: (controller, url) {
        debugPrint('CaptchaWebView: Page started loading: $url');
      },
      onLoadStop: (controller, url) async {
        debugPrint('CaptchaWebView: Page finished loading: $url');

        // Check if this is actually a successful page load by verifying content
        if (url != null && !url.toString().contains('challenges.cloudflare.com')) {
          await _verifyPageContent(url.toString());
        }
      },
      onReceivedError: (controller, request, error) {
        debugPrint('CaptchaWebView: Error: ${error.description}');
        widget.onError('연결에 실패했습니다. URL을 확인해 주세요');
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url.toString();
        debugPrint('CaptchaWebView: Navigation request: $url');

        // Android logic: shouldOverrideUrlLoading checks for bootstrap/jquery
        // Check if this navigation indicates captcha completion
        if (url.contains('bootstrap') || url.contains('jquery')) {
          debugPrint('CaptchaWebView: Detected captcha completion via resource load');
          _handleCaptchaCompletion(url);
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}
