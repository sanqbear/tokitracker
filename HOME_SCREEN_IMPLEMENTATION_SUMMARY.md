# Home Screen Implementation Summary

## Overview
Successfully implemented the Home Screen feature with Comic and Webtoon tabs, following Clean Architecture principles. The implementation includes HTML parsing, state management with BLoC, and comprehensive UI components.

## Implementation Date
2025-10-10

## Features Implemented

### 1. Domain Layer
#### Entities
- **BaseMode** ([lib/features/home/domain/entities/base_mode.dart](lib/features/home/domain/entities/base_mode.dart))
  - Enum for content types: `auto`, `comic`, `webtoon`
  - URL path conversion method

- **MangaTitle** ([lib/features/home/domain/entities/manga_title.dart](lib/features/home/domain/entities/manga_title.dart))
  - Core entity for manga/webtoon titles
  - Properties: id, name, thumbnailUrl, author, tags, release, baseMode

- **Episode** ([lib/features/home/domain/entities/episode.dart](lib/features/home/domain/entities/episode.dart))
  - Entity for individual episodes/chapters
  - Properties: id, name, date, thumbnailUrl, baseMode

- **RankedItem** ([lib/features/home/domain/entities/ranked_item.dart](lib/features/home/domain/entities/ranked_item.dart))
  - Generic wrapper for ranked items
  - Properties: item (generic), ranking

- **RankingSection** ([lib/features/home/domain/entities/ranking_section.dart](lib/features/home/domain/entities/ranking_section.dart))
  - Container for grouped ranking items
  - Properties: name, items

- **ComicHomeData** ([lib/features/home/domain/entities/comic_home_data.dart](lib/features/home/domain/entities/comic_home_data.dart))
  - Aggregates comic home page data
  - Properties: recentManga, rankingTitles, weeklyRanking

- **WebtoonHomeData** ([lib/features/home/domain/entities/webtoon_home_data.dart](lib/features/home/domain/entities/webtoon_home_data.dart))
  - Aggregates webtoon home page data
  - Properties: sections (8 ranking sections)

#### Repository Interface
- **HomeRepository** ([lib/features/home/domain/repositories/home_repository.dart](lib/features/home/domain/repositories/home_repository.dart))
  - Abstract interface following Repository pattern
  - Methods: `fetchComicHomeData()`, `fetchWebtoonHomeData()`

#### Use Cases
- **FetchComicHomeData** ([lib/features/home/domain/usecases/fetch_comic_home_data.dart](lib/features/home/domain/usecases/fetch_comic_home_data.dart))
  - Encapsulates business logic for fetching comic home data

- **FetchWebtoonHomeData** ([lib/features/home/domain/usecases/fetch_webtoon_home_data.dart](lib/features/home/domain/usecases/fetch_webtoon_home_data.dart))
  - Encapsulates business logic for fetching webtoon home data

### 2. Data Layer
#### Models
All models extend their domain entities and implement JSON serialization:
- **MangaTitleModel** ([lib/features/home/data/models/manga_title_model.dart](lib/features/home/data/models/manga_title_model.dart))
- **EpisodeModel** ([lib/features/home/data/models/episode_model.dart](lib/features/home/data/models/episode_model.dart))
- **RankedItemModel** ([lib/features/home/data/models/ranked_item_model.dart](lib/features/home/data/models/ranked_item_model.dart))
- **RankingSectionModel** ([lib/features/home/data/models/ranking_section_model.dart](lib/features/home/data/models/ranking_section_model.dart))
- **ComicHomeDataModel** ([lib/features/home/data/models/comic_home_data_model.dart](lib/features/home/data/models/comic_home_data_model.dart))
- **WebtoonHomeDataModel** ([lib/features/home/data/models/webtoon_home_data_model.dart](lib/features/home/data/models/webtoon_home_data_model.dart))

