import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/fetch_comic_home_data.dart';
import '../../domain/usecases/fetch_webtoon_home_data.dart';
import 'home_event.dart';
import 'home_state.dart';

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
