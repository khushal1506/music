import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../providers/tracks_provider.dart';
import '../widgets/mini_player.dart';
import '../widgets/track_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 400) {
      context.read<TracksProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TracksProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1000 ? 3 : (width >= 640 ? 2 : 1);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A1250), Color(0xFF0B0B14), Color(0xFF0B0B14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                      ),
                      child: const Icon(Icons.graphic_eq_rounded, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('Discover',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: TextField(
                  controller: _search,
                  onChanged: (v) {
                    setState(() {});
                    tp.search(v);
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search songs',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                              tp.clearSearch();
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(child: _body(tp, columns)),
              const MiniPlayer(),
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(TracksProvider tp, int columns) {
    if (tp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tp.error != null) {
      return _Message(
        icon: Icons.wifi_off_rounded,
        title: 'Something went wrong',
        subtitle: tp.error!,
        actionLabel: 'Try again',
        onAction: tp.loadInitial,
      );
    }
    if (tp.isEmpty) {
      return _Message(
        icon: Icons.search_off_rounded,
        title: 'No songs found',
        subtitle: 'Nothing matches "${tp.query}". Try a different search.',
      );
    }

    final player = context.watch<PlayerProvider>();
    final tracks = tp.tracks;
    final footer = tp.isLoadingMore ||
        tp.moreError != null ||
        (!tp.hasMore && tracks.isNotEmpty);

    Widget tile(int i) => TrackTile(
          track: tracks[i],
          isCurrent: player.current?.id == tracks[i].id,
          isPlaying: player.isPlaying,
          onTap: () {
            if (player.current?.id == tracks[i].id) {
              player.togglePlay();
            } else {
              player.playTrack(tracks, i);
            }
          },
        );

    return RefreshIndicator(
      onRefresh: tp.loadInitial,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 78,
                crossAxisSpacing: 8,
                mainAxisSpacing: 4,
              ),
              itemCount: tracks.length,
              itemBuilder: (_, i) => tile(i),
            ),
          ),
          if (footer)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: tp.isLoadingMore
                      ? const CircularProgressIndicator()
                      : tp.moreError != null
                          ? TextButton.icon(
                              onPressed: tp.loadMore,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text('${tp.moreError} — tap to retry'),
                            )
                          : const Text("You've reached the end",
                              style: TextStyle(color: Colors.white38)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60)),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
