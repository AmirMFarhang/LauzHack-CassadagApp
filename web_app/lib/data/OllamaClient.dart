// lib/data/OllamaClient.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaClient {
  final String baseUrl;

  OllamaClient({this.baseUrl = 'http://localhost:11434'}); // Update if your server runs on a different host or port

  /// Sends a message to the Ollama server with contextual information and returns a stream of response fragments.
  Stream<String> sendMessage(
      String userMessage, {
        String model = 'llama3.2:3b',
        int maxTokens = 150,
        String appContext = '',
        String graphData = '',
      }) async* {
    final url = Uri.parse('$baseUrl/api/generate');

    // Construct the full prompt with app context and graph data
    final prompt = '''
You are an AI assistant for a biochemical compounds forecasting platform. The platform analyzes historical data, including sales and side effects, to forecast market trends and assess product performance. It can provide insights based on regional data (when a user clicks on a specific point in the graph) or general data for overall analysis.

App Context:
$appContext

Graph Data:
$graphData

User Message:
$userMessage

Respond accordingly.
''';

    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': model,
        'prompt': prompt,
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
