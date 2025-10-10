import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../widgets/comic_tab.dart';
import '../widgets/webtoon_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HomeBloc? _homeBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes to load data for each tab
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && _homeBloc != null) {
      // Tab animation finished
      if (_tabController.index == 0) {
        _homeBloc!.add(const HomeComicDataRequested());
      } else {
        _homeBloc!.add(const HomeWebtoonDataRequested());
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _homeBloc = sl<HomeBloc>()..add(const HomeComicDataRequested());
        return _homeBloc!;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TokiTracker'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '만화'),
              Tab(text: '웹툰'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ComicTab(),
            WebtoonTab(),
          ],
        ),
      ),
    );
  }
}
