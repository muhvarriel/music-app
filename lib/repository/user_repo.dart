import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:music_app/configuration/app_environment.dart';
import 'package:music_app/model/chat_room.dart';

class UserRepo {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'deepseek-r1-distill-llama-70b';

  static Dio _getDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Authorization': 'Bearer ${AppEnvironment.apiKey}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    return dio;
  }

  // Helper function to remove <think> tags
  static String _cleanThinkTags(String content) {
    // Remove <think>...</think> content using regex
    final regex = RegExp(r'<think>[\s\S]*?<\/think>\s*', multiLine: true);
    return content.replaceAll(regex, '').trim();
  }

  static Future<String?> generateContent({String? text}) async {
    try {
      final dio = _getDio();

      final response = await dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': text ?? ''},
          ],
          'temperature': 0.7,
          'max_completion_tokens': 4096,
        },
      );

      log("response: ${jsonEncode(response.data)}");

      final content = response.data['choices']?[0]?['message']?['content'];

      if (content != null) {
        // Clean the <think> tags before returning
        return _cleanThinkTags(content.toString());
      }

      return null;
    } on DioException catch (e) {
      log('DioException: ${e.message}');
      log('Response: ${e.response?.data}');
      return null;
    } catch (e) {
      log('error $e');
      return null;
    }
  }

  static Future<String?> sendText({
    String? text,
    List<Messages>? history,
  }) async {
    try {
      final dio = _getDio();

      List<Map<String, dynamic>> messages = [];

      if (history != null && history.isNotEmpty) {
        messages = history.map((e) {
          return {
            'role': e.sender?.id == 0 ? 'user' : 'assistant',
            'content': e.content ?? '',
          };
        }).toList();
      }

      messages.add({'role': 'user', 'content': text ?? ''});

      log("messages: ${jsonEncode(messages)}");

      final response = await dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_completion_tokens': 4096,
        },
      );

      log("response: ${jsonEncode(response.data)}");

      final content = response.data['choices']?[0]?['message']?['content'];

      if (content != null) {
        // Clean the <think> tags before returning
        return _cleanThinkTags(content.toString());
      }

      return null;
    } on DioException catch (e) {
      log('DioException: ${e.message}');
      log('Response: ${e.response?.data}');
      return e.response?.data?['error']?['message'] ?? e.message;
    } catch (e) {
      log('error $e');
      return null;
    }
  }
}
