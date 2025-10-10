# Title Detail Screen - Flutter Architecture Design

## Overview
Flutter architecture design for the title detail screen (EpisodeActivity equivalent) following Clean Architecture and BLoC pattern as defined in PROJECT.md.

## Feature Location
According to PROJECT.md structure:
```
lib/features/manga/
├── data/
├── domain/
└── presentation/
```

**Note**: The title detail screen is part of the `manga` feature in PROJECT.md architecture.

## Architecture Layers

### 1. Domain Layer

#### Entities

**lib/features/manga/domain/entities/title_detail.dart**
```dart
import 'package:equatable/equatable.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/entities/episode.dart';

class TitleDetail extends Equatable {
  final int id;
  final String name;
  final String? thumbnailUrl;
  final String? author;
  final List<String> tags;
  final String? release;
  final BaseMode baseMode;
  final List<Episode> episodes;
  final int recommendCount;
  final bool isBookmarked;
  final String? bookmarkLink;

  const TitleDetail({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.author,
    this.tags = const [],
    this.release,
    required this.baseMode,
    this.episodes = const [],
    this.recommendCount = 0,
    this.isBookmarked = false,
    this.bookmarkLink,
  });

  String getUrl() => '/${baseMode.toUrlPath()}/$id';

  @override
  List<Object?> get props => [
        id,
        name,
        thumbnailUrl,
        author,
        tags,
        release,
        baseMode,
        episodes,
        recommendCount,
        isBookmarked,
        bookmarkLink,
      ];
}
```

**lib/features/manga/domain/entities/episode.dart**
```dart
import 'package:equatable/equatable.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';

class Episode extends Equatable {
  final int id;
  final String name;
  final String? date;
  final BaseMode baseMode;
  final String? offlinePath; // For offline mode support

  const Episode({
    required this.id,
    required this.name,
    this.date,
    required this.baseMode,
    this.offlinePath,
  });

  String getUrl() => '/${baseMode.toUrlPath()}/$id';

  bool get isOffline => offlinePath != null && offlinePath!.isNotEmpty;

  @override
  List<Object?> get props => [id, name, date, baseMode, offlinePath];
}
```

#### Repository Interface

**lib/features/manga/domain/repositories/manga_repository.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';

abstract class MangaRepository {
  /// Fetch title detail with episodes
  Future<Either<Failure, TitleDetail>> fetchTitleDetail({
    required int id,
    required BaseMode baseMode,
  });

  /// Toggle server-side bookmark
  Future<Either<Failure, bool>> toggleBookmark({
    required String bookmarkLink,
    required bool currentStatus,
  });

  /// Add title to local favorites
  Future<Either<Failure, void>> addToFavorites(TitleDetail title);

  /// Remove title from local favorites
  Future<Either<Failure, void>> removeFromFavorites(int titleId);

  /// Check if title is in favorites
  Future<Either<Failure, bool>> isFavorite(int titleId);

  /// Add title to recent list
  Future<Either<Failure, void>> addToRecent(TitleDetail title);
}
```

#### Use Cases

**lib/features/manga/domain/usecases/fetch_title_detail.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@injectable
class FetchTitleDetail {
  final MangaRepository repository;

  FetchTitleDetail(this.repository);

  Future<Either<Failure, TitleDetail>> call({
    required int id,
    required BaseMode baseMode,
  }) async {
    return await repository.fetchTitleDetail(
      id: id,
      baseMode: baseMode,
    );
  }
}
```

**lib/features/manga/domain/usecases/toggle_bookmark.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@injectable
class ToggleBookmark {
  final MangaRepository repository;

  ToggleBookmark(this.repository);

