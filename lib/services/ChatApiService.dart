import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatApiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  static String get _apiKey {
    final configuredKey = (dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['API_KEY'] ?? '').trim();
    return configuredKey;
  }

  static String get _model {
    final configuredModel = (dotenv.env['GEMINI_MODEL'] ?? dotenv.env['MODEL_NAME'] ?? 'gemini-1.5-flash').trim();
    return configuredModel.isEmpty ? 'gemini-1.5-flash' : configuredModel;
  }

  static String get _baseUrl {
    return 'https://generativelanguage.googleapis.com/v1/models/$_model:generateContent';
  }

  Future<String> sendMessage(
    List<Map<String, String>> conversation, {
    CancelToken? cancelToken,
    String? systemPrompt,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return 'No internet connection. Please check your network and try again.';
    }

    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      return 'Error: Missing Gemini API key. Add API_KEY to your .env file.';
    }

    if (!apiKey.startsWith('AIza')) {
      return 'Error: Invalid API Key format. Gemini API keys usually start with "AIza". Please check your .env file.';
    }

    try {
      final contents = conversation.map((msg) {
        return {
          'role': msg['role'] == 'assistant' ? 'model' : 'user',
          'parts': [
            {'text': msg['content']}
          ]
        };
      }).toList();

      final data = {
        'contents': contents,
        if (systemPrompt != null && systemPrompt.trim().isNotEmpty)
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt}
            ]
          },
      };

      final response = await _dio.post(
        '$_baseUrl?key=$apiKey',
        data: data,
        cancelToken: cancelToken,
      );

      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return 'Error: No response from AI (Empty candidates)';
      }

      final candidate = candidates[0];
      final content = candidate['content'];

      if (content == null) {
        final finishReason = candidate['finishReason'] ?? 'Unknown';
        return 'Error: AI response blocked. Reason: $finishReason';
      }

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        return 'Error: Gemini returned no text parts.';
      }

      final botReply = parts[0]['text'];
      return botReply?.toString() ?? 'Error: Empty response text';
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return 'CANCELLED';
      }

      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Error: Connection timed out. Please try again.';
      }

      final statusCode = e.response?.statusCode;
      if (statusCode == 400 || statusCode == 404) {
        final errorMsg = e.response?.data?['error']?['message'] ?? 'Invalid model or key';
        return 'Error: $errorMsg';
      }
      if (statusCode == 401 || statusCode == 403) {
        return 'API access denied. Please check your API key.';
      }
      if (statusCode == 429) {
        return 'Rate limit exceeded. Please try again in a moment.';
      }
      return 'Error: Failed to connect to Gemini (${e.type})';
    } catch (e) {
      return 'Error: An unexpected error occurred';
    }
  }

  static bool isError(String reply) {
    const errorPrefixes = [
      'Error:',
      'No internet connection',
      'API access denied',
      'Rate limit exceeded'
    ];
    return errorPrefixes.any((prefix) => reply.startsWith(prefix));
  }

  Future<String> generateTitle(String userMessage, String botReply) async {
    try {
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        return 'Untitled chat';
      }

      final data = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text':
                    'Generate a short, clear title (3-6 words) summarizing this exchange:\nUser: $userMessage\nAI: $botReply\n\nReply with ONLY the title text.'
              }
            ]
          }
        ],
      };

      final response = await _dio.post(
        '$_baseUrl?key=$apiKey',
        data: data,
      );

      final candidates = response.data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']['parts'] as List?;
        final title = parts != null && parts.isNotEmpty
            ? parts[0]['text'].toString().trim()
            : '';
        return title.isEmpty ? 'Untitled chat' : title;
      }
      return 'Untitled chat';
    } catch (e) {
      return 'Untitled chat';
    }
  }
}
