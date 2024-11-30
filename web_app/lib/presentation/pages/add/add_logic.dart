// add_logic.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_state.dart';
import '/config/core/services/base_controller.dart';

class AddModel extends BaseGetxController with StateMixin<AddState> {
  final AddState state = AddState();
  final Random _random = Random();
  final messageController = TextEditingController();

  List<String> messages = [];

  void addMessage() {
    if (messageController.text.isNotEmpty) {
      messages.add(messageController.text);
      messageController.clear();
      update();
    }
  }


  @override
  void onReady() {
    _generateForecastData();
    change(state, status: RxStatus.success());
    // add small report about forcast in html to message list
    messages.add('Forecast report generated');
    super.onReady();
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
    int nextMonth = 1;
    int nextYear = 2024;

    // Generate 6 months of forecast data
    for (int i = 0; i < 6; i++) {
      // Add some randomization to the forecast while maintaining trend
      lastValue += _random.nextDouble() * 8 - 2; // Random growth between -2 and 6

      state.chartData!.add(ChartData(
        nextMonth,
        nextYear,
        lastValue,
        null,
        lastData.productName,
        'Forecasted based on historical trends',
        DataType.forecast,
      ));

      nextMonth++;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
    }
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
    state.chartData?.clear();
    super.onClose();
  }
}