  Future<Either<Failure, bool>> call({
    required String bookmarkLink,
    required bool currentStatus,
  }) async {
    return await repository.toggleBookmark(
      bookmarkLink: bookmarkLink,
      currentStatus: currentStatus,
    );
  }
}
```

**lib/features/manga/domain/usecases/toggle_favorite.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@injectable
class ToggleFavorite {
  final MangaRepository repository;

  ToggleFavorite(this.repository);

  Future<Either<Failure, bool>> call({
    required TitleDetail title,
    required bool currentStatus,
  }) async {
    if (currentStatus) {
      final result = await repository.removeFromFavorites(title.id);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(false),
      );
    } else {
      final result = await repository.addToFavorites(title);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(true),
      );
    }
  }
}
```

**lib/features/manga/domain/usecases/add_to_recent.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@injectable
class AddToRecent {
  final MangaRepository repository;

  AddToRecent(this.repository);

  Future<Either<Failure, void>> call(TitleDetail title) async {
    return await repository.addToRecent(title);
  }
}
```

### 2. Data Layer

#### Models

**lib/features/manga/data/models/title_detail_model.dart**
```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/data/models/episode_model.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';

part 'title_detail_model.g.dart';

@JsonSerializable()
class TitleDetailModel extends TitleDetail {
  const TitleDetailModel({
    required super.id,
    required super.name,
    super.thumbnailUrl,
    super.author,
    super.tags,
    super.release,
    required super.baseMode,
    super.episodes,
    super.recommendCount,
    super.isBookmarked,
    super.bookmarkLink,
  });

  factory TitleDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TitleDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$TitleDetailModelToJson(this);

  factory TitleDetailModel.fromEntity(TitleDetail entity) {
    return TitleDetailModel(
      id: entity.id,
      name: entity.name,
      thumbnailUrl: entity.thumbnailUrl,
      author: entity.author,
      tags: entity.tags,
      release: entity.release,
      baseMode: entity.baseMode,
      episodes: entity.episodes
          .map((e) => EpisodeModel.fromEntity(e))
          .toList(),
      recommendCount: entity.recommendCount,
      isBookmarked: entity.isBookmarked,
      bookmarkLink: entity.bookmarkLink,
    );
  }
}
```

**lib/features/manga/data/models/episode_model.dart**
```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/entities/episode.dart';

part 'episode_model.g.dart';

@JsonSerializable()
class EpisodeModel extends Episode {
  const EpisodeModel({
    required super.id,
    required super.name,
    super.date,
    required super.baseMode,
    super.offlinePath,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) =>
      _$EpisodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeModelToJson(this);

  factory EpisodeModel.fromEntity(Episode entity) {
    return EpisodeModel(
      id: entity.id,
      name: entity.name,
      date: entity.date,
      baseMode: entity.baseMode,
      offlinePath: entity.offlinePath,
    );
  }
}
```

#### Data Sources

**lib/features/manga/data/datasources/manga_remote_datasource.dart**
```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:tokitracker/core/error/exceptions.dart';
import 'package:tokitracker/core/network/http_client.dart';
import 'package:tokitracker/core/storage/local_storage.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/data/models/episode_model.dart';
import 'package:tokitracker/features/manga/data/models/title_detail_model.dart';

@injectable
class MangaRemoteDataSource {
  final HttpClient httpClient;
  final LocalStorage localStorage;

  MangaRemoteDataSource(this.httpClient, this.localStorage);

