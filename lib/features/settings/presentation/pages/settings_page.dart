import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../../../core/storage/local_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _localStorage = sl<LocalStorage>();
  final _baseUrlController = TextEditingController();
  final _homeDirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final baseUrl = _localStorage.getBaseUrl() ?? '';
    final homeDir = _localStorage.getHomeDir() ?? '';

    _baseUrlController.text = baseUrl;
    _homeDirController.text = homeDir;
  }

  Future<void> _saveSettings() async {
    await _localStorage.setBaseUrl(_baseUrlController.text.trim());
    await _localStorage.setHomeDir(_homeDirController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정이 저장되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _homeDirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: '저장',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '기본 설정',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              hintText: 'https://example.com',
              border: OutlineInputBorder(),
              helperText: 'API 서버 주소를 입력하세요',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _homeDirController,
            decoration: const InputDecoration(
              labelText: '다운로드 디렉토리',
              hintText: '/storage/emulated/0/TokiTracker',
              border: OutlineInputBorder(),
              helperText: '만화를 저장할 디렉토리',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('설정 저장'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
