// lib/data/OllamaClient.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaClient {
  final String baseUrl;

  OllamaClient({this.baseUrl = 'http://localhost:11434'}); // Update if necessary

  /// Sends a message to the Ollama server and returns a stream of response fragments.
  Stream<String> sendMessage(String message, {String model = 'llama3.2:3b', int maxTokens = 150}) async* {
    final url = Uri.parse('$baseUrl/api/generate');

    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': model,
        'prompt': message,
        'max_tokens': maxTokens,
      });

    final response = await request.send();

    if (response.statusCode == 200) {
      // Decode the response stream
      final stream = response.stream.transform(utf8.decoder);
      String buffer = '';

      await for (var chunk in stream) {
        // Each chunk may contain multiple JSON objects separated by newlines
        final lines = chunk.split('\n').where((line) => line.trim().isNotEmpty);
        for (var line in lines) {
          try {
            final data = jsonDecode(line);
            if (data['response'] != null && data['response'].isNotEmpty) {
              buffer += data['response'];
            }
          } catch (e) {
            // Handle JSON parsing errors
            print('Error parsing JSON: $e');
          }
        }
      }

      // Yield the accumulated response as a single message
      if (buffer.isNotEmpty) {
        yield buffer;
      }
    } else {
      final error = await response.stream.bytesToString();
      throw Exception('Failed to communicate with Ollama: $error');
    }
  }
}
