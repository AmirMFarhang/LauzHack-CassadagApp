// lib/pages/add_logic.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/OllamaClient.dart';
import 'add_state.dart';
import '/config/core/services/base_controller.dart';

class AddModel extends BaseGetxController with StateMixin<AddState> {
  final AddState state = AddState();
  final Random _random = Random();
  final messageController = TextEditingController();
  final OllamaClient llama = OllamaClient();

  // Using RxList for reactive updates
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  // Flag to indicate if a response is being generated
  final RxBool isGenerating = false.obs;

  @override
  void onReady() {
    _generateForecastData();
    change(state, status: RxStatus.success());
    // Add initial report about forecast
    messages.add(ChatMessage(message: 'Forecast report generated', isUser: false));
    super.onReady();
  }

  /// Handles sending a message and processing the response stream.
  void addMessage() async {
    final userMessage = messageController.text.trim();
    if (userMessage.isEmpty) return;

    // Add user message to the chat
    messages.add(ChatMessage(message: userMessage, isUser: true));
    messageController.clear();

    // Set isGenerating to true to disable input
    isGenerating.value = true;

    // Add "Typing..." indicator
    messages.add(ChatMessage(message: "Typing...", isUser: false));

    String buffer = '';

    try {
      // Listen to the stream of responses
      await for (var response in llama.sendMessage(userMessage)) {
        buffer += response;
      }

      // After the stream is done, replace "Typing..." with the full message
      if (messages.isNotEmpty && messages.last.message == "Typing...") {
        messages.removeLast();
      }
      messages.add(ChatMessage(message: buffer, isUser: false));
    } catch (e) {
      // Remove the "Typing..." indicator if present
      if (messages.isNotEmpty && messages.last.message == "Typing...") {
        messages.removeLast();
      }

      // Add an error message
      messages.add(ChatMessage(message: "Error: ${e.toString()}", isUser: false));
    } finally {
      // Set isGenerating to false to enable input
      isGenerating.value = false;
    }
  }

  void changeCountry(String country) {
    state.selectedCountry = country;
    state.updateChartData();
    _generateForecastData();
    change(state, status: RxStatus.success());
  }

  void _generateForecastData() {
    if (state.chartData == null || state.chartData!.isEmpty) return;

    final lastData = state.chartData!.last;
    double lastValue = lastData.value;
    int nextMonth = lastData.month;
    int nextYear = lastData.year;

    // Generate 6 months of forecast data
    for (int i = 0; i < 6; i++) {
      // Add some randomization to the forecast while maintaining trend
      lastValue += _random.nextDouble() * 8 - 2; // Random growth between -2 and 6

      nextMonth++;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }

      state.chartData!.add(ChartData(
        nextMonth,
        nextYear,
        lastValue,
        null,
        lastData.productName,
        'Forecasted based on historical trends',
        DataType.forecast,
      ));
    }

    // Notify listeners about the updated chart data
    update();
  }

  String getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1) % 12];
  }

  String getFormattedDate(int month, int year) {
    return '${getMonthName(month)} ${year}';
  }

  void showDataPointDetails(BuildContext context, ChartData point) {
    Get.dialog(
      AlertDialog(
        title: Text('${point.productName} - ${getFormattedDate(point.month, point.year)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Country: ${state.selectedCountry}'),
            Text('Product: ${point.productName}'),
            Text('Period: ${getFormattedDate(point.month, point.year)}'),
            Text('Value: ${point.value.toStringAsFixed(2)} mg'),
            if (point.predictedValue != null)
              Text('Predicted: ${point.predictedValue!.toStringAsFixed(2)} mg'),
            const SizedBox(height: 8),
            Text('Details: ${point.description}'),
            const SizedBox(height: 8),
            Text('Data Type: ${point.dataType.toString().split('.').last.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    state.chartData?.clear();
    super.onClose();
  }
}

class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});
}