#### Data Sources
- **HomeRemoteDataSource** ([lib/features/home/data/datasources/home_remote_datasource.dart](lib/features/home/data/datasources/home_remote_datasource.dart))
  - Core HTML parsing logic
  - Methods:
    - `fetchComicHome()` - Fetches and parses comic home page
    - `fetchWebtoonHome()` - Fetches and parses webtoon home page
    - `_parseRecentManga()` - Parses recent manga section
    - `_parseRankingTitles()` - Parses ranking titles section
    - `_parseWeeklyRanking()` - Parses weekly ranking section
    - `_parseWebtoonSections()` - Parses 8 webtoon sections
    - `_normalizeImageUrl()` - Normalizes image URLs to use baseURL host

#### Repository Implementation
- **HomeRepositoryImpl** ([lib/features/home/data/repositories/home_repository_impl.dart](lib/features/home/data/repositories/home_repository_impl.dart))
  - Implements HomeRepository interface
  - Error handling with Either<Failure, Data> pattern
  - Converts exceptions to appropriate Failure types

### 3. Presentation Layer
#### BLoC Pattern
- **HomeEvent** ([lib/features/home/presentation/bloc/home_event.dart](lib/features/home/presentation/bloc/home_event.dart))
  - Events: HomeComicDataRequested, HomeWebtoonDataRequested, HomeRefreshRequested

- **HomeState** ([lib/features/home/presentation/bloc/home_state.dart](lib/features/home/presentation/bloc/home_state.dart))
  - States: HomeInitial, HomeComicLoading, HomeComicLoaded, HomeComicError
  - States: HomeWebtoonLoading, HomeWebtoonLoaded, HomeWebtoonError

- **HomeBloc** ([lib/features/home/presentation/bloc/home_bloc.dart](lib/features/home/presentation/bloc/home_bloc.dart))
  - Manages home screen state
  - Handles comic and webtoon data fetching
  - Supports pull-to-refresh

#### Pages
- **HomePage** ([lib/features/home/presentation/pages/home_page.dart](lib/features/home/presentation/pages/home_page.dart))
  - Main page with TabBar (Comic/Webtoon)
  - Manages tab switching and data loading
  - Integrates with HomeBloc

#### Widgets
- **ComicTab** ([lib/features/home/presentation/widgets/comic_tab.dart](lib/features/home/presentation/widgets/comic_tab.dart))
  - Displays comic home data
  - Sections: Recent Manga, Weekly Best, Japanese Manga Best
  - Pull-to-refresh support

- **WebtoonTab** ([lib/features/home/presentation/widgets/webtoon_tab.dart](lib/features/home/presentation/widgets/webtoon_tab.dart))
  - Displays webtoon home data
  - 8 sections with rankings
  - Pull-to-refresh support

- **SectionHeader** ([lib/features/home/presentation/widgets/section_header.dart](lib/features/home/presentation/widgets/section_header.dart))
  - Reusable section header with optional "더 보기" button
  - Handles text overflow gracefully

- **EpisodeCard** ([lib/features/home/presentation/widgets/episode_card.dart](lib/features/home/presentation/widgets/episode_card.dart))
  - Displays episode/manga with thumbnail
  - Supports tap navigation
  - Cached network images with placeholder/error states

- **RankedListItem** ([lib/features/home/presentation/widgets/ranked_list_item.dart](lib/features/home/presentation/widgets/ranked_list_item.dart))
  - Displays ranked items in list format
  - Shows ranking number, title, and optional metadata
  - Supports tap navigation

## Key Technical Solutions

### 1. HTML Parsing
Successfully parsed HTML from the legacy site with flexible selectors to handle variations:

#### Recent Manga Section
```dart
// Flexible selector to handle with/without <b> tag
final nameElement = row.querySelector('div.in-subject b') ??
    row.querySelector('div.in-subject');
final name = nameElement?.text.trim() ?? '';
```

#### Weekly Ranking Section
```dart
// Extract name from <a> tag and remove rank prefix
String name = link.text.trim();
final rankSpan = link.querySelector('span.rank-icon');
if (rankSpan != null) {
  final rankText = rankSpan.text.trim();
  if (name.startsWith(rankText)) {
    name = name.substring(rankText.length).trim();
  }
}
```

### 2. Image URL Normalization
Implemented host normalization to ensure images load through the configured baseURL:

