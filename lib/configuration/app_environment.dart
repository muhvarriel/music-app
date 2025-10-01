import 'package:music_app/utils/environment_constant.dart';

class AppEnvironment {
  static Map<String, String> get env => <String, String>{
    EnvironmentConstant.apiKey: const String.fromEnvironment(
      EnvironmentConstant.apiKey,
    ),
    EnvironmentConstant.spotifyClientId: const String.fromEnvironment(
      EnvironmentConstant.spotifyClientId,
    ),
    EnvironmentConstant.spotifyClientSecret: const String.fromEnvironment(
      EnvironmentConstant.spotifyClientSecret,
    ),
  };

  static String get apiKey => env[EnvironmentConstant.apiKey] ?? '';
  static String get spotifyClientId =>
      env[EnvironmentConstant.spotifyClientId] ?? '';
  static String get spotifyClientSecret =>
      env[EnvironmentConstant.spotifyClientSecret] ?? '';
}
