import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/features/captcha/domain/entities/captcha_result.dart';
import 'package:tokitracker/features/captcha/domain/usecases/verify_captcha.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_event.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_state.dart';

/// BLoC for handling captcha verification flow
/// Corresponds to CaptchaActivity logic in Android app
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
    // Android logic: if (url.contains("bootstrap") || url.contains("jquery"))
    if (event.resourceUrl.contains('bootstrap') ||
        event.resourceUrl.contains('jquery')) {
      // Captcha likely passed, show updated message
      if (state is CaptchaInProgress) {
        emit(CaptchaInProgress(
          url: (state as CaptchaInProgress).url,
          message: 'CAPTCHA 인증 완료 중...',
        ));
      }
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
