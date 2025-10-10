import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_bloc.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_event.dart';
import 'package:tokitracker/features/captcha/presentation/bloc/captcha_state.dart';
import 'package:tokitracker/features/captcha/presentation/widgets/captcha_webview.dart';
import 'package:tokitracker/injection_container.dart';

/// Captcha verification page
/// Corresponds to CaptchaActivity.java in Android app
/// Now using flutter_inappwebview for cross-platform support (Android, iOS, Windows, macOS, Web)
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
            // Show error in snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: '닫기',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
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
              } else if (state is CaptchaError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Retry loading
                          context.read<CaptchaBloc>().add(
                                CaptchaLoadRequested(captchaUrl),
                              );
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
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

/// Info text widget that shows after a delay
/// Corresponds to infoText in activity_captcha.xml
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
