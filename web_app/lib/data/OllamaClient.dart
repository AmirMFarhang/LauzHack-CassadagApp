// lib/data/OllamaClient.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaClient {
  final String baseUrl;
  final String apiKey;

  OllamaClient({
    this.baseUrl = 'https://api.groq.com', // Groq API base URL
    required this.apiKey, // Groq API Key
  });

  /// Sends a message to the Groq server with contextual information and returns a stream of response fragments.
  Stream<String> sendMessage(
      String userMessage, {
        String model = 'llama3-8b-8192',
        int maxTokens = 560,
        String appContext = '',
        String graphData = '',
      }) async* {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    // Construct the messages array with system and user messages
    final List<Map<String, String>> messages = [];

    if (appContext.isNotEmpty) {
      messages.add({
        'role': 'system',
        'content': 'App Context:\n$appContext',
      });
    }

    if (graphData.isNotEmpty) {
      messages.add({
        'role': 'system',
        'content': 'Graph Data:\n$graphData',
      });
    }

    messages.add({
      'role': 'user',
      'content': userMessage,
    });

    final requestBody = {
      'model': model,
      'messages': messages,
      'max_tokens': maxTokens,
      // Add any additional fields required by the Groq API
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Assuming Groq API's response structure is similar to OpenAI's
        // with 'choices' being a list of possible completions
        if (data.containsKey('choices') && data['choices'] is List) {
          for (var choice in data['choices']) {
            if (choice.containsKey('message') &&
                choice['message'].containsKey('content')) {
              yield choice['message']['content'];
            }
          }
        } else if (data.containsKey('response')) {
          // Fallback if Groq API returns a single 'response' field
          yield data['response'];
        } else {
          throw Exception('Unexpected response format from Groq API.');
        }
      } else {
        final error = response.body;
        throw Exception('Failed to communicate with Groq API: $error');
      }
    } catch (e) {
      throw Exception('Error communicating with Groq API: $e');
    }
  }
}
