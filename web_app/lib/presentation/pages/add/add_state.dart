// lib/pages/add_state.dart

enum DataType {
  forecast,  // Predicted future data
}

class ChartData {
  final DateTime date;
  double value; // yhat
  double? yhatLower;
  double? yhatUpper;
  final String productName;
  final String description;
  final DataType dataType;

  ChartData(
      this.date,
      this.value,
      this.yhatLower,
      this.yhatUpper,
      this.productName,
      this.description,
      this.dataType,
      );
}

class ForecastData {
  final String date; // Expecting "YYYY-MM-DD"
  final double yhat;
  final double yhatLower;
  final double yhatUpper;

  ForecastData({
    required this.date,
    required this.yhat,
    required this.yhatLower,
    required this.yhatUpper,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      date: json['ds'],
      yhat: (json['yhat'] as num).toDouble(),
      yhatLower: (json['yhat_lower'] as num).toDouble(),
      yhatUpper: (json['yhat_upper'] as num).toDouble(),
    );
  }
}

class AddState {
  List<ChartData> chartData = [];
  List<String> availableProducts = ['innovix', 'briorist'];
  String selectedProduct = 'innovix';
  List<String> availableCountries = ['elnonie', 'floresland'];
  String selectedCountry = 'elnonie';

  // Forecast Data fetched from API
  List<ForecastData>? forecastData;

  // Mapping of countries to their respective ports
  final Map<String, int> countryPortMap = {
    'elnonie': 7071,
    'floresland': 7072,
    'zigoland': 7070,
    // Add more countries and ports as needed
  };

  AddState() {
    // No initial data
  }

  /// Update available countries based on selected product
  void updateAvailableCountries() {
    if (selectedProduct == 'innovix') {
      availableCountries = ['elnonie', 'floresland'];
    } else if (selectedProduct == 'briorist') {
      availableCountries = ['zigoland'];
    } else {
      availableCountries = [];
    }

    // Reset selected country to the first available
    if (availableCountries.isNotEmpty) {
      selectedCountry = availableCountries[0];
    } else {
      selectedCountry = '';
    }
  }

  /// Reset chartData
  void resetChartData() {
    chartData = [];
  }
}