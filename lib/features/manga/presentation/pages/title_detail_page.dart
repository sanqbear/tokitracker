import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/presentation/bloc/title_detail_bloc.dart';
import 'package:tokitracker/features/manga/presentation/bloc/title_detail_event.dart';
import 'package:tokitracker/features/manga/presentation/bloc/title_detail_state.dart';
import 'package:tokitracker/features/manga/presentation/widgets/title_detail_header.dart';
import 'package:tokitracker/features/manga/presentation/widgets/episode_list_item.dart';
import 'package:tokitracker/injection_container.dart';

class TitleDetailPage extends StatelessWidget {
  final int titleId;
  final BaseMode baseMode;

  const TitleDetailPage({
    super.key,
    required this.titleId,
    required this.baseMode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TitleDetailBloc>()
        ..add(TitleDetailFetchRequested(
          titleId: titleId,
          baseMode: baseMode,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('상세 정보'),
          actions: [
            BlocBuilder<TitleDetailBloc, TitleDetailState>(
              builder: (context, state) {
                if (state is TitleDetailLoaded) {
                  return IconButton(
                    icon: Icon(
                      state.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: state.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      context
                          .read<TitleDetailBloc>()
                          .add(const TitleDetailFavoriteToggled());
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<TitleDetailBloc, TitleDetailState>(
          builder: (context, state) {
            if (state is TitleDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is TitleDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<TitleDetailBloc>()
                            .add(const TitleDetailRefreshRequested());
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              );
            } else if (state is TitleDetailCaptchaRequired) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      '캡차 인증이 필요합니다',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // Navigate to captcha page
                        final result = await context.push<bool>(
                          '/captcha?url=${Uri.encodeComponent(state.url)}',
                        );

                        // If captcha succeeded, retry loading
                        if (result == true && context.mounted) {
                          context
                              .read<TitleDetailBloc>()
                              .add(const TitleDetailRefreshRequested());
                        }
                      },
                      child: const Text('캡차 인증하기'),
                    ),
                  ],
                ),
              );
            } else if (state is TitleDetailLoaded) {
              final titleDetail = state.titleDetail;
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<TitleDetailBloc>()
                      .add(const TitleDetailRefreshRequested());
                },
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: TitleDetailHeader(
                        titleDetail: titleDetail,
                        onBookmarkTap: () {
                          context
                              .read<TitleDetailBloc>()
                              .add(const TitleDetailBookmarkToggled());
                        },
                        onFirstEpisodeTap: () {
                          if (titleDetail.episodes.isNotEmpty) {
                            final firstEpisode =
                                titleDetail.episodes.last; // Reversed order
                            // TODO: Navigate to viewer
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('첫화: ${firstEpisode.name}'),
                              ),
                            );
                          }
                        },
                        onAuthorTap: () {
                          // TODO: Navigate to author search
                          if (titleDetail.author != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('작가: ${titleDetail.author}'),
                              ),
                            );
                          }
                        },
                        onTagTap: (tag) {
                          // TODO: Navigate to tag search
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('태그: $tag'),
                            ),
                          );
                        },
                      ),
                    ),
                    // Episodes list
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final episode = titleDetail.episodes[index];
                            return EpisodeListItem(
                              episode: episode,
                              onTap: () {
                                // TODO: Navigate to viewer
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('에피소드: ${episode.name}'),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: titleDetail.episodes.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
