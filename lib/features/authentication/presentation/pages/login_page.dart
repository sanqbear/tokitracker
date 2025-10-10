import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../../../config/routes/route_paths.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(const AuthCaptchaRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('로그인'),
          centerTitle: true,
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // Navigate to home on successful login
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('로그인 성공!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.go(RoutePaths.home);
            } else if (state is AuthLoginError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AuthCaptchaError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthInitial || state is AuthCaptchaLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is AuthCaptchaError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      '캡차 로드 실패',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthCaptchaRequested());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 시도'),
                    ),
                  ],
                ),
              );
            }

            // Show login form for CaptchaLoaded, LoginInProgress, and LoginError states
            return const SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: LoginForm(),
            );
          },
        ),
      ),
    );
  }
}
