import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/model/track.dart';
import 'package:music_app/ui/widgets/custom_cached_image.dart';
import 'package:music_app/ui/widgets/custom_text.dart';
import 'package:music_app/utils/music_provider.dart';
import 'package:provider/provider.dart';

class TrackPreview extends StatefulWidget {
  final Tracks tracks;
  final Function() onTap;
  final EdgeInsets? padding;
  final bool? isAlbum;

  const TrackPreview({
    super.key,
    required this.tracks,
    required this.onTap,
    this.padding,
    this.isAlbum,
  });

  @override
  State<TrackPreview> createState() => _TrackPreviewState();
}

class _TrackPreviewState extends State<TrackPreview> {
  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final isPlaying = musicProvider.track?.id == widget.tracks.id;

    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Padding(
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                (widget.tracks.album?.images?.isNotEmpty ?? false)
                    ? customCachedImage(
                        width: 50,
                        height: 50,
                        radius: 10,
                        isRectangle: true,
                        url:
                            widget.tracks.album?.images?.firstOrNull?.url ?? "",
                        isDrive: false,
                        isBlack: isPlaying,
                      )
                    : Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: CustomText(
                          text: (widget.tracks.trackNumber ?? 0).toString(),
                        ),
                      ),
                if (isPlaying)
                  Container(
                    width: (widget.tracks.album?.images?.isNotEmpty ?? false)
                        ? 50
                        : 30,
                    height: (widget.tracks.album?.images?.isNotEmpty ?? false)
                        ? 50
                        : 30,
                    padding: (widget.tracks.album?.images?.isNotEmpty ?? false)
                        ? const EdgeInsets.all(14)
                        : EdgeInsets.zero,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      value:
                          musicProvider.playerState == PlayerState.playing ||
                              musicProvider.playerState == PlayerState.paused
                          ? ((musicProvider.position.inMilliseconds) /
                                    (musicProvider.duration.inMilliseconds.isNaN
                                        ? 1
                                        : musicProvider
                                              .duration
                                              .inMilliseconds))
                                .clamp(0, 1)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: widget.tracks.name ?? "",
                    overflow: TextOverflow.clip,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  CustomText(
                    text: (widget.isAlbum ?? false)
                        ? (widget.tracks.album?.name ?? "-")
                        : (widget.tracks.artists
                                  ?.map((e) => e.name ?? "")
                                  .toList()
                                  .join(", ") ??
                              "-"),
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
