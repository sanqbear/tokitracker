# Home Screen Architecture - Flutter Implementation

This document outlines the Flutter architecture for implementing the home screen feature based on the legacy Android app analysis.

## Architecture Overview

Following the existing Clean Architecture pattern used in the authentication feature:

```
lib/features/home/
├── domain/
│   ├── entities/
│   │   ├── base_mode.dart
│   │   ├── manga_title.dart
│   │   ├── episode.dart
│   │   ├── ranked_item.dart
│   │   ├── ranking_section.dart
│   │   ├── comic_home_data.dart
│   │   └── webtoon_home_data.dart
│   ├── repositories/
│   │   └── home_repository.dart
│   └── usecases/
│       ├── fetch_comic_home_data.dart
│       └── fetch_webtoon_home_data.dart
├── data/
│   ├── models/
│   │   ├── manga_title_model.dart
│   │   ├── episode_model.dart
│   │   ├── ranked_item_model.dart
│   │   ├── ranking_section_model.dart
│   │   ├── comic_home_data_model.dart
│   │   └── webtoon_home_data_model.dart
│   ├── datasources/
│   │   └── home_remote_datasource.dart
│   └── repositories/
│       └── home_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── home_bloc.dart
    │   ├── home_event.dart
    │   └── home_state.dart
    ├── pages/
    │   └── home_page.dart
    └── widgets/
        ├── comic_tab.dart
        ├── webtoon_tab.dart
        ├── section_header.dart
        ├── manga_card.dart
        ├── episode_card.dart
        └── ranked_list_item.dart
```

---

## Domain Layer

### Entities

#### 1. BaseMode (enum)
```dart
enum BaseMode {
  auto,
  comic,
  webtoon;

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
}
```

#### 2. MangaTitle
```dart
class MangaTitle {
  final int id;
  final String name;
  final String? thumbnailUrl;
  final String? author;
  final List<String> tags;
  final String? release;
  final BaseMode baseMode;

  const MangaTitle({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.author,
    this.tags = const [],
    this.release,
    required this.baseMode,
  });

  String getUrl() => '/${baseMode.toUrlPath()}/$id';
}
```

#### 3. Episode
```dart
class Episode {
  final int id;
  final String name;
  final String? date;
  final String? thumbnailUrl;
  final BaseMode baseMode;

  const Episode({
    required this.id,
    required this.name,
    this.date,
    this.thumbnailUrl,
    required this.baseMode,
  });

  String getUrl() => '/${baseMode.toUrlPath()}/$id';
}
```

#### 4. RankedItem&lt;T&gt;
```dart
class RankedItem<T> {
  final T item;
  final int ranking;

  const RankedItem({
    required this.item,
    required this.ranking,
  });
}
```

#### 5. RankingSection&lt;T&gt;
```dart
class RankingSection<T> {
  final String name;
  final List<RankedItem<T>> items;

  const RankingSection({
    required this.name,
    required this.items,
  });
}
```

#### 6. ComicHomeData
```dart
class ComicHomeData {
  final List<Episode> recentManga;
  final List<RankedItem<MangaTitle>> rankingTitles;
  final List<RankedItem<Episode>> weeklyRanking;

  const ComicHomeData({
    required this.recentManga,
    required this.rankingTitles,
    required this.weeklyRanking,
  });
}
```

#### 7. WebtoonHomeData
```dart
class WebtoonHomeData {
  final List<RankingSection<MangaTitle>> sections;

  const WebtoonHomeData({
    required this.sections,
  });

  // Helper getters for specific sections
  RankingSection<MangaTitle>? get normalNew =>
      sections.isNotEmpty ? sections[0] : null;
  RankingSection<MangaTitle>? get adultNew =>
      sections.length > 1 ? sections[1] : null;
  RankingSection<MangaTitle>? get gayNew =>
      sections.length > 2 ? sections[2] : null;
  RankingSection<MangaTitle>? get comicNew =>
      sections.length > 3 ? sections[3] : null;
  RankingSection<MangaTitle>? get normalBest =>
      sections.length > 4 ? sections[4] : null;
  RankingSection<MangaTitle>? get adultBest =>
      sections.length > 5 ? sections[5] : null;
  RankingSection<MangaTitle>? get gayBest =>
      sections.length > 6 ? sections[6] : null;
  RankingSection<MangaTitle>? get comicBest =>
      sections.length > 7 ? sections[7] : null;
}
```

