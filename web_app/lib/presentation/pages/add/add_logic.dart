// lib/pages/add_logic.dart

import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/OllamaClient.dart';
import 'add_state.dart';
import '/config/core/services/base_controller.dart';
import 'package:http/http.dart' as http;

class AddModel extends BaseGetxController with StateMixin<AddState> {
  final AddState state = AddState();
  final Random _random = Random();
  final messageController = TextEditingController();
  final OllamaClient llama = OllamaClient();

  // Using RxList for reactive updates
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  // Flag to indicate if a response is being generated
  final RxBool isGenerating = false.obs;

  // Current regional context data (if any)
  String? currentRegionalContext;

  @override
  void onInit() {
    super.onInit();
    // Initial fetch of forecast data
    fetchForecastData();
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
      // Prepare app context
      String appContext = '''
A platform for forecasting information based on historical data with AI collaboration and specific medical interpolation. It considers all kinds of market aspects for biochemical compounds, from sales to side effects, and is helpful for analyzing products with historical information or newly made synthetic applications.
''';

      // Prepare graph data
      String graphData = '';

      if (currentRegionalContext != null) {
        // Extract data around the clicked point
        // Format: "Month,Year,Sales,Description"
        List<String> contextParts = currentRegionalContext!.split(',');
        if (contextParts.length >= 4) {
          String month = contextParts[0];
          String year = contextParts[1];
          String sales = contextParts[2];
          String description = contextParts[3];
          graphData = '''
Regional Context:
Selected Point - Month: $month, Year: $year
Sales: $sales mg
Side Effects: $description
''';
        }
      } else {
        // General context including all forecast data
        graphData = '''
General Context:
the product ${state.selectedProduct} in ${state.selectedCountry}.
''';
      }

      // Add forecast data to the graph data
      if (state.forecastData != null && state.forecastData!.isNotEmpty) {
        graphData += '''
Here is the forecast data provided by the API the values are in mg not dollars of the product sold:
${_formatForecastDataForLLM()}
''';
      }

      // Listen to the stream of responses
      await for (var response in llama.sendMessage(
        userMessage,
        appContext: appContext,
        graphData: graphData,
      )) {
        buffer += response;
      }

      // After the stream is done, replace "Typing..." with the full message
      if (messages.isNotEmpty && messages.last.message == "Typing...") {
        messages.removeLast();
      }
      messages.add(ChatMessage(message: buffer, isUser: false));

      // Check if the LLM requested a parameter change
      if (_detectParameterChange(buffer)) {
        _handleParameterChange();
      }

      // Update state status to success
      change(state, status: RxStatus.success());
    } catch (e) {
      // Remove the "Typing..." indicator if present
      if (messages.isNotEmpty && messages.last.message == "Typing...") {
        messages.removeLast();
      }

      // Add an error message
      messages.add(ChatMessage(message: "Error: ${e.toString()}", isUser: false));

      // Update state status to error
      change(state, status: RxStatus.error(e.toString()));
    } finally {
      // Set isGenerating to false to enable input
      isGenerating.value = false;
      // Reset regional context after handling
      currentRegionalContext = null;
    }
  }

  /// Formats the forecast data into a readable table or summary for the LLM
  String _formatForecastDataForLLM() {
    if (state.forecastData == null || state.forecastData!.isEmpty) {
      return "No forecast data available.";
    }

    StringBuffer sb = StringBuffer();
    sb.writeln("| Date       | Forecast (yhat) | Lower Bound (yhat_lower) | Upper Bound (yhat_upper) |");
    sb.writeln("|------------|-----------------|--------------------------|--------------------------|");
    for (var forecast in state.forecastData!) {
      sb.writeln("| ${forecast.date} | ${forecast.yhat.toStringAsFixed(2)} | ${forecast.yhatLower.toStringAsFixed(2)} | ${forecast.yhatUpper.toStringAsFixed(2)} |");
    }
    return sb.toString();
  }

  /// Detects if the response contains a request to change parameters.
  bool _detectParameterChange(String response) {
    // Simple keyword detection; can be enhanced with NLP techniques
    final keywords = ['change parameters', 'modify parameters', 'update parameters', 'what if'];
    for (var keyword in keywords) {
      if (response.toLowerCase().contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Handles parameter change requests by invoking a mock graph redraw.
  void _handleParameterChange() {
    // Mock action: Invoke a redraw with changed parameters
    // In a real scenario, this would trigger the forecasting model with new parameters

    // Example: Change the forecast trend by increasing sales by 10%
    _mockRedrawGraph();
  }

  /// Mocks the graph redraw process by modifying the chart data.
  void _mockRedrawGraph() {
    // For demonstration, we'll increase all forecasted sales by 10%
    if (state.chartData.isNotEmpty) {
      for (var data in state.chartData) {
        if (data.dataType == DataType.forecast) {
          data.value *= 1.10; // Increase by 10%
          if (data.yhatLower != null) {
            data.yhatLower = data.yhatLower! * 1.10;
          }
          if (data.yhatUpper != null) {
            data.yhatUpper = data.yhatUpper! * 1.10;
          }
        }
      }
      // Notify listeners about the updated chart data
      change(state, status: RxStatus.success());
      messages.add(ChatMessage(message: "Graph parameters updated based on your request.", isUser: false));
    } else {
      messages.add(ChatMessage(message: "Unable to update graph parameters. No forecast data available.", isUser: false));
      // Update state status to empty
      change(state, status: RxStatus.empty());
    }
  }

  /// Handles changes in the selected product.
  void changeProduct(String product) {
    if (product == state.selectedProduct) return;

    state.selectedProduct = product;
    state.updateAvailableCountries();
    state.resetChartData();

    // Fetch new forecast data based on the updated filters
    fetchForecastData();

    // Update state status to loading
    change(state, status: RxStatus.loading());
  }

  /// Handles changes in the selected country.
  void changeCountry(String country) {
    if (country == state.selectedCountry) return;

    state.selectedCountry = country;
    state.resetChartData();

    // Fetch new forecast data based on the updated filters
    fetchForecastData();

    // Update state status to loading
    change(state, status: RxStatus.loading());
  }

  /// Fetches forecast data from the API based on selected product and country.
  Future<void> fetchForecastData() async {
    // Construct the API URL with query parameters
    final String product = state.selectedProduct;
    final String country = state.selectedCountry;
    int? port = state.countryPortMap[country];
    if (port == null) {
      port = 7070; // Default port
    }
    final Uri apiUrl = Uri.parse('http://3.94.162.57:$port/forecast');

    try {
      // Set isGenerating to true to disable filters and chat input
      isGenerating.value = true;

      // Show a loading message
      messages.add(ChatMessage(message: "Fetching forecast data...", isUser: false));

      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<dynamic> ds = data['ds'];
        List<dynamic> yhat = data['yhat'];
        List<dynamic> yhatLower = data['yhat_lower'];
        List<dynamic> yhatUpper = data['yhat_upper'];

        // Clear existing forecast data
        state.forecastData = [];

        // Parse the forecast data
        for (int i = 0; i < ds.length; i++) {
          state.forecastData!.add(ForecastData(
            date: ds[i],
            yhat: (yhat[i] as num).toDouble(),
            yhatLower: (yhatLower[i] as num).toDouble(),
            yhatUpper: (yhatUpper[i] as num).toDouble(),
          ));
        }

        // Update the chart with forecast data
        _updateChartWithForecast();

        // Remove the loading message
        if (messages.isNotEmpty && messages.last.message == "Fetching forecast data...") {
          messages.removeLast();
        }

        // Notify the LLM that forecast data is available
        messages.add(ChatMessage(message: "Forecast data successfully fetched and updated.", isUser: false));

        // Update state status to success
        change(state, status: RxStatus.success());
      } else {
        // Handle non-200 responses
        throw Exception('Failed to fetch forecast data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Remove the loading message if present
      if (messages.isNotEmpty && messages.last.message == "Fetching forecast data...") {
        messages.removeLast();
      }

      // Add an error message
      messages.add(ChatMessage(message: "Error fetching forecast data: ${e.toString()}", isUser: false));

      // Update state status to error
      change(state, status: RxStatus.error(e.toString()));
    } finally {
      // Re-enable filters and chat input
      isGenerating.value = false;
    }
  }

  /// Updates the chart with the fetched forecast data.
  void _updateChartWithForecast() {
    if (state.forecastData == null || state.forecastData!.isEmpty) return;

    // Clear existing forecast data in chartData to ensure only API data is shown
    state.chartData.removeWhere((data) => data.dataType == DataType.forecast);

    // Convert ForecastData to ChartData and append to chartData
    for (var forecast in state.forecastData!) {
      // Parse the date
      DateTime parsedDate = DateTime.parse(forecast.date);

      state.chartData.add(ChartData(
        parsedDate,
        forecast.yhat,
        forecast.yhatLower,
        forecast.yhatUpper,
        state.selectedProduct,
        'Forecasted based on historical trends',
        DataType.forecast,
      ));
    }

    // Notify listeners about the updated chart data
    change(state, status: RxStatus.success());
  }

  /// Handles graph point clicks by setting the regional context.
  void onGraphPointClicked(ChartData clickedData) {
    // Format: "Month,Year,Sales,Description"
    currentRegionalContext = '${_getMonthName(clickedData.date.month)},${clickedData.date.year},${clickedData.value.toStringAsFixed(2)},${clickedData.description}';
    // Optionally, you can automatically send a prompt to the LLM based on the click
    // For example:
    // addMessageWithContext('Tell me more about this data point.');
  }

  /// Converts month number to month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[(month - 1) % 12];
  }

  /// Sends a message with context automatically (optional)
  void addMessageWithContext(String userMessage) {
    // Set the message controller text and send the message
    messageController.text = userMessage;
    addMessage();
  }

  @override
  void onClose() {
    messageController.dispose();
    state.chartData.clear();
    super.onClose();
  }

  /// Explains the impactful parameters for a specific date.
  void explain(int month, int year, double value) async {
    // Find the data point based on month, year, and value
    var currentIndex = state.chartData.indexWhere(
          (data) => data.value == value && data.date.month == month && data.date.year == year,
    );

    if (currentIndex == -1) {
      // Data point not found
      Get.snackbar("Error", "Data point not found.");
      return;
    }

    var current = state.chartData[currentIndex];

    // Construct date string
    String dateStr = DateFormat('yyyy-MM-dd').format(current.date);

    // Get port based on country
    int? port = state.countryPortMap[state.selectedCountry];

    if (port == null) {
      Get.snackbar("Error", "Port not found for country ${state.selectedCountry}");
      return;
    }

    // Construct API URL
    String apiUrl = 'http://3.94.162.57:$port/impactful-parameters/$dateStr';
    print('Fetching impactful parameters from: $apiUrl');
    try {
      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Send GET request
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        String impactfulParams = response.body; // Assuming the response is plain text or JSON

        // Send impactfulParams to llama to get comprehensive report
        String userMessage = "Provide a comprehensive report based on the following impactful parameters: $impactfulParams";

        String appContext = '''
Comprehensive Report:
Impactful Parameters: $impactfulParams
''';

        String llamaResponse = '';

        await for (var response in llama.sendMessage(
          userMessage,
          appContext: appContext,
        )) {
          llamaResponse += response;
        }

        // Close loading dialog
        Get.back();

        // Show the report in a dialog
        Get.dialog(
          AlertDialog(
            title: const Text('Impactful Parameters Report'),
            content: SingleChildScrollView(child: Text(llamaResponse)),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        // Handle non-200 responses
        Get.back(); // Close loading dialog
        Get.snackbar("Error", "Failed to fetch impactful parameters. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar("Error", "Error fetching impactful parameters: $e");
    }
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.message, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}
