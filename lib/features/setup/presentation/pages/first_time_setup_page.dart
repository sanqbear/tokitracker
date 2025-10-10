import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection_container.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../config/routes/route_paths.dart';

class FirstTimeSetupPage extends StatefulWidget {
  const FirstTimeSetupPage({super.key});

  @override
  State<FirstTimeSetupPage> createState() => _FirstTimeSetupPageState();
}

class _FirstTimeSetupPageState extends State<FirstTimeSetupPage> {
  final _localStorage = sl<LocalStorage>();
  final _baseUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save base URL
      await _localStorage.setBaseUrl(_baseUrlController.text.trim());

      // Mark first time setup as complete
      await _localStorage.setFirstTimeCompleted();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('설정이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home
        context.go(RoutePaths.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정 저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome icon
                  Icon(
                    Icons.rocket_launch,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Welcome title
                  Text(
                    'TokiTracker에 오신 것을 환영합니다!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    '시작하기 전에 기본 설정을 완료해주세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Base URL field
                  TextFormField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Base URL',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                      helperText: '만화 사이트 주소를 입력하세요',
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Base URL을 입력해주세요';
                      }
                      if (!value.startsWith('http://') &&
                          !value.startsWith('https://')) {
                        return 'http:// 또는 https://로 시작해야 합니다';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Info card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '나중에 설정에서 변경할 수 있습니다',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Start button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '시작하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