### Repository Interface

```dart
abstract class HomeRepository {
  /// Fetch comic home page data
  Future<Either<Failure, ComicHomeData>> fetchComicHomeData();

  /// Fetch webtoon home page data
  Future<Either<Failure, WebtoonHomeData>> fetchWebtoonHomeData();
}
```

### Use Cases

#### FetchComicHomeData
```dart
@injectable
class FetchComicHomeData {
  final HomeRepository repository;

  FetchComicHomeData(this.repository);

  Future<Either<Failure, ComicHomeData>> call() async {
    return await repository.fetchComicHomeData();
  }
}
```

#### FetchWebtoonHomeData
```dart
@injectable
class FetchWebtoonHomeData {
  final HomeRepository repository;

  FetchWebtoonHomeData(this.repository);

  Future<Either<Failure, WebtoonHomeData>> call() async {
    return await repository.fetchWebtoonHomeData();
  }
}
```

---

## Data Layer

### Models

All models extend their corresponding entities and add `fromJson`/`toJson` methods.

#### MangaTitleModel
```dart
@JsonSerializable()
class MangaTitleModel extends MangaTitle {
  const MangaTitleModel({
    required super.id,
    required super.name,
    super.thumbnailUrl,
    super.author,
    super.tags = const [],
    super.release,
    required super.baseMode,
  });

  factory MangaTitleModel.fromJson(Map<String, dynamic> json) =>
      _$MangaTitleModelFromJson(json);

  Map<String, dynamic> toJson() => _$MangaTitleModelToJson(this);

  factory MangaTitleModel.fromEntity(MangaTitle entity) {
    return MangaTitleModel(
      id: entity.id,
      name: entity.name,
      thumbnailUrl: entity.thumbnailUrl,
      author: entity.author,
      tags: entity.tags,
      release: entity.release,
      baseMode: entity.baseMode,
    );
  }
}
```

Similar patterns for:
- `EpisodeModel`
- `RankedItemModel<T>`
- `RankingSectionModel<T>`
- `ComicHomeDataModel`
- `WebtoonHomeDataModel`

### Data Source

