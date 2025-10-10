import 'package:equatable/equatable.dart';

/// Captcha verification result
/// Contains cookies and user agent extracted from WebView after successful captcha completion
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

  /// Create a successful result with cookies and optional user agent
  const CaptchaResult.success({
    required Map<String, String> cookies,
    String? userAgent,
  }) : this(
          success: true,
          cookies: cookies,
          userAgent: userAgent,
        );

  /// Create a failure result with error message
  const CaptchaResult.failure(String errorMessage)
      : this(
          success: false,
          errorMessage: errorMessage,
        );

  @override
  List<Object?> get props => [success, cookies, userAgent, errorMessage];
}
