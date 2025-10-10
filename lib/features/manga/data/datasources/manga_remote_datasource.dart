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
          throw CaptchaRequiredException(location);
        }
      }

      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch title detail');
      }

      final document = html_parser.parse(response.data);

      // Parse title details
      return _parseTitleDetail(document, id, baseMode, baseUrl);
    } on DioException catch (e) {
      // Check if the error is a CaptchaRequiredException
      if (e.error is CaptchaRequiredException) {
        throw e.error as CaptchaRequiredException;
      }
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is CaptchaRequiredException) rethrow;
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
          // Extract ID from URL like /comic/12345 or /webtoon/67890
          final pathSegments = href.split('/');
          if (pathSegments.length < 2) continue;

          final idStr = pathSegments.last;
          final episodeId = int.tryParse(idStr);
          if (episodeId == null) continue;
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
      // Check if the error is a CaptchaRequiredException
      if (e.error is CaptchaRequiredException) {
        throw e.error as CaptchaRequiredException;
      }
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is CaptchaRequiredException) rethrow;
      throw ServerException('Failed to toggle bookmark: $e');
    }
  }
}