#### HomeRemoteDataSource
```dart
@injectable
class HomeRemoteDataSource {
  final HttpClient httpClient;
  final LocalStorage localStorage;

  HomeRemoteDataSource(this.httpClient, this.localStorage);

  /// Fetch comic home page data
  Future<ComicHomeDataModel> fetchComicHome() async {
    final baseUrl = localStorage.getBaseUrl();
    if (baseUrl == null || baseUrl.isEmpty) {
      throw ServerException('Base URL not configured');
    }

    final response = await httpClient.get('$baseUrl/');
    final document = parse(response.data);

    // Parse recent manga
    final recentManga = _parseRecentManga(document);

    // Parse ranking titles
    final rankingTitles = _parseRankingTitles(document);

    // Parse weekly ranking
    final weeklyRanking = _parseWeeklyRanking(document);

    return ComicHomeDataModel(
      recentManga: recentManga,
      rankingTitles: rankingTitles,
      weeklyRanking: weeklyRanking,
    );
  }

  List<EpisodeModel> _parseRecentManga(Document document) {
    final recentList = <EpisodeModel>[];

    try {
      final gallery = document.querySelector('div.miso-post-gallery');
      if (gallery == null) return recentList;

      final postRows = gallery.querySelectorAll('div.post-row');

      for (final row in postRows) {
        try {
          final link = row.querySelector('a');
          if (link == null) continue;

          final href = link.attributes['href'] ?? '';
          final idMatch = RegExp(r'comic/(\d+)').firstMatch(href);
          if (idMatch == null) continue;
          final id = int.parse(idMatch.group(1)!);

          final nameElement = row.querySelector('div.post-subject');
          final name = nameElement?.text.trim() ?? '';

          final imgElement = row.querySelector('img');
          final thumb = imgElement?.attributes['data-src'];

          final dateElement = row.querySelector('div.post-date');
          final date = dateElement?.text.trim();

          recentList.add(EpisodeModel(
            id: id,
            name: name,
            date: date,
            thumbnailUrl: thumb,
            baseMode: BaseMode.comic,
          ));
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
    } catch (e) {
      throw ServerException('Failed to parse recent manga: $e');
    }

    return recentList;
  }

  List<RankedItemModel<MangaTitleModel>> _parseRankingTitles(Document document) {
    final rankingList = <RankedItemModel<MangaTitleModel>>[];

    try {
      final galleries = document.querySelectorAll('div.miso-post-gallery');
      if (galleries.isEmpty) return rankingList;

      final lastGallery = galleries.last;
      final postRows = lastGallery.querySelectorAll('div.post-row');

      int ranking = 1;
      for (final row in postRows) {
        try {
          final link = row.querySelector('a');
          if (link == null) continue;

          final href = link.attributes['href'] ?? '';
          final idMatch = RegExp(r'comic/(\d+)').firstMatch(href);
          if (idMatch == null) continue;
          final id = int.parse(idMatch.group(1)!);

          final nameElement = row.querySelector('div.post-subject');
          final name = nameElement?.text.trim() ?? '';

          final imgElement = row.querySelector('img');
          final thumb = imgElement?.attributes['data-src'];

          final title = MangaTitleModel(
            id: id,
            name: name,
            thumbnailUrl: thumb,
            baseMode: BaseMode.comic,
          );

          rankingList.add(RankedItemModel(
            item: title,
            ranking: ranking++,
          ));
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      throw ServerException('Failed to parse ranking titles: $e');
    }

    return rankingList;
  }

  List<RankedItemModel<EpisodeModel>> _parseWeeklyRanking(Document document) {
    final weeklyList = <RankedItemModel<EpisodeModel>>[];

    try {
      final lists = document.querySelectorAll('div.miso-post-list');
      if (lists.isEmpty) return weeklyList;

      final lastList = lists.last;
      final postRows = lastList.querySelectorAll('li.post-row');

      int ranking = 1;
      for (final row in postRows) {
        try {
          final link = row.querySelector('a');
          if (link == null) continue;

          final href = link.attributes['href'] ?? '';
          final idMatch = RegExp(r'comic/(\d+)').firstMatch(href);
          if (idMatch == null) continue;
          final id = int.parse(idMatch.group(1)!);

          final nameElement = row.querySelector('a.item-subject');
          final name = nameElement?.text.trim() ?? '';

          final dateElement = row.querySelector('span.item-date');
          final date = dateElement?.text.trim();

          final episode = EpisodeModel(
            id: id,
            name: name,
            date: date,
            baseMode: BaseMode.comic,
          );

          weeklyList.add(RankedItemModel(
            item: episode,
            ranking: ranking++,
          ));
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      throw ServerException('Failed to parse weekly ranking: $e');
    }

    return weeklyList;
  }

  /// Fetch webtoon home page data
  Future<WebtoonHomeDataModel> fetchWebtoonHome() async {
    final baseUrl = localStorage.getBaseUrl();
    if (baseUrl == null || baseUrl.isEmpty) {
      throw ServerException('Base URL not configured');
    }

    // First, get the webtoon site URL via redirect
    final redirectResponse = await httpClient.get(
      '$baseUrl/site.php?id=1',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    String webtoonUrl;
    if (redirectResponse.statusCode == 302) {
      webtoonUrl = redirectResponse.headers.value('location') ?? '';
      if (webtoonUrl.isEmpty) {
        throw ServerException('Failed to get webtoon site URL');
      }
    } else {
      throw ServerException('Expected redirect to webtoon site');
    }

    // Fetch webtoon home page
    final response = await httpClient.get(webtoonUrl);
    final document = parse(response.data);

    // Parse 8 sections
    final sections = _parseWebtoonSections(document);

    return WebtoonHomeDataModel(sections: sections);
  }

  List<RankingSectionModel<MangaTitleModel>> _parseWebtoonSections(Document document) {
    final sections = <RankingSectionModel<MangaTitleModel>>[];

    try {
      final boxes = document.querySelectorAll('div.main-box');

      if (boxes.length < 12) {
        throw ServerException('Unexpected page structure');
      }

      // Section names (from MainPageWebtoon.java)
      final sectionNames = [
        '일반연재 최신',    // boxes[4]
        '성인웹툰 최신',    // boxes[5]
        'BL/GL 최신',      // boxes[6]
        '일본만화 최신',    // boxes[7]
        '일반연재 베스트',  // boxes[8]
        '성인웹툰 베스트',  // boxes[9]
        'BL/GL 베스트',    // boxes[10]
        '일본만화 베스트',  // boxes[11]
      ];

      final baseModes = [
        BaseMode.webtoon,  // 일반연재
        BaseMode.webtoon,  // 성인웹툰
        BaseMode.webtoon,  // BL/GL
        BaseMode.comic,    // 일본만화
        BaseMode.webtoon,  // 일반연재 베스트
        BaseMode.webtoon,  // 성인웹툰 베스트
        BaseMode.webtoon,  // BL/GL 베스트
        BaseMode.comic,    // 일본만화 베스트
      ];

      for (int i = 0; i < 8; i++) {
        final boxIndex = i + 4; // Start from boxes[4]
        final box = boxes[boxIndex];
        final links = box.querySelectorAll('a');
        final items = <RankedItemModel<MangaTitleModel>>[];

        int ranking = 1;
        for (final link in links) {
          try {
            final href = link.attributes['href'] ?? '';
            final idMatch = RegExp(r'=(\d+)$').firstMatch(href);
            if (idMatch == null) continue;
            final id = int.parse(idMatch.group(1)!);

            final subjectDiv = link.querySelector('div.in-subject');
            final name = (subjectDiv?.text ?? link.text).trim();

            final title = MangaTitleModel(
              id: id,
              name: name,
              baseMode: baseModes[i],
            );

            items.add(RankedItemModel(
              item: title,
              ranking: ranking++,
            ));
          } catch (e) {
            continue;
          }
        }

        sections.add(RankingSectionModel(
          name: sectionNames[i],
          items: items,
        ));
      }
    } catch (e) {
      throw ServerException('Failed to parse webtoon sections: $e');
    }

    return sections;
  }
}
```

