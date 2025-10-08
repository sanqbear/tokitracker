/// Route names for the application
/// Centralized route name definitions for type-safe navigation
class RouteNames {
  RouteNames._();

  // Root
  static const String splash = 'splash';
  static const String firstTime = 'first-time';

  // Authentication
  static const String login = 'login';
  static const String captcha = 'captcha';

  // Main
  static const String home = 'home';

  // Manga
  static const String mangaDetail = 'manga-detail';
  static const String episodeList = 'episode-list';
  static const String comments = 'comments';

  // Viewer
  static const String viewer = 'viewer';
  static const String stripViewer = 'strip-viewer';
  static const String webtoonViewer = 'webtoon-viewer';

  // Search
  static const String search = 'search';
  static const String advancedSearch = 'advanced-search';
  static const String tagSearch = 'tag-search';

  // Download
  static const String downloads = 'downloads';
  static const String downloadQueue = 'download-queue';

  // Favorites
  static const String favorites = 'favorites';

  // Settings
  static const String settings = 'settings';
  static const String folderSelect = 'folder-select';
  static const String layoutEdit = 'layout-edit';
  static const String license = 'license';
  static const String notices = 'notices';
  static const String debug = 'debug';
}
