import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../screens/now_playing_screen.dart';
import 'artwork.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final track = p.current;
    if (track == null) return const SizedBox.shrink();
    final total = p.duration.inMilliseconds;
    final progress =
        total > 0 ? (p.position.inMilliseconds / total).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => const NowPlayingScreen(),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic))
                .animate(anim),
            child: child,
          ),
        )),
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) < -200) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const NowPlayingScreen(), fullscreenDialog: true));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B1E6E), Color(0xFF5B2A86)],
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 6, 6),
                child: Row(
                  children: [
                    Hero(
                      tag: 'artwork',
                      child: Artwork(url: track.image, size: 48, radius: 12),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          Text(
                              p.error ?? track.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: p.error != null
                                      ? Colors.redAccent
                                      : Colors.white60,
                                  fontSize: 12.5)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: p.hasPrevious ? p.previous : null,
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    p.isBuffering
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5)),
                          )
                        : IconButton(
                            onPressed: p.togglePlay,
                            iconSize: 34,
                            icon: Icon(p.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded),
                          ),
                    IconButton(
                      onPressed: p.hasNext ? p.next : null,
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFFF472B6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
