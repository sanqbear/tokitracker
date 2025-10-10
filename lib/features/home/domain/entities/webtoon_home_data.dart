import 'package:equatable/equatable.dart';
import 'manga_title.dart';
import 'ranking_section.dart';

/// Data structure for webtoon home page
/// Corresponds to MainPageWebtoon class in legacy Android app
class WebtoonHomeData extends Equatable {
  /// List of 8 ranking sections
  /// 0: 일반연재 최신
  /// 1: 성인웹툰 최신
  /// 2: BL/GL 최신
  /// 3: 일본만화 최신
  /// 4: 일반연재 베스트
  /// 5: 성인웹툰 베스트
  /// 6: BL/GL 베스트
  /// 7: 일본만화 베스트
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

  @override
  List<Object?> get props => [sections];
}
