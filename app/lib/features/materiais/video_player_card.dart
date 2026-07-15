import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Player de vídeo embutido (MP4) usando media_kit. Controles inclusos.
class VideoPlayerCard extends StatefulWidget {
  final String path;
  const VideoPlayerCard({super.key, required this.path});

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  Player? _player;
  VideoController? _controller;
  bool _existe = true;

  @override
  void initState() {
    super.initState();
    _existe = File(widget.path).existsSync();
    if (_existe) {
      _player = Player();
      _controller = VideoController(_player!);
      _player!.open(Media(widget.path), play: false);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_existe) {
      return _MaterialIndisponivel(path: widget.path);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Video(controller: _controller!),
      ),
    );
  }
}

class _MaterialIndisponivel extends StatelessWidget {
  final String path;
  const _MaterialIndisponivel({required this.path});
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: s.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Arquivo não encontrado:\n$path',
                style: TextStyle(color: s.onSurfaceVariant, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
