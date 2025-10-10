/// Enum representing the type of manga/webtoon content
/// Corresponds to MTitle.baseMode in legacy Android app
enum BaseMode {
  /// Auto-detect mode (defaults to comic)
  auto,

  /// Comic/manga mode (일본만화)
  comic,

  /// Webtoon mode (웹툰)
  webtoon;

  /// Convert to URL path segment
  /// comic -> "comic", webtoon -> "webtoon"
  String toUrlPath() {
    switch (this) {
      case BaseMode.comic:
        return 'comic';
      case BaseMode.webtoon:
        return 'webtoon';
      case BaseMode.auto:
        return 'comic'; // default
    }
  }

  /// Convert to Korean display name
  /// comic -> "만화", webtoon -> "웹툰"
  String toDisplayName() {
    switch (this) {
      case BaseMode.comic:
        return '만화';
      case BaseMode.webtoon:
        return '웹툰';
      case BaseMode.auto:
        return '자동';
    }
  }

  /// Parse from URL path segment
  static BaseMode fromUrlPath(String path) {
    switch (path.toLowerCase()) {
      case 'comic':
        return BaseMode.comic;
      case 'webtoon':
        return BaseMode.webtoon;
      default:
        return BaseMode.auto;
    }
  }
}
