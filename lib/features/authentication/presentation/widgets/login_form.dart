import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginRequested(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            captchaAnswer: _captchaController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          // Logo or title
          Icon(
            Icons.book,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'TokiTracker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Username field
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: '아이디',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '아이디를 입력하세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '비밀번호',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력하세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Captcha image
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Show captcha for both loaded and error states
              final captchaImage = state is AuthCaptchaLoaded
                  ? state.captchaImage
                  : state is AuthLoginError
                      ? state.captchaImage
                      : null;

              if (captchaImage != null) {
                return Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.memory(
                          captchaImage,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _captchaController.clear();
                          context
                              .read<AuthBloc>()
                              .add(const AuthCaptchaRequested());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('새로고침'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 16),

          // Captcha answer field
          TextFormField(
            controller: _captchaController,
            decoration: const InputDecoration(
              labelText: '보안문자',
              prefixIcon: Icon(Icons.security),
              border: OutlineInputBorder(),
              helperText: '위 이미지에 표시된 문자를 입력하세요',
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(context),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '보안문자를 입력하세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Login button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoginInProgress;

              return ElevatedButton(
                onPressed: isLoading ? null : () => _handleLogin(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '로그인',
                        style: TextStyle(fontSize: 16),
                      ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Additional info
          Text(
            '* 자동 로그인이 활성화됩니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
