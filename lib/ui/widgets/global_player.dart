import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/widgets/custom_cached_image.dart';
import 'package:music_app/ui/widgets/custom_text.dart';
import 'package:music_app/utils/music_provider.dart';
import 'package:provider/provider.dart';

class GlobalPlayer extends StatelessWidget {
  const GlobalPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    if (musicProvider.track == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              customCachedImage(
                url: musicProvider.track?.album?.images?.first.url ?? "",
                width: 40,
                height: 40,
                radius: 8,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: musicProvider.track?.name ?? "",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    CustomText(
                      text:
                          musicProvider.track?.artists
                              ?.map((e) => e.name)
                              .join(", ") ??
                          "",
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  musicProvider.play(musicProvider.track!);
                },
                icon: Icon(
                  musicProvider.playerState == PlayerState.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
              IconButton(
                onPressed: () {
                  musicProvider.stop();
                },
                icon: const Icon(Icons.stop_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value:
                (musicProvider.position.inMilliseconds) /
                (musicProvider.duration.inMilliseconds.toDouble().isNaN
                    ? 1
                    : musicProvider.duration.inMilliseconds.toDouble()),
            minHeight: 2,
          ),
        ],
      ),
    );
  }
}