```dart
String? _normalizeImageUrl(String? imageUrl, String baseUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return null;

  try {
    // Handle relative URLs
    if (imageUrl.startsWith('/')) {
      return baseUrl + imageUrl;
    }

    // Replace host for external URLs
    final imageUri = Uri.parse(imageUrl);
    final baseUri = Uri.parse(baseUrl);

    if (imageUri.host != baseUri.host) {
      final normalizedUri = imageUri.replace(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.port,
      );
      return normalizedUri.toString();
    }

    return imageUrl;
  } catch (e) {
    return imageUrl;
  }
}
```

### 3. BLoC State Management
Fixed provider error by storing bloc reference before using it:

```dart
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HomeBloc? _homeBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && _homeBloc != null) {
      if (_tabController.index == 0) {
        _homeBloc!.add(const HomeComicDataRequested());
      } else {
        _homeBloc!.add(const HomeWebtoonDataRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _homeBloc = sl<HomeBloc>()..add(const HomeComicDataRequested());
        return _homeBloc!;
      },
      child: Scaffold(...),
    );
  }
}
```

### 4. UI Overflow Prevention
Added Expanded widget to prevent text overflow in headers:

```dart
Row(
  children: [
    Expanded(
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
    if (onMoreTap != null)
      TextButton(
        onPressed: onMoreTap,
        child: const Text('더 보기'),
      ),
  ],
)
```

## Testing Results

### Comic Tab
- ✅ **Recent Manga**: Successfully parsed 12 items
- ✅ **Ranking Titles**: Successfully parsed 18 items
- ✅ **Weekly Ranking**: Successfully parsed 30 items
- ✅ **Thumbnail URLs**: Correctly normalized to use baseURL host
- ✅ **Pull-to-refresh**: Working correctly
- ✅ **Image loading**: Cached with placeholder/error states

### Webtoon Tab
- ✅ **8 Sections**: Successfully parsed all sections
- ✅ **Pull-to-refresh**: Working correctly
- ✅ **Section rendering**: All rankings displayed correctly

## Issues Resolved

