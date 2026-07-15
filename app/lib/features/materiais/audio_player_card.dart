import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

/// Player de áudio (M4A) com play/pause e barra de posição, via media_kit.
class AudioPlayerCard extends StatefulWidget {
  final String titulo;
  final String path;
  const AudioPlayerCard({super.key, required this.titulo, required this.path});

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  Player? _player;
  bool _existe = true;
  bool _tocando = false;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  final _subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    _existe = File(widget.path).existsSync();
    if (!_existe) return;
    final p = Player();
    _player = p;
    p.open(Media(widget.path), play: false);
    _subs.add(p.stream.playing.listen((v) {
      if (mounted) setState(() => _tocando = v);
    }));
    _subs.add(p.stream.position.listen((v) {
      if (mounted) setState(() => _pos = v);
    }));
    _subs.add(p.stream.duration.listen((v) {
      if (mounted) setState(() => _dur = v);
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    if (!_existe) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: Text(widget.titulo),
          subtitle: const Text('Arquivo não encontrado'),
        ),
      );
    }
    final maxMs = _dur.inMilliseconds.toDouble();
    final posMs = _pos.inMilliseconds.clamp(0, _dur.inMilliseconds).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton.filled(
              onPressed: () => _player?.playOrPause(),
              icon: Icon(_tocando ? Icons.pause : Icons.play_arrow),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.titulo,
                      style: Theme.of(context).textTheme.bodyMedium),
                  Slider(
                    value: maxMs <= 0 ? 0 : posMs,
                    max: maxMs <= 0 ? 1 : maxMs,
                    onChanged: (v) =>
                        _player?.seek(Duration(milliseconds: v.round())),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text('${_fmt(_pos)} / ${_fmt(_dur)}',
                        style:
                            TextStyle(color: s.onSurfaceVariant, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
