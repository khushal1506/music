import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/track.dart';
import '../services/jamendo_api.dart';

class TracksProvider extends ChangeNotifier {
  TracksProvider({JamendoApi? api}) : _api = api ?? JamendoApi() {
    loadInitial();
  }

  final JamendoApi _api;
  final List<Track> _tracks = [];
  String _query = '';
  int _offset = 0;
  bool _loading = false; // first page
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error; // first page error
  String? _moreError; // pagination error
  int _generation = 0; // invalidates in-flight requests on new search
  Timer? _debounce;

  List<Track> get tracks => List.unmodifiable(_tracks);
  String get query => _query;
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get moreError => _moreError;
  bool get isEmpty => !_loading && _error == null && _tracks.isEmpty;

  Future<void> loadInitial() async {
    final gen = ++_generation;
    _tracks.clear();
    _offset = 0;
    _hasMore = true;
    _error = null;
    _moreError = null;
    _loadingMore = false;
    _loading = true;
    notifyListeners();
    try {
      final page = await _api.fetchTracks(query: _query, offset: 0);
      if (gen != _generation) return;
      _tracks.addAll(page);
      _offset = page.length;
      _hasMore = page.length >= JamendoApi.pageSize;
    } catch (e) {
      if (gen != _generation) return;
      _error = _clean(e);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !_hasMore || _error != null) return;
    final gen = _generation;
    _loadingMore = true;
    _moreError = null;
    notifyListeners();
    try {
      final page = await _api.fetchTracks(query: _query, offset: _offset);
      if (gen != _generation) return;
      final seen = _tracks.map((t) => t.id).toSet();
      _tracks.addAll(page.where((t) => !seen.contains(t.id)));
      _offset += page.length;
      _hasMore = page.length >= JamendoApi.pageSize;
    } catch (e) {
      if (gen != _generation) return;
      _moreError = _clean(e);
    }
    _loadingMore = false;
    notifyListeners();
  }

  void search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (q.trim() == _query) return;
      _query = q.trim();
      loadInitial();
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    if (_query.isEmpty) return;
    _query = '';
    loadInitial();
  }

  String _clean(Object e) {
    final s = e.toString().replaceFirst('Exception: ', '');
    if (s.contains('SocketException') || s.contains('ClientException')) {
      return 'No internet connection';
    }
    if (s.contains('TimeoutException')) return 'Request timed out';
    return s;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
