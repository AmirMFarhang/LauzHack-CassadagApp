// lib/pages/add_view.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import '../../components/custom_drawer.dart';
import 'add_logic.dart';
import 'add_state.dart';

/// Extension to capitalize the first letter of a string
extension StringCasingExtension on String {
  String get capitalizeFirst {
    if (this.isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  // ScrollController to auto-scroll to the latest message
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    Get.delete<AddModel>();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Delete existing model if it exists
    Get.delete<AddModel>();

    // Create new model
    final AddModel model = Get.put(AddModel());

    return Scaffold(
      body: Row(
        children: [
          _buildSideMenu(model, model.state),
          Expanded(
            child: model.obx(
                  (state) => _buildBody(model, state!),
              onLoading: const Center(child: CircularProgressIndicator()),
              onEmpty: const Center(child: Text("No Data")),
              onError: (error) => Center(child: Text(error.toString())),
            ),
          ),
          _buildChatUI(model),
        ],
      ),
    );
  }

  Widget _buildSideMenu(AddModel model, AddState state) {
    return const CustomDrawer();
  }

  Widget _buildSideMenuItem(IconData icon, String text, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onPressed,
    );
  }

  Widget _buildBody(AddModel model, AddState state) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('Product Sales Analysis & Forecast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Increased padding for better layout
        child: Column(
          children: [
            // Styled container for the description
            Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50, // Light purple background
                borderRadius: BorderRadius.circular(12), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4), // Subtle shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0), // Padding inside the container
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  children: [
                    const TextSpan(
                      text: "Power your decisions with ",
                    ),
                    TextSpan(
                      text: "real-time insights",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                      " and advanced analytics. Forecast trends, assess market impact, and unlock new opportunities with the power of ",
                    ),
                    TextSpan(
                      text: "machine learning.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterSection(model, state),
            const SizedBox(height: 20),
            Expanded(
              child: _buildChart(model, state),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the filter section with product and country selectors
  Widget _buildFilterSection(AddModel model, AddState state) {
    return Row(
      children: [
        // Product Selector
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Product',
              border: OutlineInputBorder(),
            ),
            value: state.selectedProduct,
            items: state.availableProducts.map((product) {
              return DropdownMenuItem(
                value: product,
                child: Text(product),
              );
            }).toList(),
            onChanged: model.isGenerating.value
                ? null
                : (value) {
              if (value != null) {
                model.changeProduct(value);
              }
            },
          ),
        ),
        const SizedBox(width: 20),
        // Country Selector
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(),
            ),
            value:
            state.selectedCountry.isNotEmpty ? state.selectedCountry : null,
            items: state.availableCountries.map((country) {
              return DropdownMenuItem(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: model.isGenerating.value
                ? null
                : (value) {
              if (value != null) {
                model.changeCountry(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChart(AddModel model, AddState state) {
    // Check if chartData is empty
    if (state.chartData.isEmpty) {
      return const Center(child: Text("No chart data available."));
    }

    // Dynamically calculate the minimum and maximum dates from chartData
    DateTime minDate = state.chartData
        .map((data) => data.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    DateTime maxDate = state.chartData
        .map((data) => data.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
        ),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          title: ChartTitle(
            text:
            '${state.selectedProduct} in ${state.selectedCountry} - Monthly Product Performance',
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          legend: const Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom,
          ),
          primaryXAxis: DateTimeAxis(
            minimum: minDate,
            maximum: maxDate,
            intervalType: DateTimeIntervalType.months,
            dateFormat: DateFormat('MMM yyyy'),
            majorGridLines: const MajorGridLines(width: 0),
            title: const AxisTitle(text: 'Month'),
          ),
          primaryYAxis: NumericAxis(
            minimum: state.chartData
                .map((data) => data.yhatLower ?? data.value)
                .reduce(min) -
                1000,
            maximum: state.chartData
                .map((data) => data.yhatUpper ?? data.value)
                .reduce(max) +
                1000,
            labelFormat: '{value}',
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(color: Colors.transparent),
            title: const AxisTitle(text: 'Sales'),
          ),
          series: _buildSeries(state),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'point.x : point.y mg',
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                // Show the information and explain button
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Month: ${DateFormat('MMMM').format(data.date)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Year: ${data.date.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Sales: ${data.value.toInt()} mg',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    // Explain button
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        model.explain(
                            data.date.month, data.date.year, data.value);
                        // The explanation dialog is handled within the explain method
                      },
                      child: const Text('Explain'),
                    ),
                  ],
                ),
              );
            },
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true,
            enablePinching: true,
            enableDoubleTapZooming: true,
            enableMouseWheelZooming: true,
            enableSelectionZooming: true,
            zoomMode: ZoomMode.x,
          ),
          crosshairBehavior: CrosshairBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            lineType: CrosshairLineType.vertical,
          ),
        ),
      ),
    );
  }

  /// Builds the series for the chart, differentiating data types
  List<CartesianSeries<dynamic, DateTime>> _buildSeries(AddState state) {
    return [
      // RangeAreaSeries for yhat_lower and yhat_upper
      RangeAreaSeries<dynamic, DateTime>(
        dataSource: state.chartData,
        xValueMapper: (dynamic data, _) => data.date,
        lowValueMapper: (dynamic data, _) => data.yhatLower ?? data.value,
        highValueMapper: (dynamic data, _) => data.yhatUpper ?? data.value,
        name: 'Confidence Interval',
        color: Colors.red.withOpacity(0.3),
        borderColor: Colors.red,
        borderWidth: 1,
      ),
      // LineSeries for yhat
      LineSeries<dynamic, DateTime>(
        dataSource: state.chartData,
        xValueMapper: (dynamic data, _) => data.date,
        yValueMapper: (dynamic data, _) => data.value,
        name: 'Forecast (yhat)',
        color: Colors.red,
        markerSettings: const MarkerSettings(isVisible: true),
        dataLabelSettings: const DataLabelSettings(isVisible: false),
        width: 2,
      ),
    ];
  }

  Widget _buildChatUI(AddModel model) {
    return Container(
      width: Get.width * 0.25,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Obx(() {
              // Auto-scroll to the latest message when a new message is added
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: model.messages.length,
                itemBuilder: (context, index) {
                  final message = model.messages[index];
                  return Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Colors.blue
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: message.isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          message.isUser
                              ? Text(
                            message.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          )
                              : Html(
                            data: message.message,
                            style: {
                              'body': Style(
                                fontSize:  FontSize(16),
                                color: Colors.black87,
                              ),
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          // Message input field
          _buildMessageInput(model),
        ],
      ),
    );
  }

  Widget _buildMessageInput(AddModel model) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              return TextField(
                controller: model.messageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type a message',
                ),
                onSubmitted: (value) => model.addMessage(),
                enabled: !model.isGenerating.value, // Disable when generating
              );
            }),
          ),
          const SizedBox(width: 10),
          Obx(() {
            return ElevatedButton(
              onPressed: model.isGenerating.value ? null : model.addMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Updated from surfaceTintColor
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: model.isGenerating.value
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Send'),
            );
          }),
        ],
      ),
    );
  }
}
