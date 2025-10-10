/// Route paths for the application
/// Defines the URL structure for each route
class RoutePaths {
  RoutePaths._();

  // Root
  static const String splash = '/';
  static const String firstTime = '/first-time';

  // Authentication
  static const String login = '/login';
  static const String captcha = '/captcha';

  // Main
  static const String home = '/home';

  // Manga/Title
  static const String comicDetail = '/comic/:id';
  static const String webtoonDetail = '/webtoon/:id';
  static const String mangaDetail = '/manga/:id'; // Deprecated - use comicDetail or webtoonDetail
  static const String episodeList = '/manga/:id/episodes';
  static const String comments = '/manga/:id/comments';

  // Viewer
  static const String viewer = '/viewer/:titleId/:episodeId';
  static const String stripViewer = '/strip-viewer/:titleId/:episodeId';
  static const String webtoonViewer = '/webtoon-viewer/:titleId/:episodeId';

  // Search
  static const String search = '/search';
  static const String advancedSearch = '/search/advanced';
  static const String tagSearch = '/search/tag';

  // Download
  static const String downloads = '/downloads';
  static const String downloadQueue = '/downloads/queue';

  // Favorites
  static const String favorites = '/favorites';

  // Settings
  static const String settings = '/settings';
  static const String folderSelect = '/settings/folder-select';
  static const String layoutEdit = '/settings/layout-edit';
  static const String license = '/settings/license';
  static const String notices = '/settings/notices';
  static const String debug = '/settings/debug';
}
