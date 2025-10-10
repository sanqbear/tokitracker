import 'package:equatable/equatable.dart';

/// Captcha BLoC events
sealed class CaptchaEvent extends Equatable {
  const CaptchaEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load captcha page
class CaptchaLoadRequested extends CaptchaEvent {
  final String url;

  const CaptchaLoadRequested(this.url);

  @override
  List<Object?> get props => [url];
}

/// Captcha resource (bootstrap/jquery) detected as loaded
class CaptchaResourceLoaded extends CaptchaEvent {
  final String resourceUrl;

  const CaptchaResourceLoaded(this.resourceUrl);

  @override
  List<Object?> get props => [resourceUrl];
}

/// Captcha verification completed with cookies extracted
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

/// Error occurred during captcha process
class CaptchaErrorOccurred extends CaptchaEvent {
  final String message;

  const CaptchaErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
