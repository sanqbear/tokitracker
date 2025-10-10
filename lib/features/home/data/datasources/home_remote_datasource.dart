import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/base_mode.dart';
import '../models/comic_home_data_model.dart';
import '../models/episode_model.dart';
import '../models/manga_title_model.dart';
import '../models/ranked_item_model.dart';
import '../models/ranking_section_model.dart';
import '../models/webtoon_home_data_model.dart';

@injectable
class HomeRemoteDataSource {
  final HttpClient httpClient;
  final LocalStorage localStorage;

  HomeRemoteDataSource(this.httpClient, this.localStorage);

  /// Helper method to normalize thumbnail URL to use baseURL's host
  /// Replaces the host of external image URLs with the current baseURL's host
  String? _normalizeImageUrl(String? imageUrl, String baseUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    try {
      // If it's a relative URL, make it absolute
      if (imageUrl.startsWith('/')) {
        return baseUrl + imageUrl;
      }

      // If it's an absolute URL with a different host, replace the host
      final imageUri = Uri.parse(imageUrl);
      final baseUri = Uri.parse(baseUrl);

      // If hosts are different, replace the host
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
      // Return original URL on error
      return imageUrl;
    }
  }

  /// Fetch comic home page data
  /// Parses HTML from {baseUrl}/
  Future<ComicHomeDataModel> fetchComicHome() async {
    final baseUrl = localStorage.getBaseUrl();
    if (baseUrl == null || baseUrl.isEmpty) {
      throw ServerException('Base URL not configured');
    }

    try {
      final response = await httpClient.get('$baseUrl/');
      final document = html_parser.parse(response.data);

      // Parse recent manga
      final recentManga = _parseRecentManga(document, baseUrl);

      // Parse ranking titles
      final rankingTitles = _parseRankingTitles(document, baseUrl);

      // Parse weekly ranking
      final weeklyRanking = _parseWeeklyRanking(document, baseUrl);

      return ComicHomeDataModel(
        recentManga: recentManga,
        rankingTitles: rankingTitles,
        weeklyRanking: weeklyRanking,
      );
    } on DioException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch comic home data: $e');
    }
  }

  /// Parse recent manga from first div.miso-post-gallery
  List<EpisodeModel> _parseRecentManga(Document document, String baseUrl) {
    final recentList = <EpisodeModel>[];

    try {
      final gallery = document.querySelector('div.miso-post-gallery');
      if (gallery == null) {
        return recentList;
      }

      final postRows = gallery.querySelectorAll('div.post-row');

      for (final row in postRows) {
        try {
          final link = row.querySelector('a');
          if (link == null) continue;

          final href = link.attributes['href'] ?? '';
          final idMatch = RegExp(r'comic/(\d+)').firstMatch(href);
          if (idMatch == null) continue;
          final id = int.parse(idMatch.group(1)!);

          // Name is in div.in-subject (with or without <b> tag)
          final nameElement = row.querySelector('div.in-subject b') ??
              row.querySelector('div.in-subject');
          final name = nameElement?.text.trim() ?? '';
          if (name.isEmpty) continue;

          // Thumbnail image
          final imgElement = row.querySelector('img');
          String? thumb = imgElement?.attributes['src'];
          // If src is not available, try data-src
          thumb ??= imgElement?.attributes['data-src'];
          // Normalize URL to use baseURL's host
          thumb = _normalizeImageUrl(thumb, baseUrl);

          // Date might not be available in this structure
          final date = null;

          recentList.add(EpisodeModel(
            id: id,
            name: name,
            date: date,
            thumbnailUrl: thumb,
            baseMode: BaseMode.comic,
          ));
        } catch (e) {
          // Skip invalid rows
          continue;
        }
      }
    } catch (e) {
      // Return empty list on parse error
    }

    return recentList;
  }

  /// Parse ranking titles from last div.miso-post-gallery
  List<RankedItemModel<MangaTitleModel>> _parseRankingTitles(
    Document document,
    String baseUrl,
  ) {
    final rankingList = <RankedItemModel<MangaTitleModel>>[];

    try {
      final galleries = document.querySelectorAll('div.miso-post-gallery');
      if (galleries.isEmpty) {
        return rankingList;
      }

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

          // Name is in div.in-subject (with or without <b> tag)
          final nameElement = row.querySelector('div.in-subject b') ??
              row.querySelector('div.in-subject');
          final name = nameElement?.text.trim() ?? '';
          if (name.isEmpty) continue;

          final imgElement = row.querySelector('img');
          String? thumb = imgElement?.attributes['src'];
          thumb ??= imgElement?.attributes['data-src'];
          // Normalize URL to use baseURL's host
          thumb = _normalizeImageUrl(thumb, baseUrl);

          // Author might not be available in this structure
          final author = null;

          final title = MangaTitleModel(
            id: id,
            name: name,
            thumbnailUrl: thumb,
            author: author,
            baseMode: BaseMode.comic,
          );

          rankingList.add(RankedItemModel(
            item: title,
            ranking: ranking++,
          ));
        } catch (e) {
          // Skip invalid rows
          continue;
        }
      }
    } catch (e) {
      // Return empty list on parse error
    }

    return rankingList;
  }

  /// Parse weekly ranking from last div.miso-post-list
  List<RankedItemModel<EpisodeModel>> _parseWeeklyRanking(
    Document document,
    String baseUrl,
  ) {
    final weeklyList = <RankedItemModel<EpisodeModel>>[];

    try {
      final lists = document.querySelectorAll('div.miso-post-list');
      if (lists.isEmpty) {
        return weeklyList;
      }

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

          // Name extraction: Get text but remove all span elements first
          // The <a> tag contains: <span class="pull-right">...</span><span class="rank-icon">1</span>이러는 게 좋아 53-4화
          // We need to extract only the direct text nodes, excluding all span content

          // Clone the link to avoid modifying the original DOM
          final linkClone = link.clone(true);

          // Remove all span elements
          linkClone.querySelectorAll('span').forEach((span) => span.remove());

          // Now get the text
          String name = linkClone.text.trim();

          if (name.isEmpty) continue;

          // Date might be available
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
          // Skip invalid rows
          continue;
        }
      }
    } catch (e) {
      // Return empty list on parse error
    }

    return weeklyList;
  }

  /// Fetch webtoon home page data
  /// First redirects from /site.php?id=1 to get actual webtoon URL
  Future<WebtoonHomeDataModel> fetchWebtoonHome() async {
    final baseUrl = localStorage.getBaseUrl();
    if (baseUrl == null || baseUrl.isEmpty) {
      throw ServerException('Base URL not configured');
    }

    try {
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
          throw ServerException('Failed to get webtoon site URL from redirect');
        }
      } else {
        throw ServerException(
            'Expected 302 redirect to webtoon site, got ${redirectResponse.statusCode}');
      }

      // Fetch webtoon home page
      final response = await httpClient.get(webtoonUrl);
      final document = html_parser.parse(response.data);

      // Parse 8 sections
      final sections = _parseWebtoonSections(document, webtoonUrl);

      return WebtoonHomeDataModel(sections: sections);
    } on DioException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to fetch webtoon home data: $e');
    }
  }

  /// Parse webtoon sections from div.main-box elements
  List<RankingSectionModel<MangaTitleModel>> _parseWebtoonSections(
    Document document,
    String baseUrl,
  ) {
    final sections = <RankingSectionModel<MangaTitleModel>>[];

    try {
      final boxes = document.querySelectorAll('div.main-box');

      // Section names (from MainPageWebtoon.java)
      final sectionNames = [
        '일반연재 최신', // boxes[4]
        '성인웹툰 최신', // boxes[5]
        'BL/GL 최신', // boxes[6]
        '일본만화 최신', // boxes[7]
        '일반연재 베스트', // boxes[8]
        '성인웹툰 베스트', // boxes[9]
        'BL/GL 베스트', // boxes[10]
        '일본만화 베스트', // boxes[11]
      ];

      final baseModes = [
        BaseMode.webtoon, // 일반연재
        BaseMode.webtoon, // 성인웹툰
        BaseMode.webtoon, // BL/GL
        BaseMode.comic, // 일본만화
        BaseMode.webtoon, // 일반연재 베스트
        BaseMode.webtoon, // 성인웹툰 베스트
        BaseMode.webtoon, // BL/GL 베스트
        BaseMode.comic, // 일본만화 베스트
      ];

      for (int i = 0; i < 8; i++) {
        final boxIndex = i + 4; // Start from boxes[4]
        if (boxIndex >= boxes.length) {
          continue;
        }

        final box = boxes[boxIndex];
        final links = box.querySelectorAll('a');
        final items = <RankedItemModel<MangaTitleModel>>[];

        int ranking = 1;
        for (final link in links) {
          try {
            final href = link.attributes['href'] ?? '';
            // Extract ID from URL parameter (e.g., ?id=123)
            final idMatch = RegExp(r'=(\d+)$').firstMatch(href);
            if (idMatch == null) continue;
            final id = int.parse(idMatch.group(1)!);

            final subjectDiv = link.querySelector('div.in-subject');
            final name = (subjectDiv?.text ?? link.text).trim();
            if (name.isEmpty) continue;

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
            // Skip invalid links
            continue;
          }
        }

        sections.add(RankingSectionModel(
          name: sectionNames[i],
          items: items,
        ));
      }
    } catch (e) {
      // Return empty list on parse error
    }

    return sections;
  }
}