  /// Fetch title detail from server
  Future<TitleDetailModel> fetchTitleDetail({
    required int id,
    required BaseMode baseMode,
  }) async {
    final baseUrl = localStorage.getBaseUrl();
    if (baseUrl == null || baseUrl.isEmpty) {
      throw ServerException('Base URL not configured');
    }

    try {
      final url = '$baseUrl/${baseMode.toUrlPath()}/$id';
      final response = await httpClient.get(url);

      // Check for captcha redirect
      if (response.statusCode == 302) {
        final location = response.headers.value('location') ?? '';
        if (location.contains('captcha.php')) {
          throw CaptchaRequiredException('Captcha required');
        }
      }

      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch title detail');
      }

      final document = html_parser.parse(response.data);

      // Parse title details
      return _parseTitleDetail(document, id, baseMode, baseUrl);
    } on DioException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch title detail: $e');
    }
  }

  /// Parse title detail from HTML document
  TitleDetailModel _parseTitleDetail(
    Document document,
    int id,
    BaseMode baseMode,
    String baseUrl,
  ) {
    try {
      // Header section
      final header = document.querySelector('div.view-title');
      if (header == null) {
        throw ServerException('Invalid HTML structure: view-title not found');
      }

      // Thumbnail
      String? thumbnailUrl;
      try {
        final imgElement = header.querySelector('div.view-img')?.querySelector('img');
        thumbnailUrl = imgElement?.attributes['src'];
        thumbnailUrl = _normalizeImageUrl(thumbnailUrl, baseUrl);
      } catch (e) {
        // Thumbnail optional
      }

      // Title name
      String name = '';
      try {
        final infos = header.querySelectorAll('div.view-content');
        if (infos.length > 1) {
          name = infos[1].querySelector('b')?.text.trim() ?? '';
        }
      } catch (e) {
        // Will use default empty string
      }

      // Extra info (recommend count, bookmark)
      int recommendCount = 0;
      bool isBookmarked = false;
      String? bookmarkLink;

      try {
        final infoTable = document.querySelector('table.table');
        if (infoTable != null) {
          // Recommend count
          try {
            final recommendBtn = infoTable.querySelector('button.btn-red');
            final recommendText = recommendBtn?.querySelector('b')?.text.trim() ?? '0';
            recommendCount = int.tryParse(recommendText) ?? 0;
          } catch (e) {
            // Optional
          }

          // Bookmark
          try {
            final bookmarkElement = infoTable.querySelector('a#webtoon_bookmark');
            if (bookmarkElement != null) {
              isBookmarked = bookmarkElement.classes.contains('btn-orangered');
              bookmarkLink = bookmarkElement.attributes['href'];
            }
          } catch (e) {
            // Optional (not logged in)
          }
        }
      } catch (e) {
        // Extra info optional
      }

      // Author, tags, release
      String? author;
      List<String> tags = [];
      String? release;

      try {
        final infos = header.querySelectorAll('div.view-content');
        for (final info in infos.skip(1)) {
          try {
            final typeElement = info.querySelector('strong');
            final type = typeElement?.text.trim() ?? '';

            switch (type) {
              case '작가':
                author = info.querySelector('a')?.text.trim();
                break;
              case '분류':
                final tagElements = info.querySelectorAll('a');
                tags = tagElements.map((e) => e.text.trim()).toList();
                break;
              case '발행구분':
                release = info.querySelector('a')?.text.trim();
                break;
            }
          } catch (e) {
            continue;
          }
        }
      } catch (e) {
        // Metadata optional
      }

      // Episodes
      final episodes = _parseEpisodes(document, baseMode);

      return TitleDetailModel(
        id: id,
        name: name,
        thumbnailUrl: thumbnailUrl,
        author: author,
        tags: tags,
        release: release,
        baseMode: baseMode,
        episodes: episodes,
        recommendCount: recommendCount,
        isBookmarked: isBookmarked,
        bookmarkLink: bookmarkLink,
      );
    } catch (e) {
      throw ServerException('Failed to parse title detail: $e');
    }
  }

  /// Parse episodes from HTML document
  List<EpisodeModel> _parseEpisodes(Document document, BaseMode baseMode) {
    final episodes = <EpisodeModel>[];

    try {
      final listBody = document.querySelector('ul.list-body');
      if (listBody == null) {
        return episodes;
      }

      final items = listBody.querySelectorAll('li.list-item');

      for (final item in items) {
        try {
          final link = item.querySelector('a.item-subject');
          if (link == null) continue;

          final href = link.attributes['href'] ?? '';
          final idMatch = RegExp(r'${baseMode.toUrlPath()}/(\d+)').firstMatch(href);
          if (idMatch == null) continue;

          final episodeId = int.parse(idMatch.group(1)!);
          final episodeName = link.text.trim();

          String? date;
          try {
            final details = item.querySelector('div.item-details');
            final spans = details?.querySelectorAll('span');
            if (spans != null && spans.isNotEmpty) {
              date = spans.first.text.trim();
            }
          } catch (e) {
            // Date optional
          }

          episodes.add(EpisodeModel(
            id: episodeId,
            name: episodeName,
            date: date,
            baseMode: baseMode,
          ));
        } catch (e) {
          // Skip invalid episode
          continue;
        }
      }
    } catch (e) {
      // Return empty list on error
    }

    return episodes;
  }

  /// Normalize image URL to use baseURL host
  String? _normalizeImageUrl(String? imageUrl, String baseUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    try {
      if (imageUrl.startsWith('/')) {
        return baseUrl + imageUrl;
      }

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

  /// Toggle bookmark on server
  Future<bool> toggleBookmark({
    required String bookmarkLink,
    required bool currentStatus,
    required String cookie,
  }) async {
    try {
      final response = await httpClient.post(
        bookmarkLink,
        data: {
          'mode': currentStatus ? 'off' : 'on',
          'top': '0',
          'js': 'on',
        },
        options: Options(
          headers: {
            'Cookie': cookie,
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to toggle bookmark');
      }

      // Parse JSON response
      final data = response.data as Map<String, dynamic>;
      final error = data['error'] as String?;
      final success = data['success'] as String?;

      if ((error == null || error.isEmpty) &&
          (success != null && success.isNotEmpty)) {
        return true;
      }

      return false;
    } on DioException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to toggle bookmark: $e');
    }
  }
}
```

**lib/features/manga/data/datasources/manga_local_datasource.dart**
```dart
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/storage/local_storage.dart';
import 'package:tokitracker/features/manga/data/models/title_detail_model.dart';

@injectable
class MangaLocalDataSource {
  final LocalStorage localStorage;

  MangaLocalDataSource(this.localStorage);

  /// Add to favorites
  Future<void> addToFavorites(TitleDetailModel title) async {
    final favorites = await getFavorites();
    if (!favorites.any((t) => t.id == title.id)) {
      favorites.add(title);
      await _saveFavorites(favorites);
    }
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(int titleId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((t) => t.id == titleId);
    await _saveFavorites(favorites);
  }

  /// Check if favorite
  Future<bool> isFavorite(int titleId) async {
    final favorites = await getFavorites();
    return favorites.any((t) => t.id == titleId);
  }

  /// Get all favorites
  Future<List<TitleDetailModel>> getFavorites() async {
    // Implementation using Hive or SharedPreferences
    // For now, return empty list
    return [];
  }

  /// Save favorites
  Future<void> _saveFavorites(List<TitleDetailModel> favorites) async {
    // Implementation using Hive or SharedPreferences
  }

  /// Add to recent
  Future<void> addToRecent(TitleDetailModel title) async {
    final recent = await getRecent();
    // Remove if already exists
    recent.removeWhere((t) => t.id == title.id);
    // Add to beginning
    recent.insert(0, title);
    // Keep only last 50
    if (recent.length > 50) {
      recent.removeRange(50, recent.length);
    }
    await _saveRecent(recent);
  }

  /// Get recent
  Future<List<TitleDetailModel>> getRecent() async {
    // Implementation using Hive or SharedPreferences
    return [];
  }

  /// Save recent
  Future<void> _saveRecent(List<TitleDetailModel> recent) async {
    // Implementation using Hive or SharedPreferences
  }
}
```

#### Repository Implementation

**lib/features/manga/data/repositories/manga_repository_impl.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/exceptions.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/core/storage/local_storage.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/data/datasources/manga_local_datasource.dart';
import 'package:tokitracker/features/manga/data/datasources/manga_remote_datasource.dart';
import 'package:tokitracker/features/manga/data/models/title_detail_model.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';

@Injectable(as: MangaRepository)
class MangaRepositoryImpl implements MangaRepository {
  final MangaRemoteDataSource remoteDataSource;
  final MangaLocalDataSource localDataSource;
  final LocalStorage localStorage;

  MangaRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.localStorage,
  );

  @override
  Future<Either<Failure, TitleDetail>> fetchTitleDetail({
    required int id,
    required BaseMode baseMode,
  }) async {
    try {
      final titleDetail = await remoteDataSource.fetchTitleDetail(
        id: id,
        baseMode: baseMode,
      );
      return Right(titleDetail);
    } on CaptchaRequiredException catch (e) {
      return Left(CaptchaFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleBookmark({
    required String bookmarkLink,
    required bool currentStatus,
  }) async {
    try {
      final user = localStorage.getUser();
      if (user == null || !user.isValid) {
        return const Left(AuthFailure('Login required'));
      }

      final success = await remoteDataSource.toggleBookmark(
        bookmarkLink: bookmarkLink,
        currentStatus: currentStatus,
        cookie: user.cookie,
      );

      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(TitleDetail title) async {
    try {
      final model = TitleDetailModel.fromEntity(title);
      await localDataSource.addToFavorites(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add to favorites: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int titleId) async {
    try {
      await localDataSource.removeFromFavorites(titleId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to remove from favorites: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int titleId) async {
    try {
      final isFav = await localDataSource.isFavorite(titleId);
      return Right(isFav);
    } catch (e) {
      return Left(CacheFailure('Failed to check favorite: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToRecent(TitleDetail title) async {
    try {
      final model = TitleDetailModel.fromEntity(title);
      await localDataSource.addToRecent(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add to recent: $e'));
    }
  }
}
```

### 3. Presentation Layer

#### BLoC

**lib/features/manga/presentation/bloc/title_detail_event.dart**
```dart
import 'package:equatable/equatable.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';

sealed class TitleDetailEvent extends Equatable {
  const TitleDetailEvent();

  @override
  List<Object?> get props => [];
}

class TitleDetailFetchRequested extends TitleDetailEvent {
  final int titleId;
  final BaseMode baseMode;

  const TitleDetailFetchRequested({
    required this.titleId,
    required this.baseMode,
  });

  @override
  List<Object?> get props => [titleId, baseMode];
}

class TitleDetailRefreshRequested extends TitleDetailEvent {
  const TitleDetailRefreshRequested();
}

class TitleDetailFavoriteToggled extends TitleDetailEvent {
  const TitleDetailFavoriteToggled();
}

class TitleDetailBookmarkToggled extends TitleDetailEvent {
  const TitleDetailBookmarkToggled();
}
```

**lib/features/manga/presentation/bloc/title_detail_state.dart**
```dart
import 'package:equatable/equatable.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';

sealed class TitleDetailState extends Equatable {
  const TitleDetailState();

  @override
  List<Object?> get props => [];
}

class TitleDetailInitial extends TitleDetailState {
  const TitleDetailInitial();
}

class TitleDetailLoading extends TitleDetailState {
  const TitleDetailLoading();
}

class TitleDetailLoaded extends TitleDetailState {
  final TitleDetail titleDetail;
  final bool isFavorite;
  final int? bookmarkedEpisodeId;

  const TitleDetailLoaded({
    required this.titleDetail,
    this.isFavorite = false,
    this.bookmarkedEpisodeId,
  });

  TitleDetailLoaded copyWith({
    TitleDetail? titleDetail,
    bool? isFavorite,
    int? bookmarkedEpisodeId,
  }) {
    return TitleDetailLoaded(
      titleDetail: titleDetail ?? this.titleDetail,
      isFavorite: isFavorite ?? this.isFavorite,
      bookmarkedEpisodeId: bookmarkedEpisodeId ?? this.bookmarkedEpisodeId,
    );
  }

  @override
  List<Object?> get props => [titleDetail, isFavorite, bookmarkedEpisodeId];
}

class TitleDetailError extends TitleDetailState {
  final String message;

  const TitleDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class TitleDetailCaptchaRequired extends TitleDetailState {
  final String url;

  const TitleDetailCaptchaRequired(this.url);

  @override
  List<Object?> get props => [url];
}
```

**lib/features/manga/presentation/bloc/title_detail_bloc.dart**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tokitracker/core/error/failures.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/usecases/add_to_recent.dart';
import 'package:tokitracker/features/manga/domain/usecases/fetch_title_detail.dart';
import 'package:tokitracker/features/manga/domain/usecases/toggle_bookmark.dart';
import 'package:tokitracker/features/manga/domain/usecases/toggle_favorite.dart';
import 'package:tokitracker/features/manga/domain/repositories/manga_repository.dart';
import 'package:tokitracker/features/manga/presentation/bloc/title_detail_event.dart';
import 'package:tokitracker/features/manga/presentation/bloc/title_detail_state.dart';

@injectable
class TitleDetailBloc extends Bloc<TitleDetailEvent, TitleDetailState> {
  final FetchTitleDetail fetchTitleDetail;
  final ToggleBookmark toggleBookmark;
  final ToggleFavorite toggleFavorite;
  final AddToRecent addToRecent;
  final MangaRepository repository;

  int? _currentTitleId;
  BaseMode? _currentBaseMode;

  TitleDetailBloc(
    this.fetchTitleDetail,
    this.toggleBookmark,
    this.toggleFavorite,
    this.addToRecent,
    this.repository,
  ) : super(const TitleDetailInitial()) {
    on<TitleDetailFetchRequested>(_onFetchRequested);
    on<TitleDetailRefreshRequested>(_onRefreshRequested);
    on<TitleDetailFavoriteToggled>(_onFavoriteToggled);
    on<TitleDetailBookmarkToggled>(_onBookmarkToggled);
  }

  Future<void> _onFetchRequested(
    TitleDetailFetchRequested event,
    Emitter<TitleDetailState> emit,
  ) async {
    _currentTitleId = event.titleId;
    _currentBaseMode = event.baseMode;

    emit(const TitleDetailLoading());

    final result = await fetchTitleDetail(
      id: event.titleId,
      baseMode: event.baseMode,
    );

    await result.fold(
      (failure) async {
        if (failure is CaptchaFailure) {
          emit(TitleDetailCaptchaRequired(failure.message));
        } else {
          emit(TitleDetailError(_mapFailureToMessage(failure)));
        }
      },
      (titleDetail) async {
        // Check if favorite
        final isFavResult = await repository.isFavorite(titleDetail.id);
        final isFavorite = isFavResult.getOrElse(() => false);

        // Add to recent
        await addToRecent(titleDetail);

        emit(TitleDetailLoaded(
          titleDetail: titleDetail,
          isFavorite: isFavorite,
        ));
      },
    );
  }

  Future<void> _onRefreshRequested(
    TitleDetailRefreshRequested event,
    Emitter<TitleDetailState> emit,
  ) async {
    if (_currentTitleId == null || _currentBaseMode == null) return;

    add(TitleDetailFetchRequested(
      titleId: _currentTitleId!,
      baseMode: _currentBaseMode!,
    ));
  }

  Future<void> _onFavoriteToggled(
    TitleDetailFavoriteToggled event,
    Emitter<TitleDetailState> emit,
  ) async {
    if (state is! TitleDetailLoaded) return;

    final currentState = state as TitleDetailLoaded;

    final result = await toggleFavorite(
      title: currentState.titleDetail,
      currentStatus: currentState.isFavorite,
    );

    result.fold(
      (failure) {
        // Show error message but don't change state
      },
      (newStatus) {
        emit(currentState.copyWith(isFavorite: newStatus));
      },
    );
  }

  Future<void> _onBookmarkToggled(
    TitleDetailBookmarkToggled event,
    Emitter<TitleDetailState> emit,
  ) async {
    if (state is! TitleDetailLoaded) return;

    final currentState = state as TitleDetailLoaded;
    final bookmarkLink = currentState.titleDetail.bookmarkLink;

    if (bookmarkLink == null || bookmarkLink.isEmpty) {
      return;
    }

    final result = await toggleBookmark(
      bookmarkLink: bookmarkLink,
      currentStatus: currentState.titleDetail.isBookmarked,
    );

    result.fold(
      (failure) {
        // Show error message
        if (failure is AuthFailure) {
          // Show login dialog
        }
      },
      (success) {
        if (success) {
          // Update bookmark status
          // For now, trigger refresh
          add(const TitleDetailRefreshRequested());
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return '네트워크 오류가 발생했습니다.';
    } else if (failure is CaptchaFailure) {
      return '캡차 인증이 필요합니다.';
    } else {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }
}
```

## Navigation Integration

### Update Router

**lib/config/routes/app_router.dart**
```dart
import 'package:go_router/go_router.dart';
import 'package:tokitracker/features/home/presentation/pages/home_page.dart';
import 'package:tokitracker/features/manga/presentation/pages/title_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/title/:baseMode/:id',
      builder: (context, state) {
        final baseMode = state.pathParameters['baseMode']!;
        final id = int.parse(state.pathParameters['id']!);
        return TitleDetailPage(
          titleId: id,
          baseMode: baseMode == 'comic' ? BaseMode.comic : BaseMode.webtoon,
        );
      },
    ),
  ],
);
```

### Navigation from Home Screen

Update home screen widgets to navigate to title detail:

```dart
// In EpisodeCard or RankedListItem
onTap: () {
  context.go('/title/${episode.baseMode.toUrlPath()}/${episode.id}');
}
```

## Dependency Injection

Register all dependencies in `lib/core/injection/injection_container.dart`:

```dart
@module
abstract class MangaModule {
  // Already registered by @injectable annotations
  // MangaRemoteDataSource
  // MangaLocalDataSource
  // MangaRepositoryImpl
  // FetchTitleDetail
  // ToggleBookmark
  // ToggleFavorite
  // AddToRecent
  // TitleDetailBloc
}
```

## Summary

### Files to Create

**Domain Layer (5 files)**:
1. `lib/features/manga/domain/entities/title_detail.dart`
2. `lib/features/manga/domain/entities/episode.dart`
3. `lib/features/manga/domain/repositories/manga_repository.dart`
4. `lib/features/manga/domain/usecases/fetch_title_detail.dart`
5. `lib/features/manga/domain/usecases/toggle_bookmark.dart`
6. `lib/features/manga/domain/usecases/toggle_favorite.dart`
7. `lib/features/manga/domain/usecases/add_to_recent.dart`

**Data Layer (5 files)**:
1. `lib/features/manga/data/models/title_detail_model.dart`
2. `lib/features/manga/data/models/episode_model.dart`
3. `lib/features/manga/data/datasources/manga_remote_datasource.dart`
4. `lib/features/manga/data/datasources/manga_local_datasource.dart`
5. `lib/features/manga/data/repositories/manga_repository_impl.dart`

**Presentation Layer (4 files + UI)**:
1. `lib/features/manga/presentation/bloc/title_detail_event.dart`
2. `lib/features/manga/presentation/bloc/title_detail_state.dart`
3. `lib/features/manga/presentation/bloc/title_detail_bloc.dart`
4. `lib/features/manga/presentation/pages/title_detail_page.dart` (next phase)
5. `lib/features/manga/presentation/widgets/` (next phase)

### Next Steps

1. ✅ Domain layer implementation
2. ✅ Data layer implementation
3. ✅ Presentation layer (BLoC)
4. ⏳ Presentation layer (UI - Page & Widgets)
5. ⏳ Navigation integration
6. ⏳ Testing

### Implementation Notes

1. **Reuse Home Feature Entities**: `BaseMode` already exists in home feature
2. **Episode Entity**: Can be shared between home and manga features
3. **Error Handling**: Use Dartz's `Either<Failure, T>` pattern
4. **Captcha Detection**: Check for 302 redirect to captcha.php
5. **Bookmark**: Requires login validation
6. **Favorite**: Local storage only, no server sync
7. **Recent**: Local storage with 50 item limit

This architecture follows PROJECT.md's Clean Architecture principles and integrates seamlessly with the existing home feature implementation.
