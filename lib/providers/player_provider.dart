import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/track.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription> _subs = [];

  List<Track> _queue = [];
  int _index = -1;
  bool _playing = false;
  bool _buffering = false;
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  PlayerProvider() {
    _subs.add(_player.playerStateStream.listen((s) {
      _playing = s.playing;
      _buffering = s.processingState == ProcessingState.loading ||
          s.processingState == ProcessingState.buffering;
      if (s.processingState == ProcessingState.completed) {
        if (hasNext) {
          next();
        } else {
          _player.pause();
          _player.seek(Duration.zero);
        }
      }
      notifyListeners();
    }));
    _subs.add(_player.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    }));
    _subs.add(_player.durationStream.listen((d) {
      if (d != null) _duration = d;
      notifyListeners();
    }));
  }

  Track? get current =>
      _index >= 0 && _index < _queue.length ? _queue[_index] : null;
  bool get isPlaying => _playing;
  bool get isBuffering => _buffering;
  String? get error => _error;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasNext => _index >= 0 && _index < _queue.length - 1;
  bool get hasPrevious => _index > 0;

  Future<void> playTrack(List<Track> queue, int index) async {
    _queue = List.of(queue);
    await _load(index);
  }

  Future<void> _load(int index) async {
    _index = index;
    _position = Duration.zero;
    _duration = Duration(seconds: current?.duration ?? 0);
    _error = null;
    notifyListeners();
    try {
      await _player.setUrl(current!.audio);
      _player.play();
    } catch (_) {
      _error = 'Unable to play this track';
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (current == null) return;
    if (_error != null) return _load(_index);
    _player.playing ? await _player.pause() : _player.play();
  }

  Future<void> next() async {
    if (hasNext) await _load(_index + 1);
  }

  Future<void> previous() async {
    // Restart the song if we're past 3s, like most players.
    if (_position.inSeconds > 3 || !hasPrevious) {
      await _player.seek(Duration.zero);
    } else {
      await _load(_index - 1);
    }
  }

  Future<void> seek(Duration d) => _player.seek(d);

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}
