import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Artwork extends StatelessWidget {
  final String url;
  final double? size;
  final double radius;

  const Artwork({super.key, required this.url, this.size, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.white70),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 250),
              placeholder: (_, __) => Container(
                width: size,
                height: size,
                color: Colors.white10,
              ),
              errorWidget: (_, __, ___) => placeholder,
            ),
    );
  }
}
