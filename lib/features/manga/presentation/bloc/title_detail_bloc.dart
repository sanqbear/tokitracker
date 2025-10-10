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
          emit(TitleDetailCaptchaRequired(failure.captchaUrl ?? ''));
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
        // Could emit a snackbar event here
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
        if (failure is AuthenticationFailure) {
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