### Repository Implementation

```dart
@Injectable(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ComicHomeData>> fetchComicHomeData() async {
    try {
      final data = await remoteDataSource.fetchComicHome();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, WebtoonHomeData>> fetchWebtoonHomeData() async {
    try {
      final data = await remoteDataSource.fetchWebtoonHome();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
```

---

## Presentation Layer

### BLoC

#### Events
```dart
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeComicDataRequested extends HomeEvent {
  const HomeComicDataRequested();
}

class HomeWebtoonDataRequested extends HomeEvent {
  const HomeWebtoonDataRequested();
}

class HomeRefreshRequested extends HomeEvent {
  final int currentTabIndex; // 0=comic, 1=webtoon

  const HomeRefreshRequested(this.currentTabIndex);

  @override
  List<Object?> get props => [currentTabIndex];
}
```

#### States
```dart
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeComicLoading extends HomeState {
  const HomeComicLoading();
}

class HomeComicLoaded extends HomeState {
  final ComicHomeData data;

  const HomeComicLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class HomeComicError extends HomeState {
  final String message;

  const HomeComicError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeWebtoonLoading extends HomeState {
  const HomeWebtoonLoading();
}

class HomeWebtoonLoaded extends HomeState {
  final WebtoonHomeData data;

  const HomeWebtoonLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class HomeWebtoonError extends HomeState {
  final String message;

  const HomeWebtoonError(this.message);

  @override
  List<Object?> get props => [message];
}
```

#### BLoC
```dart
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchComicHomeData fetchComicHomeData;
  final FetchWebtoonHomeData fetchWebtoonHomeData;

  HomeBloc(
    this.fetchComicHomeData,
    this.fetchWebtoonHomeData,
  ) : super(const HomeInitial()) {
    on<HomeComicDataRequested>(_onComicDataRequested);
    on<HomeWebtoonDataRequested>(_onWebtoonDataRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onComicDataRequested(
    HomeComicDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeComicLoading());

    final result = await fetchComicHomeData();

    result.fold(
      (failure) => emit(HomeComicError(failure.message)),
      (data) => emit(HomeComicLoaded(data)),
    );
  }

  Future<void> _onWebtoonDataRequested(
    HomeWebtoonDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeWebtoonLoading());

    final result = await fetchWebtoonHomeData();

    result.fold(
      (failure) => emit(HomeWebtoonError(failure.message)),
      (data) => emit(HomeWebtoonLoaded(data)),
    );
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (event.currentTabIndex == 0) {
      add(const HomeComicDataRequested());
    } else {
      add(const HomeWebtoonDataRequested());
    }
  }
}
```

