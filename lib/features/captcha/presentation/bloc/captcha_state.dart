import 'package:equatable/equatable.dart';

/// Captcha BLoC states
sealed class CaptchaState extends Equatable {
  const CaptchaState();

  @override
  List<Object?> get props => [];
}

/// Initial state before captcha loads
class CaptchaInitial extends CaptchaState {
  const CaptchaInitial();
}

/// Captcha page is loading
class CaptchaLoading extends CaptchaState {
  final String url;

  const CaptchaLoading(this.url);

  @override
  List<Object?> get props => [url];
}

/// Captcha verification in progress
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

/// Captcha verification successful
class CaptchaSuccess extends CaptchaState {
  const CaptchaSuccess();
}

/// Captcha verification failed
class CaptchaError extends CaptchaState {
  final String message;

  const CaptchaError(this.message);

  @override
  List<Object?> get props => [message];
}
