import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/track.dart';
import 'package:music_app/repository/music_repo.dart';

class MusicProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Tracks? _track;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  Tracks? get track => _track;
  PlayerState get playerState => _playerState;
  Duration get duration => _duration;
  Duration get position => _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playerCompleteSubscription;

  MusicProvider() {
    _playerCompleteSubscription = _player.onPlayerComplete.listen((event) {
      _playerState = PlayerState.completed;
      _position = Duration.zero;
      notifyListeners();
    });

    _positionSubscription = _player.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _durationSubscription = _player.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    _playerStateSubscription = _player.onPlayerStateChanged.listen((s) {
      _playerState = s;
      notifyListeners();
    });
  }

  Future<void> play(Tracks track) async {
    if (_track?.id == track.id) {
      if (_playerState == PlayerState.playing) {
        await pause();
      } else {
        await resume();
      }
    } else {
      _track = track;
      final previewUrl = await MusicRepo.getSpotifyPreviewUrl(track.id ?? "");
      if (previewUrl?.isNotEmpty ?? false) {
        await _player.play(UrlSource(previewUrl ?? 'https://foo.com/bar.mp3'));
        _playerState = PlayerState.playing;
      }
    }
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    _playerState = PlayerState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.resume();
    _playerState = PlayerState.playing;
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _playerState = PlayerState.stopped;
    _track = null;
    _position = Duration.zero;
    notifyListeners();
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}
