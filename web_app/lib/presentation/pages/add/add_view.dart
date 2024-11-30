import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../config/theme/app_colors.dart';
import '../../components/button.dart';
import '../../components/country_selection.dart';
import '../../components/custom_drawer.dart';
import 'add_logic.dart';
import 'add_state.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  @override
  void dispose() {
    Get.delete<AddModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // delete model if it exists
    Get.delete<AddModel>();

    // create new model
    final AddModel model = Get.put(AddModel());

    return Scaffold(
      body: Row(
        children: [
          _buildSideMenu(model, model.state),
          Expanded(
            child: model.obx(
                  (state) => _buildBody(model, model.state),
              onLoading: const Center(child: CircularProgressIndicator()),
              onEmpty: const Center(child: Text("No Data")),
              onError: (error) => Text(error.toString()),
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

  Widget _buildSideMenuItem(IconData icon, String text,
      VoidCallback onPressed) {
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
        padding: const EdgeInsets.all(16.0), // Increase padding for better layout
        child: Column(
          children: [
            // Create a styled container for the description
            Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50, // Light purple background
                borderRadius: BorderRadius.circular(12), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4), // Add subtle shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0), // Padding inside the container
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(Get.context!)
                      .textTheme
                      .labelMedium!
                      .copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "Power your decisions with ",
                    ),
                    TextSpan(
                      text: "real-time insights",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
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
            Expanded(
              child: _buildChart(model, state),
            ),
          ],
        ),
      ),
    );
  }


}

  Widget _buildChart(AddModel model, AddState state) {
  return Column(
    children: [
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color:
            Theme.of(Get.context!).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/svg/ic_filter.svg",
              color: Get.theme.colorScheme.primary,
            ),
            SizedBox(
              width: Get.width / 100 * 0.5,
            ),
            Text(
              "Filter Analysis by ",
              textAlign: TextAlign.center,
              style: Theme.of(Get.context!)
                  .textTheme
                  .labelMedium!
                  .copyWith(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              width: Get.width / 100 * 0.5,
            ),   SizedBox(
              width: Get.width / 100 * 0.5,
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                  child: ProviderSelection(
                    selectedLabel: state.selectedCountry,
                    data: state.availableCountries,
                    onChanged: (value) {
                      if (value != null) {
                        model.changeCountry(value);
                      }
                    },
                  )),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                  child: ProviderSelection(
                    selectedLabel: "Product A",
                    data: ["Product A", "Product B"],
                    onChanged: (value) {},
                  )),
            ),


          ],
        ),
      ),
      const SizedBox(height: 20),

      Expanded(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
            ),
            child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                title: ChartTitle(
                  text: '${state.selectedCountry} - Monthly Product Performance',
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                legend: const Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                  position: LegendPosition.bottom,
                ),
                primaryXAxis: NumericAxis(
                  minimum: 1,
                  maximum: state.chartData!.length.toDouble(),
                  interval: 1,
                  majorGridLines: const MajorGridLines(width: 0),
                  plotBands: const <PlotBand>[
                    PlotBand(
                        start: 13, // Start of the forecast period
                        end: 18, // End of the forecast period
                        size: 20,
                        associatedAxisStart: 230.5,
                        text: 'Market Expansion',
                        verticalTextAlignment: TextAnchor.end,
                        associatedAxisEnd: 200.5,
                        textAngle: 0,

                        isVisible: true,
                        color: Color(0xFF0095F5),
                        textStyle: TextStyle(color: Colors.white, fontSize: 17)),

                  ],
                  title: const AxisTitle(text: 'Month'),
                  axisLabelFormatter: (AxisLabelRenderDetails details) {
                    final int monthIndex = details.value.toInt();
                    if (monthIndex <= state.chartData!.length) {
                      final chartData = state.chartData![monthIndex - 1];
                      return ChartAxisLabel(
                        model.getFormattedDate(chartData.month, chartData.year),
                        details.textStyle,
                      );
                    }
                    return ChartAxisLabel('', details.textStyle);
                  },
                ),
              primaryYAxis: NumericAxis(
                minimum: state.chartData != null && state.chartData!.isNotEmpty
                    ? state.chartData!
                    .map((data) => data.value)
                    .reduce((a, b) => a < b ? a : b) -
                    10 // Adjust this offset as needed to add padding below the min value
                    : null,
                labelFormat: '{value}mg',
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(color: Colors.transparent),
                title: const AxisTitle(text: 'Sales'),
              ),

              series: <LineSeries<ChartData, num>>[
                // Real data series
                LineSeries<ChartData, num>(
            dataSource: state.chartData!
                .where((data) => data.dataType == DataType.real)
                .toList(),
            xValueMapper: (ChartData sales, _) => sales.monthIndex,
            yValueMapper: (ChartData sales, _) => sales.value,
            name: 'Actual Sales',
            color: Colors.blue,
            markerSettings: const MarkerSettings(isVisible: true),
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
                // Test data series
                LineSeries<ChartData, num>(
                dataSource: state.chartData!
                    .where((data) => data.dataType == DataType.test)
                .toList(),
            xValueMapper: (ChartData sales, _) => sales.monthIndex,
            yValueMapper: (ChartData sales, _) => sales.value,
            name: 'Test Data',
            color: Colors.green,
                  markerSettings: const MarkerSettings(isVisible: true),
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
                  // Test data predictions
                  LineSeries<ChartData, num>(
                    dataSource: state.chartData!
                        .where((data) => data.dataType == DataType.test && data.predictedValue != null)
                        .toList(),
                    xValueMapper: (ChartData sales, _) => sales.monthIndex,
                    yValueMapper: (ChartData sales, _) => sales.predictedValue,
                    name: 'Test Predictions',
                    color: Colors.orange,
                    dashArray: const <double>[5, 5],
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                  // Forecast data series
                  LineSeries<ChartData, num>(
                    dataSource: state.chartData!
                        .where((data) => data.dataType == DataType.forecast)
                        .toList(),
                    xValueMapper: (ChartData sales, _) => sales.monthIndex,
                    yValueMapper: (ChartData sales, _) => sales.value,
                    name: 'Forecast',
                    color: Colors.red,
                    dashArray: const <double>[15, 3, 3, 3],
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    emptyPointSettings: const EmptyPointSettings(
                      mode: EmptyPointMode.zero,
                      color: Colors.black,
                    ),

                  ),
                ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x : point.y mg',
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
              // onPointTapped: (PointTapArgs args) {
              //   if (state.chartData != null && args.pointIndex < state.chartData!.length) {
              //     model.showDataPointDetails(
              //       Get.context!,
              //       state.chartData![args.pointIndex],
              //     );
              //   }
              // },
              onDataLabelTapped: (DataLabelTapDetails args) {
                if (state.chartData != null && args.pointIndex < state.chartData!.length) {
                  model.showDataPointDetails(
                    Get.context!,
                    state.chartData![args.pointIndex],
                  );
                }
              },
            ),
          ),
        ),
      ),
    ],
  );
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
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildMessage("""<!DOCTYPE html>
<html>
<head>
    <title>Market Expansion Impact</title>
</head>
<body>
    <h2>Market Expansion</h2>
    <p>
        The market expansion is expected to increase sales by targeting new regions and customer segments. 
        Based on current assumptions, this initiative has a projected impact of a 15% sales boost with a 
        70% probability of success. Further analysis is ongoing to refine these estimates.
    </p>
</body>
</html>
""");
            },
          ),
        ),
        _buildMessageInput(model),
      ],
    ),
  );
}

Widget _buildMessage(String message) {
  return Container(
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Html(
      data: message,
      style: {
        'body': Style(
          fontSize: FontSize(16),
          color: Colors.white,
        ),
      },
    ),
  );
}


Widget _buildMessageInput(AddModel model) {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: model.messageController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type a message',
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: model.addMessage,
          style: ElevatedButton.styleFrom(

          surfaceTintColor: Colors.blue,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Send'),

        ),
      ],
    ),
  );
}