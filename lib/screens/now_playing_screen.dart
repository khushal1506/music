import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../widgets/artwork.dart';
import '../widgets/track_tile.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final track = p.current;
    if (track == null) {
      // Nothing to show (shouldn't normally happen) – close.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold();
    }

    final wide = MediaQuery.sizeOf(context).width >= 720;
    final art = LayoutBuilder(builder: (context, c) {
      final side = (c.biggest.shortestSide).clamp(0.0, 420.0);
      return Center(
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Hero(
            tag: 'artwork',
            child: Artwork(url: track.image, size: side, radius: 28),
          ),
        ),
      );
    });

    final controls = _Controls(p: p);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF1B1035), Color(0xFF0B0B14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 34),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text('NOW PLAYING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 2,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70)),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: art),
                            const SizedBox(width: 48),
                            Expanded(child: Center(child: controls)),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(child: art),
                            const SizedBox(height: 24),
                            controls,
                            const SizedBox(height: 12),
                          ],
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

class _Controls extends StatefulWidget {
  final PlayerProvider p;
  const _Controls({required this.p});

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  double? _drag; // ms while user drags the slider

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final track = p.current!;
    final total = p.duration.inMilliseconds.toDouble();
    final pos = (_drag ?? p.position.inMilliseconds.toDouble())
        .clamp(0.0, total > 0 ? total : 1.0);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(track.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(p.error ?? track.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  color: p.error != null ? Colors.redAccent : Colors.white60)),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: const Color(0xFFF472B6),
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: const Color(0x33F472B6),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              min: 0,
              max: total > 0 ? total : 1,
              value: pos,
              onChanged: total > 0 ? (v) => setState(() => _drag = v) : null,
              onChangeEnd: (v) {
                p.seek(Duration(milliseconds: v.round()));
                setState(() => _drag = null);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(Duration(milliseconds: pos.round())),
                    style: const TextStyle(color: Colors.white60)),
                Text(formatDuration(p.duration),
                    style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 44,
                onPressed: p.hasPrevious || p.position.inSeconds > 3
                    ? p.previous
                    : null,
                icon: const Icon(Icons.skip_previous_rounded),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                ),
                child: p.isBuffering
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.white),
                      )
                    : IconButton(
                        iconSize: 44,
                        onPressed: p.togglePlay,
                        icon: Icon(p.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                      ),
              ),
              IconButton(
                iconSize: 44,
                onPressed: p.hasNext ? p.next : null,
                icon: const Icon(Icons.skip_next_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
