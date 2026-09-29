class Track {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String image;
  final String audio;
  final int duration;

  const Track({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.image,
    required this.audio,
    required this.duration,
  });

  factory Track.fromJson(Map<String, dynamic> j) => Track(
        id: '${j['id']}',
        name: (j['name'] ?? 'Unknown').toString(),
        artistName: (j['artist_name'] ?? 'Unknown artist').toString(),
        albumName: (j['album_name'] ?? '').toString(),
        image: (j['image'] ?? j['album_image'] ?? '').toString(),
        audio: (j['audio'] ?? '').toString(),
        duration: (j['duration'] as num?)?.toInt() ?? 0,
      );
}
