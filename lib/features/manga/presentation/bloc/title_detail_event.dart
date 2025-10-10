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
