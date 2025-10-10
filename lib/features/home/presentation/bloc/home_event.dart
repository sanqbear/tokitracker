import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load comic home data
class HomeComicDataRequested extends HomeEvent {
  const HomeComicDataRequested();
}

/// Request to load webtoon home data
class HomeWebtoonDataRequested extends HomeEvent {
  const HomeWebtoonDataRequested();
}

/// Request to refresh current tab data
class HomeRefreshRequested extends HomeEvent {
  final int currentTabIndex; // 0=comic, 1=webtoon

  const HomeRefreshRequested(this.currentTabIndex);

  @override
  List<Object?> get props => [currentTabIndex];
}
