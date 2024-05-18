import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:music_app/model/track.dart';
import 'package:music_app/repository/music_repo.dart';
import 'package:music_app/ui/chat_music_screen.dart';
import 'package:music_app/ui/widgets/custom_cached_image.dart';
import 'package:music_app/ui/widgets/custom_text.dart';
import 'package:music_app/utils/app_navigators.dart';
import 'package:music_app/utils/music_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatHomeScreen extends StatefulWidget {
  final Function(String)? onWeb;

  const ChatHomeScreen({super.key, this.onWeb});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final TextEditingController _searchEditingController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Tracks> listTrack = [];
  List<Tracks> listSearch = [];

  final player = AudioPlayer();
  String? idPlayer;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    await MusicRepo.musicLoaded();

    await MusicRepo.getMultipleTopTrack(MusicStorage.listMusic
            .map((e) => e.id ?? "")
            .toList()
            .getRange(0, 4)
            .toList())
        .then((value) {
      if (mounted) {
        setState(() {
          listTrack = value;
        });
      }
    });
    setState(() {});
  }

  Future<void> getSearchTrack(String query) async {
    await MusicRepo.searchTrack(query).then((value) {
      if (value[0] == 200) {
        if (mounted) {
          TracksResponse result = value[1];

          setState(() {
            listSearch = result.items ?? [];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    double opacityBorder = _scrollController.hasClients
        ? (_scrollController.position.maxScrollExtent != 0
            ? ((_scrollController.offset -
                        _scrollController.position.minScrollExtent) /
                    (_scrollController.position.maxScrollExtent -
                        _scrollController.position.minScrollExtent))
                .clamp(0, 1)
            : 0)
        : 0;

    return Scaffold(
        floatingActionButton:
            _scrollController.hasClients && _scrollController.offset > 20
                ? FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      HapticFeedback.lightImpact();

                      _scrollController.animateTo(0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                    child: const Icon(Icons.expand_less_rounded))
                : null,
        body: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: (isDark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100)
                                .withOpacity(opacityBorder)))),
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.viewPaddingOf(context).top + 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: "Music App",
                              fontSize: 20 +
                                  (_scrollController.hasClients
                                      ? ((-1 * _scrollController.offset) / 50)
                                          .clamp(0, 10)
                                      : 0),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (false)
                            GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    size: 18,
                                  )),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                )),
            Expanded(
              child: NotificationListener(
                onNotification: (notification) {
                  setState(() {});
                  return true;
                },
                child: ListView(
                  shrinkWrap: true,
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: CupertinoTextField(
                              controller: _searchEditingController,
                              placeholderStyle: GoogleFonts.mulish(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700),
                              placeholder: "Search for track",
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                              ),
                              style: GoogleFonts.mulish(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade900),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.search,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  getSearchTrack(value);
                                } else {
                                  listSearch.clear();
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    if (listSearch.isNotEmpty) _searchSection(),
                    _trackSection(),
                    _musicSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _searchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Searched",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          padding: EdgeInsets.only(left: 16),
        ),
        const SizedBox(height: 6),
        ListView.builder(
            shrinkWrap: true,
            itemCount: listSearch.length,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              var track = listSearch[index];

              return TrackPreview(
                tracks: track,
                player: player,
                idPlayer: idPlayer,
                isAlbum: true,
                onTap: () {
                  if (mounted) {
                    setState(() {
                      idPlayer = track.id;
                    });
                  }
                },
                onEnd: () {
                  if (mounted) {
                    setState(() {
                      idPlayer = null;
                    });
                  }
                },
              );
            }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _trackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Popular Track",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          padding: EdgeInsets.only(left: 16),
        ),
        const SizedBox(height: 6),
        ListView.builder(
            shrinkWrap: true,
            itemCount: listTrack.length,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              var track = listTrack[index];

              return TrackPreview(
                tracks: track,
                player: player,
                idPlayer: idPlayer,
                isAlbum: true,
                onTap: () {
                  if (mounted) {
                    setState(() {
                      idPlayer = track.id;
                    });
                  }
                },
                onEnd: () {
                  if (mounted) {
                    setState(() {
                      idPlayer = null;
                    });
                  }
                },
              );
            }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _musicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Popular Artist",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          padding: EdgeInsets.only(left: 16),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 200,
          child: ListView.builder(
              itemCount: MusicStorage.listMusic.length,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                var artist = MusicStorage.listMusic[index];

                return Padding(
                  padding:
                      EdgeInsets.only(left: index == 0 ? 16 : 0, right: 16),
                  child: GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();

                      await pageOpenWithResult(ChatMusicScreen(artist: artist));

                      setState(() {});
                    },
                    child: Hero(
                      tag: artist.images?.firstOrNull?.url ?? "",
                      child: Stack(
                        children: [
                          customCachedImage(
                            width: 175,
                            height: 200,
                            radius: 20,
                            isRectangle: true,
                            url: artist.images?.firstOrNull?.url ?? "",
                            isDrive: false,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MusicStorage.favouriteArtist.contains(artist.id)
                                  ? SizedBox(
                                      width: 175,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6, top: 6),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 10.0, sigmaY: 10.0),
                                                child: Container(
                                                  width: 35,
                                                  height: 35,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 5, 5, 3),
                                                  color: Colors.grey.shade800
                                                      .withOpacity(0.5),
                                                  child: const Icon(
                                                    Icons.favorite_rounded,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20)),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                    width: 175,
                                    height: 60,
                                    padding: const EdgeInsets.all(10),
                                    color:
                                        Colors.grey.shade800.withOpacity(0.5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomText(
                                          text: artist.name ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        CustomText(
                                          text:
                                              "${NumberFormat("#,##0", "en_US").format(artist.followers?.total ?? 0)} monthly listeners",
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
