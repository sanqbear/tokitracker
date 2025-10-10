import 'package:equatable/equatable.dart';
import '../../domain/entities/comic_home_data.dart';
import '../../domain/entities/webtoon_home_data.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Comic data loading
class HomeComicLoading extends HomeState {
  const HomeComicLoading();
}

/// Comic data loaded successfully
class HomeComicLoaded extends HomeState {
  final ComicHomeData data;

  const HomeComicLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Comic data loading failed
class HomeComicError extends HomeState {
  final String message;

  const HomeComicError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Webtoon data loading
class HomeWebtoonLoading extends HomeState {
  const HomeWebtoonLoading();
}

/// Webtoon data loaded successfully
class HomeWebtoonLoaded extends HomeState {
  final WebtoonHomeData data;

  const HomeWebtoonLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Webtoon data loading failed
class HomeWebtoonError extends HomeState {
  final String message;

  const HomeWebtoonError(this.message);

  @override
  List<Object?> get props => [message];
}
