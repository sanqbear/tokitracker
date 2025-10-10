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
