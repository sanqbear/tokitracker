import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'ranked_list_item.dart';
import 'section_header.dart';

class WebtoonTab extends StatelessWidget {
  const WebtoonTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeWebtoonLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeWebtoonError) {
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
                    context.read<HomeBloc>().add(const HomeWebtoonDataRequested());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        if (state is HomeWebtoonLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshRequested(1));
              // Wait a bit for the bloc to process
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: state.data.sections.isEmpty
                ? const Center(
                    child: Text('데이터가 없습니다'),
                  )
                : ListView.builder(
                    itemCount: state.data.sections.length,
                    itemBuilder: (context, sectionIndex) {
                      final section = state.data.sections[sectionIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(title: section.name),
                          if (section.items.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: section.items.length,
                              itemBuilder: (context, itemIndex) {
                                final rankedItem = section.items[itemIndex];
                                return RankedListItem(
                                  ranking: rankedItem.ranking,
                                  title: rankedItem.item.name,
                                  onTap: () {
                                    // TODO: Navigate to title detail
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '작품: ${rankedItem.item.name}',
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('데이터가 없습니다'),
                            ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
