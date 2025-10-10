import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'episode_card.dart';
import 'ranked_list_item.dart';
import 'section_header.dart';

class ComicTab extends StatelessWidget {
  const ComicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeComicLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeComicError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<HomeBloc>().add(const HomeComicDataRequested());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        if (state is HomeComicLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshRequested(0));
              // Wait a bit for the bloc to process
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Manga Section
                  SectionHeader(
                    title: '최근 추가된 만화',
                    onMoreTap: () {
                      // TODO: Navigate to more updated list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('준비 중입니다')),
                      );
                    },
                  ),
                  if (state.data.recentManga.isNotEmpty)
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: state.data.recentManga.length,
                        itemBuilder: (context, index) {
                          final episode = state.data.recentManga[index];
                          return EpisodeCard(
                            episode: episode,
                            onTap: () {
                              // Navigate to title detail page
                              context.go('/comic/${episode.id}');
                            },
                          );
                        },
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('데이터가 없습니다'),
                    ),

                  const SizedBox(height: 16),

                  // Weekly Best Section
                  const SectionHeader(title: '주간 베스트'),
                  if (state.data.weeklyRanking.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.data.weeklyRanking.length,
                      itemBuilder: (context, index) {
                        final rankedItem = state.data.weeklyRanking[index];
                        return RankedListItem(
                          ranking: rankedItem.ranking,
                          title: rankedItem.item.name,
                          subtitle: rankedItem.item.date,
                          onTap: () {
                            // Navigate to title detail page
                            context.go('/comic/${rankedItem.item.id}');
                          },
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('데이터가 없습니다'),
                    ),

                  const SizedBox(height: 16),

                  // Japanese Manga Best Section
                  const SectionHeader(title: '일본만화 베스트'),
                  if (state.data.rankingTitles.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.data.rankingTitles.length,
                      itemBuilder: (context, index) {
                        final rankedItem = state.data.rankingTitles[index];
                        return RankedListItem(
                          ranking: rankedItem.ranking,
                          title: rankedItem.item.name,
                          subtitle: rankedItem.item.author,
                          thumbnailUrl: rankedItem.item.thumbnailUrl,
                          onTap: () {
                            // Navigate to title detail page
                            context.go('/comic/${rankedItem.item.id}');
                          },
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('데이터가 없습니다'),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
