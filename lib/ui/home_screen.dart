import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:music_app/model/artist.dart';
import 'package:music_app/model/track.dart';
import 'package:music_app/repository/music_repo.dart';
import 'package:music_app/ui/music_screen.dart';
import 'package:music_app/ui/widgets/custom_cached_image.dart';
import 'package:music_app/ui/widgets/custom_text.dart';
import 'package:music_app/ui/widgets/track_preview.dart';
import 'package:music_app/utils/app_navigators.dart';
import 'package:music_app/utils/music_provider.dart';
import 'package:music_app/utils/music_storage.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(String)? onWeb;

  const HomeScreen({super.key, this.onWeb});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchEditingController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Tracks> listTrack = [];
  List<Tracks> listSearch = [];
  List<Artist> listSearchArtist = [];
  Timer? _debounce;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void init() async {
    await MusicRepo.musicLoaded();

    await MusicRepo.getMultipleTopTrack(
      MusicStorage.listMusic.map((e) => e.id ?? "").toList(),
    ).then((value) {
      if (mounted) {
        setState(() {
          listTrack = value;
        });
      }
    });
    setState(() {});
  }

  Future<void> getSearchTrack(String query) async {
    await MusicRepo.searchTrack(query).then((value) async {
      if (value[0] == 200) {
        if (mounted) {
          TracksResponse result = value[1];

          setState(() {
            listSearch = result.items ?? [];
          });

          await MusicRepo.getArtist(
            listSearch
                .map((e) => e.artists?.firstOrNull?.id ?? "")
                .toSet()
                .where((e) => e.isNotEmpty)
                .toList(),
          ).then((value) {
            if (value[0] == 200) {
              if (mounted) {
                List<Artist> resultArtist = value[1];

                setState(() {
                  listSearchArtist = resultArtist;
                });
              }
            }
          });
        }
      }
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        getSearchTrack(query);
      } else {
        listSearch.clear();
        listSearchArtist.clear();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: const Icon(Icons.expand_less_rounded),
            )
          : null,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.grey.shade900 : Colors.grey.shade100)
                      .withValues(alpha: opacityBorder),
                ),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.viewPaddingOf(context).top + 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: "Music App",
                          fontSize:
                              20 +
                              (_scrollController.hasClients
                                  ? ((-1 * _scrollController.offset) / 50)
                                        .clamp(0, 10)
                                  : 0),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
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
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: CupertinoTextField(
                            controller: _searchEditingController,
                            placeholderStyle: GoogleFonts.mulish(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
                            placeholder: "Search for track",
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                            ),
                            style: GoogleFonts.mulish(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade900,
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (listSearch.isNotEmpty) _searchSection(),
                  if (listSearchArtist.isNotEmpty)
                    _musicSection("Searched Artist", listSearchArtist),
                  _trackSection(),
                  _musicSection("Popular Artist", MusicStorage.listMusic),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchSection() {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
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
              isAlbum: true,
              onTap: () {
                musicProvider.play(track);
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _trackSection() {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
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
              isAlbum: true,
              onTap: () {
                musicProvider.play(track);
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _musicSection(String title, List<Artist> listArtists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          padding: EdgeInsets.only(left: 16),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: listArtists.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              var artist = listArtists[index];

              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 16 : 0, right: 16),
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();

                    await pageOpenWithResult(MusicScreen(artist: artist));

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
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                            top: 6,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 10.0,
                                                sigmaY: 10.0,
                                              ),
                                              child: Container(
                                                width: 35,
                                                height: 35,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      5,
                                                      5,
                                                      5,
                                                      3,
                                                    ),
                                                color: Colors.grey.shade800
                                                    .withValues(alpha: 0.5),
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
                                bottomRight: Radius.circular(20),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10.0,
                                  sigmaY: 10.0,
                                ),
                                child: Container(
                                  width: 175,
                                  height: 60,
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.grey.shade800.withValues(
                                    alpha: 0.5,
                                  ),
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
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