### Issue 1: Provider Not Found Error
**Problem**: `ProviderNotFoundException` when accessing HomeBloc in initState
**Solution**: Stored bloc reference during BlocProvider.create() before using it
**File**: [lib/features/home/presentation/pages/home_page.dart:35-42](lib/features/home/presentation/pages/home_page.dart#L35-L42)

### Issue 2: Recent Manga Parsing Returned 0 Items
**Problem**: HTML selector didn't match actual structure
**Solution**: Changed to flexible selector with fallback
**File**: [lib/features/home/data/datasources/home_remote_datasource.dart:118-120](lib/features/home/data/datasources/home_remote_datasource.dart#L118-L120)

### Issue 3: Ranking Titles Parsing Returned 0 Items
**Problem**: Some titles had `<b>` tag, others didn't
**Solution**: Made selector flexible with fallback option
**File**: [lib/features/home/data/datasources/home_remote_datasource.dart:172-174](lib/features/home/data/datasources/home_remote_datasource.dart#L172-L174)

### Issue 4: External Image URLs
**Problem**: Thumbnails used external CDN domain
**Solution**: Implemented URL normalization to replace host with baseURL
**File**: [lib/features/home/data/datasources/home_remote_datasource.dart:25-53](lib/features/home/data/datasources/home_remote_datasource.dart#L25-L53)

### Issue 5: UI Overflow in Headers
**Problem**: Long titles caused overflow
**Solution**: Wrapped Text in Expanded with ellipsis
**File**: [lib/features/home/presentation/widgets/section_header.dart:20-26](lib/features/home/presentation/widgets/section_header.dart#L20-L26)

### Issue 6: Weekly Ranking Titles Showing "+숫자" Instead of Episode Names
**Problem**: Weekly ranking titles displayed only "+46" format instead of episode names
**Root Cause**: Previous solution only removed rank prefix but didn't handle nested span elements properly. The HTML structure had:
- `<span class="pull-right"><span class="count">+46</span></span>` (right-aligned counter)
- `<span class="rank-icon">1</span>` (rank number)
- Direct text node with episode name

**Final Solution**: Clone link element and remove ALL span elements before extracting text
**File**: [lib/features/home/data/datasources/home_remote_datasource.dart:243-250](lib/features/home/data/datasources/home_remote_datasource.dart#L243-L250)
**Result**: ✅ Weekly ranking now displays correct episode names like "이러는 게 좋아 53-4화"

## Files Created

### Domain Layer (7 files)
- lib/features/home/domain/entities/base_mode.dart
- lib/features/home/domain/entities/manga_title.dart
- lib/features/home/domain/entities/episode.dart
- lib/features/home/domain/entities/ranked_item.dart
- lib/features/home/domain/entities/ranking_section.dart
- lib/features/home/domain/entities/comic_home_data.dart
- lib/features/home/domain/entities/webtoon_home_data.dart
- lib/features/home/domain/repositories/home_repository.dart
- lib/features/home/domain/usecases/fetch_comic_home_data.dart
- lib/features/home/domain/usecases/fetch_webtoon_home_data.dart

### Data Layer (8 files)
- lib/features/home/data/models/manga_title_model.dart
- lib/features/home/data/models/manga_title_model.g.dart
- lib/features/home/data/models/episode_model.dart
- lib/features/home/data/models/episode_model.g.dart
- lib/features/home/data/models/ranked_item_model.dart
- lib/features/home/data/models/ranked_item_model.g.dart
- lib/features/home/data/models/ranking_section_model.dart
- lib/features/home/data/models/ranking_section_model.g.dart
- lib/features/home/data/models/comic_home_data_model.dart
- lib/features/home/data/models/comic_home_data_model.g.dart
- lib/features/home/data/models/webtoon_home_data_model.dart
- lib/features/home/data/models/webtoon_home_data_model.g.dart
- lib/features/home/data/datasources/home_remote_datasource.dart
- lib/features/home/data/repositories/home_repository_impl.dart

### Presentation Layer (10 files)
- lib/features/home/presentation/bloc/home_event.dart
- lib/features/home/presentation/bloc/home_state.dart
- lib/features/home/presentation/bloc/home_bloc.dart
- lib/features/home/presentation/pages/home_page.dart
- lib/features/home/presentation/widgets/comic_tab.dart
- lib/features/home/presentation/widgets/webtoon_tab.dart
- lib/features/home/presentation/widgets/section_header.dart
- lib/features/home/presentation/widgets/episode_card.dart
- lib/features/home/presentation/widgets/ranked_list_item.dart
- lib/features/home/presentation/widgets/image_with_placeholder.dart

### Documentation (2 files)
- HOME_SCREEN_ANALYSIS.md
- HOME_SCREEN_ARCHITECTURE.md

## Code Quality
- ✅ All print statements removed
- ✅ Proper error handling with try-catch
- ✅ Clean Architecture maintained
- ✅ Dependency injection with Injectable/GetIt
- ✅ Immutable state with Equatable
- ✅ JSON serialization with json_serializable
- ✅ No linter warnings

## Next Steps

### Pending Features
1. **Navigation**
   - Implement title detail page
   - Implement episode viewer page
   - Add navigation from home screen items

2. **Additional Sections**
   - Implement bookmark section
   - Implement history/continue reading section

3. **Search**
   - Implement search functionality
   - Add search tab or button

4. **Filters**
   - Add genre filters
   - Add sorting options

5. **Performance**
   - Implement pagination for large lists
   - Add list virtualization if needed

6. **Testing**
   - Add unit tests for BLoC
   - Add widget tests for UI components
   - Add integration tests

## Dependencies Used
- flutter_bloc: State management
- equatable: Value equality
- injectable/get_it: Dependency injection
- dio: HTTP client
- html: HTML parsing
- cached_network_image: Image caching
- dartz: Functional programming (Either type)

## Conclusion
The Home Screen feature has been successfully implemented with full Comic and Webtoon tab functionality. All three comic sections and all eight webtoon sections are parsing correctly, with proper error handling, state management, and UI components in place. The implementation follows Clean Architecture principles and is ready for integration with navigation and additional features.
