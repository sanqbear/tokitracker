import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import 'route_names.dart';
import 'route_paths.dart';
import '../../core/storage/local_storage.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/setup/presentation/pages/first_time_setup_page.dart';

/// Application router configuration
@singleton
class AppRouter {
  final LocalStorage _localStorage;

  AppRouter(this._localStorage);

  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      // Splash / Root
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => _buildPlaceholder('Splash'),
      ),

      // First Time Setup
      GoRoute(
        path: RoutePaths.firstTime,
        name: RouteNames.firstTime,
        builder: (context, state) => const FirstTimeSetupPage(),
      ),

      // Authentication
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.captcha,
        name: RouteNames.captcha,
        builder: (context, state) {
          final captchaUrl = state.uri.queryParameters['url'];
          return _buildPlaceholder('Captcha: $captchaUrl');
        },
      ),

      // Home
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),

      // Manga Detail
      GoRoute(
        path: RoutePaths.mangaDetail,
        name: RouteNames.mangaDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPlaceholder('Manga Detail: $id');
        },
      ),

      // Episode List
      GoRoute(
        path: RoutePaths.episodeList,
        name: RouteNames.episodeList,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPlaceholder('Episode List: $id');
        },
      ),

      // Comments
      GoRoute(
        path: RoutePaths.comments,
        name: RouteNames.comments,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPlaceholder('Comments: $id');
        },
      ),

      // Viewer
      GoRoute(
        path: RoutePaths.viewer,
        name: RouteNames.viewer,
        builder: (context, state) {
          final titleId = state.pathParameters['titleId']!;
          final episodeId = state.pathParameters['episodeId']!;
          return _buildPlaceholder('Viewer: $titleId / $episodeId');
        },
      ),

      // Strip Viewer
      GoRoute(
        path: RoutePaths.stripViewer,
        name: RouteNames.stripViewer,
        builder: (context, state) {
          final titleId = state.pathParameters['titleId']!;
          final episodeId = state.pathParameters['episodeId']!;
          return _buildPlaceholder('Strip Viewer: $titleId / $episodeId');
        },
      ),

      // Webtoon Viewer
      GoRoute(
        path: RoutePaths.webtoonViewer,
        name: RouteNames.webtoonViewer,
        builder: (context, state) {
          final titleId = state.pathParameters['titleId']!;
          final episodeId = state.pathParameters['episodeId']!;
          return _buildPlaceholder('Webtoon Viewer: $titleId / $episodeId');
        },
      ),

      // Search
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => _buildPlaceholder('Search'),
      ),

      // Advanced Search
      GoRoute(
        path: RoutePaths.advancedSearch,
        name: RouteNames.advancedSearch,
        builder: (context, state) => _buildPlaceholder('Advanced Search'),
      ),

      // Tag Search
      GoRoute(
        path: RoutePaths.tagSearch,
        name: RouteNames.tagSearch,
        builder: (context, state) {
          final tag = state.uri.queryParameters['tag'];
          return _buildPlaceholder('Tag Search: $tag');
        },
      ),

      // Downloads
      GoRoute(
        path: RoutePaths.downloads,
        name: RouteNames.downloads,
        builder: (context, state) => _buildPlaceholder('Downloads'),
      ),

      // Download Queue
      GoRoute(
        path: RoutePaths.downloadQueue,
        name: RouteNames.downloadQueue,
        builder: (context, state) => _buildPlaceholder('Download Queue'),
      ),

      // Favorites
      GoRoute(
        path: RoutePaths.favorites,
        name: RouteNames.favorites,
        builder: (context, state) => _buildPlaceholder('Favorites'),
      ),

      // Settings
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // Folder Select
      GoRoute(
        path: RoutePaths.folderSelect,
        name: RouteNames.folderSelect,
        builder: (context, state) => _buildPlaceholder('Folder Select'),
      ),

      // Layout Edit
      GoRoute(
        path: RoutePaths.layoutEdit,
        name: RouteNames.layoutEdit,
        builder: (context, state) => _buildPlaceholder('Layout Edit'),
      ),

      // License
      GoRoute(
        path: RoutePaths.license,
        name: RouteNames.license,
        builder: (context, state) => _buildPlaceholder('License'),
      ),

      // Notices
      GoRoute(
        path: RoutePaths.notices,
        name: RouteNames.notices,
        builder: (context, state) => _buildPlaceholder('Notices'),
      ),

      // Debug
      GoRoute(
        path: RoutePaths.debug,
        name: RouteNames.debug,
        builder: (context, state) => _buildPlaceholder('Debug'),
      ),
    ],
    errorBuilder: (context, state) => _buildErrorPage(state.error),
  );

  /// Handle global redirects
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isFirstTime = _localStorage.isFirstTime();
    final currentPath = state.uri.path;

    // Redirect to first time setup if needed
    if (isFirstTime && currentPath != RoutePaths.firstTime) {
      return RoutePaths.firstTime;
    }

    // After first time setup, redirect to home
    if (!isFirstTime && currentPath == RoutePaths.splash) {
      return RoutePaths.home;
    }

    // No redirect needed
    return null;
  }

  /// Build placeholder page (temporary until actual pages are implemented)
  Widget _buildPlaceholder(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This page is under construction',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error page
  Widget _buildErrorPage(Exception? error) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (error != null) ...[
              SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
