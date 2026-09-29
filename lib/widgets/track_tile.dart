import 'package:flutter/material.dart';

import '../models/track.dart';
import 'artwork.dart';

String formatDuration(Duration d) {
  final m = d.inMinutes;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class TrackTile extends StatelessWidget {
  final Track track;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const TrackTile({
    super.key,
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFF472B6);
    return Material(
      color: isCurrent ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Artwork(url: track.image, size: 60),
                  if (isCurrent)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isPlaying ? Icons.equalizer_rounded : Icons.pause_rounded,
                        color: accent,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCurrent ? accent : Colors.white,
                        )),
                    const SizedBox(height: 3),
                    Text(track.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(formatDuration(Duration(seconds: track.duration)),
                  style: const TextStyle(color: Colors.white38, fontSize: 12.5)),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
