import 'dart:convert';
import 'dart:developer';

import 'package:music_app/configuration/app_environment.dart';
import 'package:music_app/model/artist.dart';
import 'package:music_app/model/artist_album.dart';
import 'package:music_app/model/track.dart';
import 'package:music_app/services/network_service.dart';
import 'package:music_app/utils/music_storage.dart';
import 'package:music_app/utils/shared_helpers.dart';
import 'package:dio/dio.dart';

class MusicRepo {
  static final _dio = NetworkService.initDio();
  static Future<void> generateToken() async {
    try {
      final options = BaseOptions(
        baseUrl: "https://accounts.spotify.com/api/",
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      final data = {
        "grant_type": "client_credentials",
        "client_id": AppEnvironment.spotifyClientId,
        "client_secret": AppEnvironment.spotifyClientSecret,
      };

      final response = await Dio(options).post("token", data: data);

      await setSharedString(
        "spofityToken",
        response.data['access_token'].toString(),
      );
    } on DioException catch (e) {
      log('error generateToken $e');
    }
  }

  static Future<void> musicLoaded() async {
    List<String> list = [
      "2WzaAvm2bBCf4pEhyuDgCY",
      "66CXWjxzNUsdJxJ2JdwvnR",
      "0kPb52ySN2k9P6wEZPTUzm",
      "5AJRsYTgSVuUTT2SbhLLxu",
    ];

    List<Artist> temp = [];
    do {
      await getArtist(list).then((value) async {
        if (value[0] == 200) {
          temp = value[1];
        } else {
          await generateToken();
        }
      });
    } while (temp.isEmpty);

    MusicStorage.listMusic = temp;
  }

  static Future<dynamic> getArtist(List<String> listArtists) async {
    try {
      final response = await _dio.get("artists?ids=${listArtists.join(",")}");

      List<Artist> artists = List.from(
        response.data['artists'].map((e) => Artist.fromJson(e)),
      );

      return [response.statusCode, artists];
    } on DioException catch (e) {
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> getArtists(String id) async {
    try {
      final response = await _dio.get("artists/$id/related-artists");

      List<Artist> artists = List.from(
        response.data['artists'].map((e) => Artist.fromJson(e)),
      );

      return [response.statusCode, artists];
    } on DioException catch (e) {
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> getArtistAlbum(String id) async {
    try {
      final response = await _dio.get("artists/$id/albums?limit=5");

      ArtistAlbumResponse artists = ArtistAlbumResponse.fromJson(response.data);

      return [response.statusCode, artists];
    } on DioException catch (e) {
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> getArtistTopTrack(String id) async {
    try {
      final response = await _dio.get("artists/$id/top-tracks");

      List<Tracks> tracks = List.from(
        response.data['tracks'].map((e) => Tracks.fromJson(e)),
      );

      return [response.statusCode, tracks];
    } on DioException catch (e) {
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<String?> getSpotifyPreviewUrl(String trackId) async {
    try {
      final response = await _dio.get(
        'https://open.spotify.com/embed/track/$trackId',
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );

      if (response.statusCode == 200) {
        final htmlContent = response.data;

        // Extract JSON dari script tag __NEXT_DATA__
        final regex = RegExp(
          r'<script id="__NEXT_DATA__" type="application/json">(.+?)</script>',
          dotAll: true,
        );

        final match = regex.firstMatch(htmlContent);

        if (match != null) {
          final jsonString = match.group(1);
          final jsonData = jsonDecode(jsonString!);

          // Navigate ke audioPreview URL
          final audioPreview =
              jsonData['props']?['pageProps']?['state']?['data']?['entity']?['audioPreview']?['url'];

          return audioPreview as String?;
        }
      }
    } catch (e) {
      log('Error scraping Spotify embed: $e');
    }

    return null;
  }

  static Future<List<Tracks>> getMultipleTopTrack(List<String> listId) async {
    try {
      List<Tracks> listTrack = [];

      for (var i = 0; i < listId.length; i++) {
        await getArtistTopTrack(listId[i]).then((value) async {
          if (value[0] == 200) {
            List<Tracks> result = value[1];

            if (result.isNotEmpty) {
              listTrack.add(result.first);
            }
          }
        });
      }

      return listTrack;
    } catch (e) {
      return [];
    }
  }

  static Future<dynamic> searchTrack(String content) async {
    try {
      String query = content.replaceAll(" ", "+");

      final response = await _dio.get("search?q=$query&type=track&limit=4");

      TracksResponse tracks = TracksResponse.fromJson(response.data['tracks']);

      return [response.statusCode, tracks];
    } on DioException catch (e) {
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> getAlbumTrack(String id) async {
    try {
      final response = await _dio.get("albums/$id/tracks");

      TracksResponse tracks = TracksResponse.fromJson(response.data);

      return [response.statusCode, tracks];
    } on DioException catch (e) {
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> getAvailableGenre() async {
    try {
      final response = await _dio.get("recommendations/available-genre-seeds");

      List<String> genres = response.data['genres'].cast<String>();

      return [response.statusCode, genres];
    } on DioException catch (e) {
      return [e.response?.statusCode ?? 500, null];
    }
  }
}