### Pages

#### HomePage
```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeBloc>()..add(const HomeComicDataRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TokiTracker'),
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) {
              final bloc = context.read<HomeBloc>();
              if (index == 0) {
                bloc.add(const HomeComicDataRequested());
              } else {
                bloc.add(const HomeWebtoonDataRequested());
              }
            },
            tabs: const [
              Tab(text: '만화'),
              Tab(text: '웹툰'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ComicTab(),
            WebtoonTab(),
          ],
        ),
      ),
    );
  }
}
```

### Widgets

#### ComicTab
```dart
class ComicTab extends StatelessWidget {
  const ComicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeComicLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeComicError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<HomeBloc>().add(const HomeComicDataRequested());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        if (state is HomeComicLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshRequested(0));
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Manga Section
                  SectionHeader(
                    title: '최근 추가된 만화',
                    onMoreTap: () {
                      // TODO: Navigate to more updated list
                    },
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.data.recentManga.length,
                      itemBuilder: (context, index) {
                        return EpisodeCard(
                          episode: state.data.recentManga[index],
                        );
                      },
                    ),
                  ),

                  // Weekly Best Section
                  const SectionHeader(title: '주간 베스트'),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.data.weeklyRanking.length,
                    itemBuilder: (context, index) {
                      final rankedItem = state.data.weeklyRanking[index];
                      return RankedListItem(
                        ranking: rankedItem.ranking,
                        title: rankedItem.item.name,
                        subtitle: rankedItem.item.date,
                        onTap: () {
                          // TODO: Navigate to episode
                        },
                      );
                    },
                  ),

                  // Japanese Manga Best Section
                  const SectionHeader(title: '일본만화 베스트'),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.data.rankingTitles.length,
                    itemBuilder: (context, index) {
                      final rankedItem = state.data.rankingTitles[index];
                      return RankedListItem(
                        ranking: rankedItem.ranking,
                        title: rankedItem.item.name,
                        subtitle: rankedItem.item.author,
                        thumbnailUrl: rankedItem.item.thumbnailUrl,
                        onTap: () {
                          // TODO: Navigate to title
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
```

#### WebtoonTab
```dart
class WebtoonTab extends StatelessWidget {
  const WebtoonTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeWebtoonLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeWebtoonError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<HomeBloc>().add(const HomeWebtoonDataRequested());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        if (state is HomeWebtoonLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshRequested(1));
            },
            child: ListView.builder(
              itemCount: state.data.sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = state.data.sections[sectionIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: section.name),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: section.items.length,
                      itemBuilder: (context, itemIndex) {
                        final rankedItem = section.items[itemIndex];
                        return RankedListItem(
                          ranking: rankedItem.ranking,
                          title: rankedItem.item.name,
                          onTap: () {
                            // TODO: Navigate to title
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
```

---

## Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  html: ^0.15.4  # HTML parsing (instead of JSoup)
```

---

## Implementation Steps

1. ✅ Complete analysis
2. ✅ Design architecture
3. ⏭️ Create domain entities
4. ⏭️ Create repository interfaces
5. ⏭️ Create use cases
6. ⏭️ Create data models with json_serializable
7. ⏭️ Implement HomeRemoteDataSource (HTML parsing)
8. ⏭️ Implement HomeRepositoryImpl
9. ⏭️ Register dependencies in DI
10. ⏭️ Implement BLoC (events, states, logic)
11. ⏭️ Create UI widgets (SectionHeader, MangaCard, etc.)
12. ⏭️ Implement ComicTab and WebtoonTab
13. ⏭️ Implement HomePage
14. ⏭️ Update app_router to route to HomePage
15. ⏭️ Test and debug

---

## Notes

- HTML parsing uses `html` package (Dart equivalent of JSoup)
- Error handling follows existing pattern with Failure classes
- Loading states use CircularProgressIndicator
- Pull-to-refresh supported with RefreshIndicator
- Navigation placeholders use TODO comments
- Thumbnail loading should use cached_network_image
- Consider adding shimmer loading states for better UX
